# VARIABOT FSM Engine

This directory contains the professional, event-driven FSM (Finite State Machine) engine for automated code audit and remediation.

## Overview

This is not a simple script. It is a persistent service that watches the filesystem for changes, triggers targeted audits, and dispatches object-oriented FSM "bots" to automatically fix any discovered issues.

## How to Run

1.  **Install Dependencies:**
    ```bash
    pip install -r fsm_engine/requirements.txt
    ```

2.  **Start the Watcher Service:**
    ```bash
    python3 -m fsm_engine.watcher
    ```

The service will now run in the foreground, monitoring for file changes in the repository. When you commit a change, it will automatically trigger the audit and remediation process. The output will be logged to `audit_results.log`.