#!/bin/bash
#
# COMPREHENSIVE CODE AUDIT SCRIPT - VARIABOT
# Global security, quality, and compliance analysis
# 
# Usage: ./comprehensive_code_audit.sh [--verbose]

set -euo pipefail

# Configuration
SCRIPT_VERSION="1.0.0"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
AUDIT_DIR="audit_results_$(date +%Y%m%d_%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
ISSUES_FOUND=0
FILES_SCANNED=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; ((ISSUES_FOUND++)); }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; ((ISSUES_FOUND++)); }

# Setup audit directory
setup_audit() {
    log_info "Setting up audit directory: $AUDIT_DIR"
    mkdir -p "$AUDIT_DIR"/{security,quality,compliance,summary}
}

# Security audit
run_security_audit() {
    log_info "🔒 Running security audit..."
    
    # Basic security checks
    log_info "Checking for potential security issues..."
    
    # Check for hardcoded secrets
    if grep -r -i "password\|secret\|key.*=" . --exclude-dir=.git --exclude-dir=reference_vault --include="*.py" > "$AUDIT_DIR/security/potential_secrets.txt" 2>/dev/null; then
        secret_count=$(wc -l < "$AUDIT_DIR/security/potential_secrets.txt")
        log_warning "Found $secret_count potential hardcoded secrets"
    else
        log_success "No obvious hardcoded secrets found"
    fi
    
    # Check for subprocess security issues
    if grep -r "shell=True\|os.system" . --exclude-dir=.git --exclude-dir=reference_vault --include="*.py" > "$AUDIT_DIR/security/subprocess_issues.txt" 2>/dev/null; then
        subprocess_count=$(wc -l < "$AUDIT_DIR/security/subprocess_issues.txt")
        log_warning "Found $subprocess_count potential subprocess security issues"
    else
        log_success "No subprocess security issues found"
    fi
    
    # Install and run bandit if available
    if command -v pip3 &> /dev/null; then
        pip3 install bandit --quiet &>/dev/null || true
        if command -v bandit &> /dev/null; then
            log_info "Running bandit security scan..."
            bandit -r . -x reference_vault/ -f json -o "$AUDIT_DIR/security/bandit_report.json" 2>/dev/null || true
            bandit -r . -x reference_vault/ > "$AUDIT_DIR/security/bandit_summary.txt" 2>&1 || true
            log_success "Bandit scan completed"
        fi
    fi
    
    log_success "Security audit completed"
}

# Code quality audit
run_quality_audit() {
    log_info "📊 Running code quality audit..."
    
    # Count Python files
    py_files=$(find . -name "*.py" -not -path "./reference_vault/*" -not -path "./.git/*" | wc -l)
    FILES_SCANNED=$py_files
    log_info "Found $py_files Python files to analyze"
    
    # Install and run flake8 if available
    if command -v pip3 &> /dev/null; then
        pip3 install flake8 --quiet &>/dev/null || true
        if command -v flake8 &> /dev/null; then
            log_info "Running flake8 analysis..."
            flake8 . --exclude=reference_vault --count --statistics > "$AUDIT_DIR/quality/flake8_summary.txt" 2>&1 || true
            log_success "Flake8 analysis completed"
        fi
    fi
    
    # Basic syntax check
    syntax_errors=0
    for file in $(find . -name "*.py" -not -path "./reference_vault/*" -not -path "./.git/*"); do
        if ! python3 -m py_compile "$file" 2>/dev/null; then
            log_error "Syntax error in: $file"
            ((syntax_errors++))
        fi
    done
    
    if [[ $syntax_errors -eq 0 ]]; then
        log_success "All Python files have valid syntax"
    else
        log_warning "Found $syntax_errors Python files with syntax errors"
    fi
    
    log_success "Quality audit completed"
}

# Compliance audit
run_compliance_audit() {
    log_info "📋 Running compliance audit..."
    
    # Check for required files
    required_files=("README.md" "requirements.txt" ".gitignore")
    missing_files=0
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_warning "Missing required file: $file"
            ((missing_files++))
        fi
    done
    
    if [[ $missing_files -eq 0 ]]; then
        log_success "All required files present"
    fi
    
    # Check for References blocks in Python files
    files_without_refs=0
    total_py_files=0
    
    while IFS= read -r -d '' file; do
        ((total_py_files++))
        if ! grep -q "References:" "$file" 2>/dev/null; then
            ((files_without_refs++))
        fi
    done < <(find . -name "*.py" -not -path "./reference_vault/*" -not -path "./.git/*" -print0)
    
    if [[ $total_py_files -gt 0 ]]; then
        compliance_rate=$(( (total_py_files - files_without_refs) * 100 / total_py_files ))
        log_info "Reference block compliance: $compliance_rate% ($((total_py_files - files_without_refs))/$total_py_files files)"
        
        if [[ $compliance_rate -lt 50 ]]; then
            log_warning "Low compliance rate for reference blocks"
        else
            log_success "Good compliance rate for reference blocks"
        fi
    fi
    
    log_success "Compliance audit completed"
}

# Test audit
run_test_audit() {
    log_info "🧪 Running test audit..."
    
    # Check for test files
    test_files=$(find . -name "test_*.py" -not -path "./.git/*" | wc -l)
    log_info "Found $test_files test files"
    
    # Run tests if available
    if command -v python3 &> /dev/null && [[ $test_files -gt 0 ]]; then
        if command -v pytest &> /dev/null; then
            log_info "Running pytest..."
            pytest -v > "$AUDIT_DIR/summary/test_results.txt" 2>&1 && log_success "Tests passed" || log_warning "Some tests failed"
        else
            # Try running tests directly
            for test_file in $(find . -name "test_*.py" -not -path "./.git/*"); do
                if python3 "$test_file" > "$AUDIT_DIR/summary/${test_file##*/}.log" 2>&1; then
                    log_success "Test passed: $test_file"
                else
                    log_warning "Test failed: $test_file"
                fi
            done
        fi
    else
        log_info "No test framework or test files found"
    fi
    
    log_success "Test audit completed"
}

# Generate summary report
generate_summary() {
    log_info "📄 Generating audit summary..."
    
    cat > "$AUDIT_DIR/summary/audit_report.txt" << EOF
VARIABOT COMPREHENSIVE CODE AUDIT REPORT
=======================================

Generated: $TIMESTAMP
Version: $SCRIPT_VERSION
Repository: serverhustled-web/VARIABOT

AUDIT SUMMARY
=============
Files Scanned: $FILES_SCANNED
Issues Found: $ISSUES_FOUND
Audit Directory: $AUDIT_DIR

MODULES AUDITED
===============
✅ Security Analysis
✅ Code Quality Check
✅ Compliance Validation  
✅ Test Coverage Analysis

DETAILED RESULTS
================
Security: $AUDIT_DIR/security/
Quality: $AUDIT_DIR/quality/
Compliance: $AUDIT_DIR/compliance/
Summary: $AUDIT_DIR/summary/

STATUS
======
EOF

    if [[ $ISSUES_FOUND -eq 0 ]]; then
        echo "🎉 AUDIT PASSED - No critical issues found" >> "$AUDIT_DIR/summary/audit_report.txt"
        log_success "Audit completed successfully - No critical issues!"
    elif [[ $ISSUES_FOUND -lt 5 ]]; then
        echo "⚠️  AUDIT WARNING - $ISSUES_FOUND minor issues found" >> "$AUDIT_DIR/summary/audit_report.txt"
        log_warning "Audit completed with $ISSUES_FOUND minor issues"
    else
        echo "❌ AUDIT ATTENTION NEEDED - $ISSUES_FOUND issues found" >> "$AUDIT_DIR/summary/audit_report.txt"
        log_warning "Audit completed with $ISSUES_FOUND issues requiring attention"
    fi
    
    cat "$AUDIT_DIR/summary/audit_report.txt"
}

# Main execution
main() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              VARIABOT COMPREHENSIVE CODE AUDIT              ║"
    echo "║                     Version $SCRIPT_VERSION                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log_info "Starting comprehensive code audit..."
    
    # Setup
    setup_audit
    
    # Run all audits
    run_security_audit
    run_quality_audit
    run_compliance_audit
    run_test_audit
    
    # Generate summary
    generate_summary
    
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     AUDIT COMPLETE                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Exit with appropriate code
    if [[ $ISSUES_FOUND -gt 10 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"