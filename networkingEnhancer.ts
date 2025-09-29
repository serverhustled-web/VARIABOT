/**
 * Networking Enhancement Command Orchestrator (corrected)
 *
 * Corrections:
 * - Replaced deprecated `nmap -sP` with `nmap -sn`.
 * - Added timeouts and larger maxBuffer to avoid hangs/partial output.
 * - Concurrency limiting to avoid resource contention.
 * - Graceful fallbacks for commands that may not exist (Android/Termux/containers).
 * - Reduced root-only/long-running defaults (short tcpdump capture; bounded traceroute/mtr).
 * - Clear auditing with which alternative actually executed.
 *
 * References: /reference vault (CLI orchestration, audit logging), Node child_process.exec
 */

import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

type NetCmd = {
  name: string;
  desc: string;
  // Alternatives are attempted in order; first successful runs is used.
  alternatives: string[];
  critical?: boolean;
  timeoutMs?: number;
};

const DEFAULT_TIMEOUT = 10_000; // 10s per command
const MAX_BUFFER = 10 * 1024 * 1024; // 10MB

const NET_COMMANDS: NetCmd[] = [
  { name: "ip", desc: "Modern interfaces", alternatives: ["ip addr show"] },
  { name: "ifconfig", desc: "Legacy interfaces", alternatives: ["ifconfig"], timeoutMs: 4000 },
  { name: "ping", desc: "Ping 1.1.1.1", alternatives: ["ping -c 3 -w 5 1.1.1.1"] },
  { name: "trace", desc: "Route hops", alternatives: ["traceroute -m 10 -q 1 1.1.1.1", "tracepath -n 1.1.1.1"], timeoutMs: 8000 },
  { name: "ss", desc: "Socket stats", alternatives: ["ss -s"] },
  { name: "netstat", desc: "Legacy connections", alternatives: ["netstat -an"], timeoutMs: 4000 },
  { name: "dns-dig", desc: "DNS lookup", alternatives: ["dig +short google.com", "nslookup -type=A google.com", "host google.com"], timeoutMs: 5000 },
  { name: "route", desc: "Routing table", alternatives: ["ip route show", "route -n"], timeoutMs: 4000 },
  { name: "wireless", desc: "Wireless info", alternatives: ["iw dev", "iwconfig"], timeoutMs: 4000 },
  { name: "nmap-scan", desc: "LAN ping scan", alternatives: ["nmap -sn 192.168.1.0/24"], timeoutMs: 12000 },
  { name: "tcpdump-sample", desc: "Packet capture (5 pkts)", alternatives: ["tcpdump -c 5 -i any -nn"], timeoutMs: 8000 },
  { name: "wget", desc: "HTTP GET (spider)", alternatives: ["wget -q --spider http://example.com || true"], timeoutMs: 5000 },
  { name: "curl", desc: "HTTP HEAD", alternatives: ["curl -I --max-time 5 http://example.com"], timeoutMs: 5000 },
  { name: "ssh", desc: "SSH version", alternatives: ["ssh -V || true"], timeoutMs: 3000 },
  { name: "nmcli", desc: "NetworkManager", alternatives: ["nmcli connection show"], timeoutMs: 4000 },
  { name: "ethtool", desc: "Ethernet status", alternatives: ["ethtool eth0 || true"], timeoutMs: 4000 },
  { name: "neigh", desc: "ARP/neigh cache", alternatives: ["ip neigh show", "arp -a"], timeoutMs: 4000 },
  { name: "iptables", desc: "Firewall rules", alternatives: ["iptables -L -n || true", "nft list tables || true"], timeoutMs: 5000 },
  { name: "mtr", desc: "Condensed mtr", alternatives: ["mtr -r -c 3 -wz google.com"], timeoutMs: 8000 },
  { name: "ipcalc", desc: "Subnet calc", alternatives: ["ipcalc 192.168.1.1/24"], timeoutMs: 2000 },
];

type CmdResult = {
  name: string;
  desc: string;
  executed: string | null; // which alternative ran
  stdout: string;
  stderr: string;
  ok: boolean;
  startedAt: string;
  endedAt: string;
  durationMs: number;
};

async function runFirstAvailable(cmd: NetCmd): Promise<CmdResult> {
  const startedAt = new Date();
  const startMs = Date.now();
  for (const candidate of cmd.alternatives) {
    try {
      const { stdout, stderr } = await execAsync(candidate, {
        timeout: cmd.timeoutMs ?? DEFAULT_TIMEOUT,
        maxBuffer: MAX_BUFFER,
        windowsHide: true,
      });
      const endMs = Date.now();
      return {
        name: cmd.name,
        desc: cmd.desc,
        executed: candidate,
        stdout,
        stderr,
        ok: true,
        startedAt: startedAt.toISOString(),
        endedAt: new Date().toISOString(),
        durationMs: endMs - startMs,
      };
    } catch (err: any) {
      // Try next alternative on common failures (ENOENT, exit code 127, timeout)
      const code = err?.code;
      const isTimeout = !!err?.killed || /ETIMEDOUT|timeout/i.test(err?.message || "");
      const isNotFound = code === 127 || /not found|command not found/i.test(err?.message || "");
      const shouldTryNext = isTimeout || isNotFound || true; // fall through to next alt regardless
      if (!shouldTryNext) {
        const endMs = Date.now();
        return {
          name: cmd.name,
          desc: cmd.desc,
          executed: candidate,
          stdout: "",
          stderr: String(err?.message ?? err),
          ok: false,
          startedAt: startedAt.toISOString(),
          endedAt: new Date().toISOString(),
          durationMs: endMs - startMs,
        };
      }
      // continue
    }
  }
  const endMs = Date.now();
  return {
    name: cmd.name,
    desc: cmd.desc,
    executed: null,
    stdout: "",
    stderr: "All alternatives failed.",
    ok: false,
    startedAt: startedAt.toISOString(),
    endedAt: new Date().toISOString(),
    durationMs: endMs - startMs,
  };
}

function pLimit(concurrency: number) {
  let active = 0;
  const queue: (() => void)[] = [];
  const next = () => {
    active--;
    if (queue.length) {
      const fn = queue.shift()!;
      fn();
    }
  };
  return function <T>(fn: () => Promise<T>): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      const run = () => {
        active++;
        fn().then(
          (v) => { next(); resolve(v); },
          (e) => { next(); reject(e); }
        );
      };
      if (active < concurrency) run();
      else queue.push(run);
    });
  };
}

async function runNetCommandsInUnison(commands: NetCmd[] = NET_COMMANDS, concurrency = 4) {
  const limit = pLimit(Math.max(1, concurrency));
  const tasks = commands.map(c => limit(() => runFirstAvailable(c)));
  const results = await Promise.all(tasks);
  for (const r of results) {
    auditLog(r);
    if (!r.ok && commands.find(c => c.name === r.name)?.critical) {
      throw new Error(`Critical command failed: ${r.name}`);
    }
  }
  return indexBy(results, x => x.name);
}

function auditLog(r: CmdResult) {
  const status = r.ok ? "OK" : "ERROR";
  console.log(
    `[${r.endedAt}] [${status}] ${r.name}: ${r.desc}\n` +
    `  Executed: ${r.executed ?? "none"}\n` +
    `  Duration: ${r.durationMs}ms\n` +
    `  STDOUT: ${trimOut(r.stdout)}\n` +
    `  STDERR: ${trimOut(r.stderr)}\n`
  );
}

function trimOut(s: string, max = 2000) {
  s = (s || "").toString();
  return s.length > max ? s.slice(0, max) + `\n... [${s.length - max} more bytes]` : s;
}

function indexBy<T>(arr: T[], key: (x: T) => string): Record<string, T> {
  return arr.reduce((acc, v) => { acc[key(v)] = v; return acc; }, {} as Record<string, T>);
}

// For direct execution
if (require.main === module) {
  runNetCommandsInUnison().then(map => {
    // Summary print
    console.log("\nSummary:");
    for (const k of Object.keys(map)) {
      const r = map[k];
      console.log(`- ${k}: ${r.ok ? "ok" : "fail"} (${r.executed ?? "none"}) in ${r.durationMs}ms`);
    }
  }).catch(e => {
    console.error("Execution failed:", e?.message || e);
    process.exit(1);
  });
}

export { runNetCommandsInUnison, NET_COMMANDS, type NetCmd, type CmdResult };

/*
References:
- /reference vault (CLI orchestration patterns, audit logging)
- Node.js child_process.exec: https://nodejs.org/api/child_process.html#child_processexeccommand-options-callback
- Nmap ping scan: https://nmap.org/book/man-host-discovery.html
- ip vs ifconfig: Linux iproute2 documentation
*/