# AGENTS.md

This file describes the agents and tools in the VARIABOT codebase. It helps Jules AI and other contributors understand the autonomous systems, their purposes, and how to interact with them.

## Overview

VARIABOT is a comprehensive multi-purpose framework combining AI chatbot capabilities with production-grade Android rooting tools and live bot integration. The primary goal is Android 13 ARM64 tablet rooting completion with Kali Linux integration.

## Agent Architecture

### Agentic Rooting System (The "Agentic-Matrix")

An autonomous, multi-agent system designed to achieve root access on Android devices with minimal human intervention.

#### Key Concepts

- **The Agentic Wheel**: An automated rooting process that continuously adapts and mutates its strategy, cycling through tens of thousands of tool and parameter combinations until it finds a successful exploit chain.
- **Living Code**: Agents are capable of self-mutation and adaptation to overcome obstacles in real-time.
- **Endless Adaptation**: Agents persist and adapt continuously until the goal is achieved, never silently failing.

## Core Agents

### 1. Error Variable Adaptor Bot

**Location**: `android_rooting/bots/error_bot.py`

**Purpose**: Real-time error monitoring, adaptation, and obstacle overcoming for Android rooting operations.

**Key Features**:
- Live error detection and classification
- Adaptive error handling strategies
- GitHub integration for audit trails
- Endless adaptation capability
- Multiple adaptation strategies (privilege escalation, alternative methods, environment modification, system repair, fallback execution)

**Input Conventions**:
- Monitors system errors and exceptions in real-time
- Receives error events with severity classification
- Accepts adaptation strategy configurations

**Output Conventions**:
- Structured error events with timestamps
- Adaptation actions and results
- GitHub audit logs
- Recovery status and metrics

**Interaction Methods**:
```python
from android_rooting.bots.error_bot import ErrorAdaptorBot

bot = ErrorAdaptorBot()
bot.start_monitoring()
# Bot runs continuously, adapting to errors
```

### 2. Error Handler Bot

**Location**: `android_rooting/bots/error_handler_bot.py`

**Purpose**: Complementary error handling system with specialized recovery mechanisms.

**Key Features**:
- Structured error categorization
- Recovery workflow orchestration
- Integration with core rooting modules

**Input Conventions**:
- Error events from rooting operations
- System state information
- Recovery strategy preferences

**Output Conventions**:
- Recovery actions executed
- Success/failure status
- Detailed error reports

### 3. Kali Adaptation Bot

**Location**: `android_rooting/bots/kali_adapt_bot.py`

**Purpose**: Live error adaptation and root persistence bot with Kali Linux chroot integration.

**Key Features**:
- Real-time monitoring of rooting processes
- Kali Linux chroot integration
- GitHub-driven live code updates
- Endless persistence until root success
- Advanced reconnaissance using tools like `nmap`, `tshark`, and `hydra`

**Input Conventions**:
- System status monitoring data
- Kali chroot environment state
- Root detection results

**Output Conventions**:
- Adaptation status updates (INITIALIZING, MONITORING, ADAPTING, ESCALATING, SUCCESS, PAUSED, ERROR)
- Root status reports (NO_ROOT, PARTIAL_ROOT, FULL_ROOT, UNKNOWN)
- Audit logs and metrics

**Interaction Methods**:
```python
from android_rooting.bots.kali_adapt_bot import KaliAdaptBot

bot = KaliAdaptBot()
bot.initialize()
bot.start_monitoring()
# Bot adapts continuously until root achieved
```

## Core Tools and Modules

### Root Detection System

**Location**: `android_rooting/core/root_detector.py`

**Purpose**: Multi-method root detection and verification.

**Methods**:
- Binary detection (su, busybox)
- Package analysis
- Property inspection
- SELinux status checking

### Magisk Integration

**Location**: `android_rooting/core/magisk_manager.py`

**Purpose**: Complete Magisk management and installation support.

**Features**:
- Magisk installation and updates
- Module management
- Root hiding capabilities

### Android Penetration Testing Framework

**Location**: `android_rooting/core/android_pentest.py`

**Purpose**: Comprehensive security testing and analysis framework.

**Tools Available**:
- APK analysis (aapt, dex2jar, jadx, apktool)
- Dynamic analysis (objection, frida, drozer)
- Security scanning (mobsf, qark)
- Device connection and package extraction

**Usage**:
```bash
# Device information
python -m android_rooting.core.android_pentest device-info

# Extract APK
python -m android_rooting.core.android_pentest extract-apk --package com.example.app

# Static analysis
python -m android_rooting.core.android_pentest static-analysis --apk app.apk

# Full penetration test
python -m android_rooting.core.android_pentest full-pentest --package com.example.app
```

### Kali Linux Integration

**Location**: `android_rooting/core/kali_integration.py`

**Purpose**: Kali Linux chroot integration for advanced exploitation.

**Features**:
- Chroot environment setup
- Tool installation and management
- NetHunter integration
- Advanced penetration testing capabilities

## AI Chatbot Agents

### Qwen 1.5-110B Chat

**Location**: `Qwen110BChat.py`, `st-Qwen1.5-110B-Chat.py`

**Purpose**: Large language model interface for conversational AI.

**Usage**:
```bash
# Terminal interface
python Qwen110BChat.py

# Web interface
streamlit run st-Qwen1.5-110B-Chat.py
```

### Additional AI Models

- **Qwen 1.5-MoE-A2.7B-Chat** (`st_Qwen1_5_MoE_A2_7B_Chat.py`): Mixture of experts model
- **Phi-3-Mini-128k** (`st_Phi3Mini_128k_Chat.py`): Microsoft's compact model
- **OpenELM-3B** (`st_Openelm_3B.py`): Apple's efficient language model
- **TinyLlama Chat** (`st_tinyllama_chat.py`): Lightweight chat model
- **CodeT5 Small** (`st_codet5_small.py`): Code generation model

## Utility Modules

### GitHub Integration

**Location**: `android_rooting/utils/github_integration.py`

**Purpose**: Live code updates and audit trail logging to GitHub.

**Features**:
- Automated audit logging
- Live code building and updates
- Change tracking and compliance

### Android System Utilities

**Location**: `android_rooting/utils/android_utils.py`

**Purpose**: Android system information and utility functions.

**Features**:
- System information gathering
- Environment detection
- Compatibility checks

### Termux Compatibility

**Location**: `android_rooting/utils/termux_compat.py`

**Purpose**: Termux environment compatibility and optimization.

**Features**:
- Environment detection
- Path mapping
- Permission handling
- Termux-specific optimizations

## Scripts and Automation

### Android Root Complete

**Location**: `android_rooting/scripts/android_root_complete.sh`

**Purpose**: Main rooting completion script with automated workflow.

### Termux Setup

**Location**: `android_rooting/scripts/termux_setup.sh`

**Purpose**: Complete Termux environment initialization and dependency installation.

### Kali Chroot Setup

**Location**: `android_rooting/scripts/kali_chroot_setup.sh`

**Purpose**: Kali Linux chroot initialization for advanced exploitation.

## Agent Interaction Patterns

### General Pattern

1. **Initialization**: Agent loads configuration and checks environment
2. **Monitoring**: Agent observes system state and operations
3. **Detection**: Agent identifies errors, obstacles, or opportunities
4. **Adaptation**: Agent selects and executes adaptation strategies
5. **Recovery**: Agent attempts recovery and continues monitoring
6. **Persistence**: Agent loops until goal achieved or explicitly stopped

### Error Handling Convention

All agents follow the endless adaptation principle:
- Never silently swallow errors
- Always record errors in structured format
- Continuously mutate strategy until goal achieved
- Provide audit trail through logging and GitHub integration

### Logging Standards

Agents use structured logging with consistent levels:
- **TRACE**: Detailed execution flow
- **DEBUG**: Diagnostic information
- **INFO**: Normal operation events
- **WARN**: Potential issues requiring attention
- **ERROR**: Errors requiring adaptation

### Communication Protocols

- **Internal**: Python module imports and function calls
- **External**: Subprocess execution for system commands
- **Audit**: GitHub API for change tracking
- **Monitoring**: File-based logging and real-time metrics

## Environment Requirements

### System Requirements
- **Android**: 10+ (ARM64 recommended)
- **Termux**: Latest version from F-Droid
- **Python**: 3.7+
- **Storage**: 2GB+ free space

### Optional Enhancements
- **Kali Linux**: For advanced penetration testing
- **Root Access**: For full functionality
- **Network Access**: For GitHub integration and updates

## Getting Started with Agents

### Quick Start

```bash
# Clone repository
git clone https://github.com/serverhustled-web/VARIABOT.git
cd VARIABOT

# Install dependencies
pip install -r requirements.txt

# Start error monitoring bot
python -m android_rooting.bots.error_bot --daemon

# Launch Kali adaptation bot
python -m android_rooting.bots.kali_adapt_bot

# Run Android penetration test
python -m android_rooting.core.android_pentest device-info
```

### Advanced Usage

For complex rooting scenarios, combine multiple agents:

```python
from android_rooting.bots.error_bot import ErrorAdaptorBot
from android_rooting.bots.kali_adapt_bot import KaliAdaptBot
from android_rooting.core.root_detector import RootDetector

# Initialize agents
error_bot = ErrorAdaptorBot()
kali_bot = KaliAdaptBot()
detector = RootDetector()

# Start monitoring
error_bot.start_monitoring()
kali_bot.start_monitoring()

# Check root status
status = detector.check_root_status()
print(f"Root Status: {status}")
```

## Contributing to Agents

### Development Guidelines

- **Code Quality**: 100% functional, production-ready code only
- **Testing**: Comprehensive coverage required
- **Documentation**: End-of-file References blocks required
- **Security**: Provide exploit payloads when requested
- **Error Handling**: Endless adaptation until goal achieved

### Adding New Agents

1. Create agent file in `android_rooting/bots/`
2. Implement core agent interface
3. Add monitoring and adaptation logic
4. Integrate with error handling system
5. Add tests and documentation
6. Update this AGENTS.md file

## References

- Internal: `/reference_vault/copilot_instructions.md` - AI behavior guidelines
- Internal: `/reference_vault/ORGANIZATION_STANDARDS.md` - Repository structure
- Internal: `/reference_vault/PRODUCTION_GRADE_STANDARDS.md` - Code quality standards
- Internal: `/reference_vault/linux_kali_android.md` - Platform specifics
- Internal: `README-OLD.md` - Project overview and features
- Internal: `organization_instructions.md` - Contribution workflow

## Tips for Jules AI

- **Keep AGENTS.md up to date**: Update this file when adding or modifying agents
- **Follow agent patterns**: New agents should follow the established interaction patterns
- **Use structured error handling**: All agents use the ErrorAdaptorBot patterns
- **Respect the endless adaptation principle**: Agents never give up until goal achieved
- **Maintain audit trails**: All significant actions should be logged for compliance
- **Test in Termux environment**: Agents are optimized for Android/Termux deployment

---

**Document Version**: 1.0.0  
**Last Updated**: 2025-01-XX  
**Maintained By**: VARIABOT Development Team
