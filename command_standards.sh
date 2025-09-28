#!/bin/bash
# command_standards.sh - VARIABOT User Command Standards Definitions
# Defines forbidden patterns, required patterns, and compliance rules for AI command validation

# CRITICAL FORBIDDEN PATTERNS - Commands containing these are immediately rejected
FORBIDDEN_PATTERNS=(
    "rm -rf /"
    "sudo rm -rf"
    "format c:"
    "del /s /q"
    "DROP DATABASE"
    "DROP TABLE"
    "TRUNCATE TABLE"
    "rm -rf /var"
    "rm -rf /etc"
    "rm -rf /usr"
    "rm -rf /home"
    "rm -rf /root"
    "chmod 777 /"
    "chown -R root:root /"
    "mkfs."
    "fdisk /dev/"
    "dd if=/dev/zero"
    "killall -9"
    "pkill -f"
    "shutdown now"
    "reboot now"
    "halt -f"
    "init 0"
    ":/bin/sh"
    "nc -e /bin/sh"
    "bash -i"
    "python -c \"exec\""
    "eval("
    "exec("
    "system("
    "__import__"
    "compile("
    "globals("
    "locals("
    "getattr"
    "setattr"
    "delattr"
    "vars("
    "dir("
    "help("
    "input("
    "raw_input("
    "open("
    "file("
    "execfile("
    "reload("
    "memoryview("
    "buffer("
    "bytearray("
    "subprocess.call"
    "subprocess.run"
    "subprocess.Popen"
    "os.system"
    "os.popen"
    "os.spawn"
    "os.exec"
    "commands.getoutput"
    "commands.getstatusoutput"
    "pexpect.spawn"
    "paramiko.SSHClient"
    "socket.socket"
    "urllib.request.urlopen"
    "urllib2.urlopen"
    "requests.get"
    "requests.post"
    "ftplib.FTP"
    "smtplib.SMTP"
    "telnetlib.Telnet"
    "dangerous_function"
    "unsafe_operation"
    "bypass_security"
    "disable_firewall"
    "remove_antivirus"
    "crack_password"
    "exploit_vulnerability"
    "backdoor"
    "rootkit"
    "keylogger"
    "botnet"
    "malware"
    "virus"
    "trojan"
    "worm"
    "ransomware"
    "spyware"
    "adware"
)

# REQUIRED SECURITY PATTERNS - Commands should include these for security compliance
REQUIRED_SECURITY_PATTERNS=(
    "error handling"
    "exception handling"
    "input validation"
    "sanitize"
    "validate"
    "authenticate"
    "authorize"
    "permission"
    "secure"
    "safe"
    "protected"
    "verified"
    "tested"
    "compliant"
    "standard"
    "best practice"
    "production-grade"
    "enterprise"
    "audit"
    "log"
    "monitor"
    "trace"
    "debug"
    "documentation"
    "reference"
    "vault"
)

# VARIABOT-SPECIFIC REQUIRED PATTERNS - Commands should reference these for VARIABOT compliance
VARIABOT_REQUIRED_PATTERNS=(
    "reference_vault"
    "PRODUCTION_GRADE_STANDARDS"
    "ORGANIZATION_STANDARDS"
    "comprehensive_code_audit"
    "android_rooting"
    "termux"
    "kali"
    "security"
    "compliance"
    "standards"
)

# PRODUCTION QUALITY INDICATORS - Patterns that indicate high-quality requests
PRODUCTION_QUALITY_PATTERNS=(
    "production-ready"
    "enterprise-grade"
    "scalable"
    "maintainable"
    "extensible"
    "robust"
    "reliable"
    "efficient"
    "optimized"
    "tested"
    "documented"
    "secure"
    "compliant"
    "professional"
    "industry-standard"
    "best-practices"
    "clean code"
    "SOLID principles"
    "design patterns"
    "architecture"
    "framework"
    "library"
    "module"
    "component"
    "service"
    "api"
    "interface"
    "abstraction"
    "encapsulation"
    "polymorphism"
    "inheritance"
    "composition"
    "dependency injection"
    "inversion of control"
    "separation of concerns"
    "single responsibility"
    "open-closed principle"
    "liskov substitution"
    "interface segregation"
    "dependency inversion"
)

# WARNING PATTERNS - Commands containing these trigger warnings but are not rejected
WARNING_PATTERNS=(
    "quick fix"
    "temporary"
    "hack"
    "workaround"
    "patch"
    "hotfix"
    "band-aid"
    "duct tape"
    "kludge"
    "bodge"
    "jury-rig"
    "makeshift"
    "stopgap"
    "interim"
    "placeholder"
    "todo"
    "fixme"
    "xxx"
    "deprecated"
    "legacy"
    "obsolete"
    "outdated"
    "old"
    "ancient"
    "simple"
    "basic"
    "minimal"
    "bare"
    "stripped"
    "lightweight"
    "quick and dirty"
    "rough"
    "crude"
    "primitive"
    "naive"
    "brute force"
    "hardcode"
    "hardcoded"
    "magic number"
    "copy paste"
    "duplicate"
    "repeat"
    "redundant"
    "unnecessary"
    "unused"
    "dead code"
    "commented out"
    "disable"
    "turn off"
    "bypass"
    "skip"
    "ignore"
    "suppress"
    "silence"
    "hide"
    "mask"
    "cover up"
)

# AI SYSTEM SPECIFIC REQUIREMENTS
declare -A AI_SYSTEM_REQUIREMENTS=(
    ["copilot"]="Follow GitHub Copilot best practices, include proper context, use clear variable names"
    ["gemini"]="Provide detailed context, specify output format, include examples"
    ["grok"]="Be specific about requirements, include context, specify constraints"
    ["chatgpt"]="Provide clear instructions, specify format, include examples"
    ["claude"]="Be precise, include context, specify output requirements"
    ["generic"]="Follow general AI interaction best practices"
)

# COMMAND CONTEXT DEFINITIONS
declare -A COMMAND_CONTEXTS=(
    ["standard"]="General command with standard compliance requirements"
    ["production"]="Production environment command with strict security and quality requirements"
    ["security"]="Security-focused command with enhanced validation and audit requirements"
    ["development"]="Development environment command with testing and documentation requirements"
    ["android"]="Android/rooting specific command with specialized security considerations"
    ["audit"]="Audit and compliance command with comprehensive validation requirements"
    ["emergency"]="Emergency command with relaxed validation but enhanced logging"
    ["execute"]="Command to be executed with full monitoring and audit trail"
)

# COMPLIANCE SCORING WEIGHTS
declare -A COMPLIANCE_WEIGHTS=(
    ["security_pattern_match"]=20
    ["production_quality_match"]=15
    ["variabot_specific_match"]=15
    ["proper_length"]=10
    ["context_appropriate"]=10
    ["no_warning_patterns"]=10
    ["clear_intent"]=10
    ["documentation_mentioned"]=5
    ["testing_mentioned"]=5
)

# MINIMUM COMPLIANCE SCORES BY CONTEXT
declare -A MIN_COMPLIANCE_SCORES=(
    ["standard"]=60
    ["production"]=85
    ["security"]=90
    ["development"]=70
    ["android"]=80
    ["audit"]=95
    ["emergency"]=40
    ["execute"]=75
)

# VARIABOT SPECIFIC COMMAND ENHANCEMENTS
VARIABOT_STANDARD_ENHANCEMENTS=(
    "Follow VARIABOT production-grade standards"
    "Include proper error handling (no bare except clauses)"
    "Add comprehensive logging and monitoring"
    "Include References section citing /reference_vault/"
    "Ensure security best practices (no hardcoded secrets)"
    "Validate against comprehensive_code_audit.sh requirements"
    "Follow ORGANIZATION_STANDARDS.md file organization"
    "Meet PRODUCTION_GRADE_STANDARDS.md quality requirements"
    "Include appropriate test coverage and validation"
    "Document all functions and classes properly"
    "Use VARIABOT naming conventions"
    "Implement proper dependency management"
    "Add performance monitoring where applicable"
    "Include proper configuration management"
    "Implement graceful error recovery"
    "Add comprehensive input validation"
    "Include proper resource cleanup"
    "Implement proper logging levels and formatting"
    "Add proper exception handling with specific exception types"
    "Include comprehensive documentation"
)

# ANDROID/ROOTING SPECIFIC ENHANCEMENTS
ANDROID_SPECIFIC_ENHANCEMENTS=(
    "Reference /reference_vault/linux_kali_android.md standards"
    "Include Termux compatibility considerations"
    "Implement proper privilege escalation safeguards"
    "Add Kali Linux integration where applicable"
    "Follow Android security best practices"
    "Include proper device detection and validation"
    "Implement safe rooting procedures with rollback capabilities"
    "Add comprehensive error handling for Android-specific operations"
    "Include proper permission handling for Android 10+"
    "Implement proper Magisk integration where applicable"
    "Add proper SELinux context handling"
    "Include proper Android version compatibility checks"
    "Implement proper storage access framework compliance"
    "Add proper network security configuration"
    "Include comprehensive logging for Android operations"
)

# SECURITY SPECIFIC ENHANCEMENTS
SECURITY_SPECIFIC_ENHANCEMENTS=(
    "Implement comprehensive input validation and sanitization"
    "Add proper authentication and authorization checks"
    "Include comprehensive audit logging"
    "Implement proper secret management (no hardcoded secrets)"
    "Add comprehensive security headers and configurations"
    "Include proper encryption for sensitive data"
    "Implement proper session management"
    "Add comprehensive security testing and validation"
    "Include proper rate limiting and abuse prevention"
    "Implement proper secure coding practices"
    "Add comprehensive vulnerability scanning and assessment"
    "Include proper security monitoring and alerting"
    "Implement proper incident response procedures"
    "Add comprehensive security documentation"
    "Include proper security compliance validation"
)

# Function to get AI system specific requirements
get_ai_system_requirements() {
    local ai_system="$1"
    echo "${AI_SYSTEM_REQUIREMENTS[$ai_system]:-${AI_SYSTEM_REQUIREMENTS[generic]}}"
}

# Function to get command context definition
get_command_context() {
    local context="$1"
    echo "${COMMAND_CONTEXTS[$context]:-${COMMAND_CONTEXTS[standard]}}"
}

# Function to get minimum compliance score for context
get_min_compliance_score() {
    local context="$1"
    echo "${MIN_COMPLIANCE_SCORES[$context]:-${MIN_COMPLIANCE_SCORES[standard]}}"
}

# Function to get compliance weight for criteria
get_compliance_weight() {
    local criteria="$1"
    echo "${COMPLIANCE_WEIGHTS[$criteria]:-5}"
}

# Export arrays and functions for use by main compliance script
export FORBIDDEN_PATTERNS
export REQUIRED_SECURITY_PATTERNS
export VARIABOT_REQUIRED_PATTERNS
export PRODUCTION_QUALITY_PATTERNS
export WARNING_PATTERNS
export VARIABOT_STANDARD_ENHANCEMENTS
export ANDROID_SPECIFIC_ENHANCEMENTS
export SECURITY_SPECIFIC_ENHANCEMENTS

# References:
# - Internal: /reference_vault/PRODUCTION_GRADE_STANDARDS.md#security-standards
# - Internal: /reference_vault/ORGANIZATION_STANDARDS.md#compliance-requirements
# - Internal: /reference_vault/copilot_instructions.md#ai-command-standards
# - External: OWASP Security Guidelines — https://owasp.org/
# - External: NIST Cybersecurity Framework — https://www.nist.gov/cyberframework