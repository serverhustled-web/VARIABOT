#!/bin/bash
# Gemini CLI Integration Demonstration for VARIABOT
# Shows comprehensive AGI-enhanced capabilities

set -euo pipefail

echo "🚀 VARIABOT Gemini CLI Integration Demo"
echo "======================================"

# Check for integration files
FILES_TO_CHECK=(
    "User-Admin-Command_Compliant-AGI.tar.gz"
    "Contents-x86_64.gz" 
    "drive.v3.json"
    "sudo.sh"
)

echo "📁 Checking for integration files..."
for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Found: $file"
    else
        echo "⚠️  Missing: $file (will use demo data)"
    fi
done

# Run integration components
echo -e "\n🔧 Running Gemini CLI Configuration..."
python3 gemini_cli_integration.py --configure

echo -e "\n📊 Running AGI-Enhanced Analysis..."
python3 gemini_cli_integration.py --analyze

echo -e "\n🔐 Running Admin Compliance Integration..."
bash advanced_integrations/gemini_cli/admin_compliance_integration.sh

echo -e "\n📦 Processing System Contents..."
python3 advanced_integrations/gemini_cli/contents_processor.py

echo -e "\n✅ Gemini CLI Integration Demo Completed!"
echo "Results available in: advanced_integrations/gemini_cli/"
