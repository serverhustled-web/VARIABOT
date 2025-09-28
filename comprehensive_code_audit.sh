#!/bin/bash
# comprehensive_code_audit.sh - VARIABOT Global Code Audit Tool
# Enforces production-grade standards across the entire repository
set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}"
AUDIT_LOG="${REPO_ROOT}/audit_results.log"
VIOLATIONS_FOUND=0
CRITICAL_VIOLATIONS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize audit log
echo "=== VARIABOT Comprehensive Code Audit ===" > "${AUDIT_LOG}"
echo "Audit Date: $(date)" >> "${AUDIT_LOG}"
echo "Repository: ${REPO_ROOT}" >> "${AUDIT_LOG}"
echo "" >> "${AUDIT_LOG}"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[INFO] $1" >> "${AUDIT_LOG}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[WARNING] $1" >> "${AUDIT_LOG}"
    ((VIOLATIONS_FOUND++))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $1" >> "${AUDIT_LOG}"
    ((VIOLATIONS_FOUND++))
    ((CRITICAL_VIOLATIONS++))
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[SUCCESS] $1" >> "${AUDIT_LOG}"
}

# Check if required tools are installed
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_tools=()
    
    command -v python3 >/dev/null 2>&1 || missing_tools+=("python3")
    command -v shellcheck >/dev/null 2>&1 || missing_tools+=("shellcheck")
    command -v find >/dev/null 2>&1 || missing_tools+=("find")
    command -v grep >/dev/null 2>&1 || missing_tools+=("grep")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Installing missing tools..."
        
        # Try to install missing tools
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y "${missing_tools[@]}"
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y "${missing_tools[@]}"
        elif command -v brew >/dev/null 2>&1; then
            brew install "${missing_tools[@]}"
        else
            log_error "Cannot install missing tools automatically. Please install: ${missing_tools[*]}"
            return 1
        fi
    fi
    
    log_success "Prerequisites check passed"
}

# Audit file structure and organization
audit_file_structure() {
    log_info "Auditing file structure compliance..."
    
    # Check for required directories from ORGANIZATION_STANDARDS.md
    local required_dirs=("reference_vault" "android_rooting")
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "${REPO_ROOT}/${dir}" ]; then
            log_error "Missing required directory: ${dir}"
        else
            log_success "Required directory exists: ${dir}"
        fi
    done
    
    # Check for required reference vault files
    local vault_files=(
        "reference_vault/PRODUCTION_GRADE_STANDARDS.md"
        "reference_vault/ORGANIZATION_STANDARDS.md"
        "reference_vault/copilot_instructions.md"
        "reference_vault/audit_trail.md"
    )
    
    for file in "${vault_files[@]}"; do
        if [ ! -f "${REPO_ROOT}/${file}" ]; then
            log_warning "Missing reference vault file: ${file}"
        else
            log_success "Reference vault file exists: ${file}"
        fi
    done
    
    # Check for proper .gitignore
    if [ ! -f "${REPO_ROOT}/.gitignore" ]; then
        log_warning "Missing .gitignore file"
    else
        log_success ".gitignore file exists"
    fi
}

# Audit Python files for code quality
audit_python_files() {
    log_info "Auditing Python files for code quality..."
    
    find "${REPO_ROOT}" -name "*.py" -type f | while IFS= read -r pyfile; do
        log_info "Checking Python file: ${pyfile}"
        
        # Check syntax
        if ! python3 -m py_compile "${pyfile}" 2>/dev/null; then
            log_error "Python syntax error in: ${pyfile}"
            continue
        fi
        
        # Check for hardcoded secrets/tokens
        if grep -q -E "(token|key|password|secret)\s*=\s*['\"][^'\"]*['\"]" "${pyfile}"; then
            log_error "Potential hardcoded secrets found in: ${pyfile}"
        fi
        
        # Check for proper imports
        if grep -q "^import \*" "${pyfile}"; then
            log_warning "Wildcard imports found in: ${pyfile}"
        fi
        
        # Check for error handling patterns
        if grep -q "except:" "${pyfile}" && ! grep -q "except Exception:" "${pyfile}"; then
            log_warning "Bare except clauses found in: ${pyfile}"
        fi
        
        # Check for References section
        if ! grep -q "References:" "${pyfile}"; then
            log_warning "Missing References section in: ${pyfile}"
        fi
        
        # Check for vault citations
        if ! grep -q "reference_vault" "${pyfile}"; then
            log_warning "No reference vault citations in: ${pyfile}"
        fi
        
        log_success "Python file audit completed: ${pyfile}"
    done
}

# Audit shell scripts
audit_shell_scripts() {
    log_info "Auditing shell scripts..."
    
    find "${REPO_ROOT}" -name "*.sh" -type f | while IFS= read -r script; do
        log_info "Checking shell script: ${script}"
        
        # Check for proper shebang
        if ! head -1 "${script}" | grep -q "^#!/"; then
            log_error "Missing shebang in: ${script}"
        fi
        
        # Check for set -euo pipefail
        if ! grep -q "set -euo pipefail" "${script}"; then
            log_warning "Missing 'set -euo pipefail' in: ${script}"
        fi
        
        # Run shellcheck if available
        if command -v shellcheck >/dev/null 2>&1; then
            if ! shellcheck "${script}" >/dev/null 2>&1; then
                log_warning "ShellCheck issues found in: ${script}"
            fi
        fi
        
        # Check for References section
        if ! grep -q "References:" "${script}"; then
            log_warning "Missing References section in: ${script}"
        fi
        
        log_success "Shell script audit completed: ${script}"
    done
}

# Audit documentation files
audit_documentation() {
    log_info "Auditing documentation files..."
    
    find "${REPO_ROOT}" -name "*.md" -type f | while IFS= read -r mdfile; do
        log_info "Checking documentation file: ${mdfile}"
        
        # Check for table of contents in large files
        local line_count=$(wc -l < "${mdfile}")
        if [ "${line_count}" -gt 100 ] && ! grep -q "Table of Contents\|TOC" "${mdfile}"; then
            log_warning "Large documentation file missing Table of Contents: ${mdfile}"
        fi
        
        # Check for References section
        if ! grep -q "References:" "${mdfile}"; then
            log_warning "Missing References section in: ${mdfile}"
        fi
        
        # Check for vault citations in non-vault files
        if [[ "${mdfile}" != *"reference_vault"* ]] && ! grep -q "reference_vault" "${mdfile}"; then
            log_warning "No reference vault citations in: ${mdfile}"
        fi
        
        log_success "Documentation audit completed: ${mdfile}"
    done
}

# Audit security compliance
audit_security() {
    log_info "Auditing security compliance..."
    
    # Check for exposed secrets in common files
    local sensitive_files=(
        ".env"
        ".env.local" 
        "config.json"
        "secrets.json"
    )
    
    for file in "${sensitive_files[@]}"; do
        if [ -f "${REPO_ROOT}/${file}" ]; then
            log_warning "Sensitive configuration file found: ${file}"
        fi
    done
    
    # Check for API keys in all text files
    find "${REPO_ROOT}" -type f \( -name "*.py" -o -name "*.sh" -o -name "*.md" -o -name "*.txt" -o -name "*.json" \) \
        -exec grep -l -E "(api_key|secret_key|password|token).*[=:]\s*['\"][a-zA-Z0-9_-]{20,}" {} \; | while IFS= read -r file; do
        log_error "Potential exposed API key/secret in: ${file}"
    done
    
    # Check for proper .gitignore entries
    if [ -f "${REPO_ROOT}/.gitignore" ]; then
        local gitignore_patterns=(".env" "*.log" "__pycache__" ".DS_Store" "node_modules")
        for pattern in "${gitignore_patterns[@]}"; do
            if ! grep -q "${pattern}" "${REPO_ROOT}/.gitignore"; then
                log_warning "Missing .gitignore pattern: ${pattern}"
            fi
        done
    fi
}

# Audit Android rooting specific compliance
audit_android_rooting() {
    log_info "Auditing Android rooting module compliance..."
    
    local android_dir="${REPO_ROOT}/android_rooting"
    if [ ! -d "${android_dir}" ]; then
        log_error "Android rooting directory not found"
        return
    fi
    
    # Check for required subdirectories
    local required_subdirs=("bots" "core" "scripts" "utils")
    for subdir in "${required_subdirs[@]}"; do
        if [ ! -d "${android_dir}/${subdir}" ]; then
            log_warning "Missing android_rooting subdirectory: ${subdir}"
        fi
    done
    
    # Check for bot framework files
    if [ -d "${android_dir}/bots" ]; then
        find "${android_dir}/bots" -name "*.py" -type f | while IFS= read -r bot_file; do
            # Check for proper error handling
            if ! grep -q "try:" "${bot_file}" || ! grep -q "except" "${bot_file}"; then
                log_warning "Bot file missing proper error handling: ${bot_file}"
            fi
            
            # Check for logging
            if ! grep -q "log" "${bot_file}"; then
                log_warning "Bot file missing logging: ${bot_file}"
            fi
        done
    fi
    
    # Check for Kali Linux integration as mentioned in standards
    if ! find "${android_dir}" -name "*.py" -o -name "*.sh" | xargs grep -l -i "kali\|chroot" >/dev/null 2>&1; then
        log_warning "Missing Kali Linux integration references in android_rooting"
    fi
}

# Generate audit report
generate_report() {
    log_info "Generating final audit report..."
    
    echo "" >> "${AUDIT_LOG}"
    echo "=== AUDIT SUMMARY ===" >> "${AUDIT_LOG}"
    echo "Total violations found: ${VIOLATIONS_FOUND}" >> "${AUDIT_LOG}"
    echo "Critical violations: ${CRITICAL_VIOLATIONS}" >> "${AUDIT_LOG}"
    echo "Audit completed at: $(date)" >> "${AUDIT_LOG}"
    
    if [ "${CRITICAL_VIOLATIONS}" -gt 0 ]; then
        log_error "AUDIT FAILED: ${CRITICAL_VIOLATIONS} critical violations found"
        log_error "Review ${AUDIT_LOG} for detailed results"
        return 1
    elif [ "${VIOLATIONS_FOUND}" -gt 0 ]; then
        log_warning "AUDIT WARNING: ${VIOLATIONS_FOUND} violations found"
        log_warning "Review ${AUDIT_LOG} for detailed results"
        return 2
    else
        log_success "AUDIT PASSED: No violations found"
        log_success "Full report available in ${AUDIT_LOG}"
        return 0
    fi
}

# Main audit execution
main() {
    log_info "Starting comprehensive code audit for VARIABOT repository"
    log_info "Repository root: ${REPO_ROOT}"
    
    # Run all audit checks
    check_prerequisites || exit 1
    audit_file_structure
    audit_python_files
    audit_shell_scripts
    audit_documentation
    audit_security
    audit_android_rooting
    
    # Generate final report
    generate_report
    local exit_code=$?
    
    # Display results summary
    echo ""
    echo "=== AUDIT RESULTS SUMMARY ==="
    echo "Total violations: ${VIOLATIONS_FOUND}"
    echo "Critical violations: ${CRITICAL_VIOLATIONS}"
    echo "Detailed log: ${AUDIT_LOG}"
    echo ""
    
    if [ "${exit_code}" -eq 0 ]; then
        echo -e "${GREEN}✅ AUDIT PASSED${NC}"
    elif [ "${exit_code}" -eq 2 ]; then
        echo -e "${YELLOW}⚠️  AUDIT WARNING${NC}"
    else
        echo -e "${RED}❌ AUDIT FAILED${NC}"
    fi
    
    exit "${exit_code}"
}

# Run the audit
main "$@"

# References:
# - Internal: /reference_vault/PRODUCTION_GRADE_STANDARDS.md#code-quality
# - Internal: /reference_vault/ORGANIZATION_STANDARDS.md#file-organization
# - Internal: /reference_vault/audit_trail.md#change-management
# - External: ShellCheck — https://www.shellcheck.net/
# - External: Python Style Guide — https://pep8.org/