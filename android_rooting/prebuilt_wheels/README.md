# Pre-built Python Wheels for Termux/Android

**Purpose**: This directory contains pre-compiled Python wheels for ARM64 Android devices to overcome Termux compilation limitations.

## Problem Statement

Termux on Android has known issues with building complex Python packages that require native compilation, particularly:
- NumPy
- Pandas
- Scikit-learn
- TensorFlow Lite
- PyTorch Mobile
- Other packages with C/C++ extensions

Building these packages from source in Termux often fails due to:
- Limited compiler support
- Memory constraints
- Missing build dependencies
- Architecture-specific compilation issues

## Solution

Pre-built wheels eliminate compilation requirements by providing ready-to-install binary packages.

## Directory Structure

```
prebuilt_wheels/
├── arm64/              # ARM64 (aarch64) wheels for Android 13+
│   ├── numpy/
│   ├── pandas/
│   ├── scikit_learn/
│   └── ...
├── README.md           # This file
└── requirements_prebuilt.txt  # Specific versions available as wheels
```

## Usage

### Option 1: Install from Local Wheels

```bash
# Install specific package from pre-built wheel
pip install --no-index --find-links=/path/to/prebuilt_wheels/arm64 numpy

# Install all requirements using pre-built wheels
pip install --no-index --find-links=/path/to/prebuilt_wheels/arm64 -r requirements_prebuilt.txt
```

### Option 2: Priority to Local, Fallback to PyPI

```bash
# Try local wheels first, fall back to PyPI if not found
pip install --find-links=/path/to/prebuilt_wheels/arm64 numpy
```

### Option 3: Automated Installation Script

```bash
# Use provided installation script
./android_rooting/scripts/install_with_prebuilt_wheels.sh
```

## Building Wheels

If you need to build new wheels for Termux:

### On a Linux ARM64 System (Recommended)

```bash
# Install build dependencies
pip install build wheel

# Build wheel for specific package
python -m build --wheel package_name

# The wheel will be in dist/ directory
```

### Cross-compilation (Advanced)

For cross-compiling wheels from x86_64 to ARM64:

```bash
# Using cibuildwheel (requires Docker)
pip install cibuildwheel
cibuildwheel --platform linux --archs aarch64
```

## Wheel Sources

Wheels can be obtained from:
1. **Termux repositories**: `pkg install python-numpy` (then extract wheel)
2. **piwheels.org**: Pre-built wheels for ARM architectures
3. **Custom builds**: Build on actual ARM64 device or VM
4. **Community sources**: Termux package maintainers and forums

## Required Wheels for VARIABOT

Priority packages that must be pre-built:

- [ ] `numpy>=1.21.0` (ARM64)
- [ ] `pandas>=1.5.0` (ARM64)
- [ ] `Pillow>=8.0.0` (ARM64)
- [ ] `cryptography>=40.0.0` (ARM64)
- [ ] `scikit-learn` (if ML features needed)
- [ ] `torch` (mobile/lite version for ARM64)
- [ ] `tensorflow-lite` (ARM64 optimized)

## Installation in Termux

### Environment Setup

```bash
# Update Termux packages
pkg update && pkg upgrade

# Install Python and build essentials
pkg install python python-pip clang cmake ninja

# Install pre-requisites that don't need wheels
pip install --upgrade pip setuptools wheel
```

### Install with Pre-built Wheels

```bash
# Clone repository
git clone https://github.com/serverhustled-web/VARIABOT
cd VARIABOT

# Install using pre-built wheels
export WHEEL_DIR="$PWD/android_rooting/prebuilt_wheels/arm64"
pip install --find-links="$WHEEL_DIR" -r requirements.txt
```

## Verification

After installation, verify packages:

```python
import sys
import numpy as np
import pandas as pd

print(f"Python: {sys.version}")
print(f"NumPy: {np.__version__}")
print(f"Pandas: {pd.__version__}")
print(f"Architecture: {np.show_config()}")
```

## Troubleshooting

### Issue: "No matching distribution found"

**Solution**: 
1. Check architecture: `uname -m` should show `aarch64`
2. Verify Python version compatibility
3. Ensure wheel file name matches platform tags

### Issue: "Wheel is not compatible with this platform"

**Solution**:
1. Check wheel platform tag: `wheel unpack *.whl && cat */WHEEL`
2. Rename wheel if needed to match platform
3. Use `--force-reinstall` if wheel was previously installed

### Issue: "Unable to find wheel in directory"

**Solution**:
1. Verify wheel files exist: `ls -la prebuilt_wheels/arm64/`
2. Check file permissions
3. Use absolute path instead of relative

## Contributing Wheels

To contribute pre-built wheels:

1. Build wheel on ARM64 Android device or compatible system
2. Test installation in clean Termux environment
3. Verify package functionality
4. Submit wheel with metadata (Python version, Android version, build date)
5. Include checksum: `sha256sum *.whl > checksums.txt`

## Security Considerations

**IMPORTANT**: Only use wheels from trusted sources.

- Verify checksums before installation
- Build from source when possible for production use
- Keep wheels updated with latest security patches
- Document wheel provenance in `wheel_metadata.json`

## Automation

The `/android_rooting/bots/wheel_manager_bot.py` provides automated wheel management:

- Detects missing wheels
- Downloads from trusted sources
- Verifies checksums
- Installs with proper fallbacks
- Logs all operations for audit trail

## References

- Internal: `/reference_vault/linux_kali_android.md#termux-package-management`
- Internal: `/reference_vault/PRODUCTION_GRADE_STANDARDS.md#dependency-management`
- External: Python Packaging — https://packaging.python.org/
- External: Termux Wiki — https://wiki.termux.com/wiki/Python
- External: piwheels — https://www.piwheels.org/
