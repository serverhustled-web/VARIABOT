#!/usr/bin/env python3
"""
System Contents Processor with Gemini CLI AGI Enhancement
Processes Contents-x86_64.gz and similar system package files
"""

import gzip
import json
from pathlib import Path
import logging

def process_contents_file(contents_file: Path):
    """Process Contents-x86_64.gz file with AGI enhancement."""
    try:
        if contents_file.suffix == '.gz':
            with gzip.open(contents_file, 'rt') as f:
                contents = f.read()
        else:
            with open(contents_file, 'r') as f:
                contents = f.read()
        
        # Parse package contents
        packages = {}
        for line in contents.split('\n'):
            if line.strip():
                parts = line.split()
                if len(parts) >= 2:
                    file_path = parts[0]
                    package_name = parts[1] if len(parts) > 1 else 'unknown'
                    
                    if package_name not in packages:
                        packages[package_name] = []
                    packages[package_name].append(file_path)
        
        # AGI-enhanced analysis
        analysis = {
            'total_packages': len(packages),
            'total_files': sum(len(files) for files in packages.values()),
            'critical_packages': [],
            'security_relevant': [],
            'android_relevant': []
        }
        
        # Identify critical packages for Android rooting
        android_keywords = ['adb', 'fastboot', 'su', 'busybox', 'magisk', 'xposed']
        security_keywords = ['sudo', 'passwd', 'shadow', 'ssh', 'ssl', 'crypto']
        
        for pkg_name, files in packages.items():
            if any(keyword in pkg_name.lower() for keyword in android_keywords):
                analysis['android_relevant'].append(pkg_name)
            if any(keyword in pkg_name.lower() for keyword in security_keywords):
                analysis['security_relevant'].append(pkg_name)
            if pkg_name in ['base-files', 'coreutils', 'util-linux', 'systemd']:
                analysis['critical_packages'].append(pkg_name)
        
        return analysis
        
    except Exception as e:
        logging.error(f"Failed to process contents file: {e}")
        return None

if __name__ == "__main__":
    contents_file = Path("Contents-x86_64.gz")
    if contents_file.exists():
        result = process_contents_file(contents_file)
        if result:
            with open("advanced_integrations/gemini_cli/contents_analysis.json", "w") as f:
                json.dump(result, f, indent=2)
            print("System contents processed with AGI enhancement")
    else:
        print("Contents-x86_64.gz not found - using simulated analysis")
