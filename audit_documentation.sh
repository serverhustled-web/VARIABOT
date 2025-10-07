#!/bin/bash
# audit_documentation.sh - Audits Markdown files for standards and quality.
set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}"
AUDIT_LOG="${REPO_ROOT}/audit_results.log"
VIOLATIONS_FOUND=0
CRITICAL_VIOLATIONS=0

# --- Colors for Output ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Logging ---
log_info() { echo -e "${BLUE}[DOC-INFO]${NC} $1"; echo "[DOC-INFO] $1" >> "${AUDIT_LOG}"; }
log_warning() { echo -e "${YELLOW}[DOC-WARN]${NC} $1"; echo "[DOC-WARN] $1" >> "${AUDIT_LOG}"; ((VIOLATIONS_FOUND++)); }
log_error() { echo -e "${RED}[DOC-ERROR]${NC} $1"; echo "[DOC-ERROR] $1" >> "${AUDIT_LOG}"; ((CRITICAL_VIOLATIONS++)); }
log_success() { echo -e "${GREEN}[DOC-SUCCESS]${NC} $1"; echo "[DOC-SUCCESS] $1" >> "${AUDIT_LOG}"; }

# --- Prerequisite Checks ---
check_doc_prerequisites() {
    log_info "Checking documentation audit prerequisites..."

    # Check for Node.js and npm (markdownlint-cli is an npm package)
    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        log_error "Node.js and/or npm are not installed. They are required for markdownlint-cli."
        return 1
    fi

    # Install markdownlint-cli if not present
    if ! npm list markdownlint-cli >/dev/null 2>&1; then
        log_info "Installing markdownlint-cli..."
        npm install --save-dev markdownlint-cli
    fi

    log_success "Documentation audit prerequisites are met."
}

# --- Audit Functions ---
audit_markdown_files() {
    log_info "Auditing Markdown files (*.md)..."
    local files
    files=$(find . -path ./node_modules -prune -o -name "*.md" -print)
    if [ -z "$files" ]; then
        log_info "No Markdown files found."
        return
    fi

    # 1. Linting with markdownlint
    log_info "Running markdownlint..."
    if ! npx markdownlint --config .markdownlint.json $files; then
        log_warning "markdownlint found issues. Please review the output above."
    else
        log_success "markdownlint audit passed."
    fi

    # 2. Project-specific standards check
    log_info "Checking for project-specific standards (e.g., 'References:' section)..."
    for file in $files; do
        # Check for References section, ignore if it's a file in the vault itself to avoid redundancy
        if ! grep -q -i "References:" "$file"; then
            log_warning "Missing 'References:' section in: $file"
        fi

        # Check for vault citations in non-vault files
        if [[ "$file" != *"reference_vault"* ]] && ! grep -q "reference_vault" "$file"; then
            log_warning "File outside 'reference_vault' is missing a citation to the vault: $file"
        fi
    done
}

# --- Main Execution ---
main() {
    echo "" >> "${AUDIT_LOG}"
    log_info "--- Starting Documentation Audit ---"

    if ! check_doc_prerequisites; then
        exit 1
    fi

    audit_markdown_files

    log_info "--- Documentation Audit Finished ---"

    if [ "${VIOLATIONS_FOUND}" -gt 0 ] || [ "${CRITICAL_VIOLATIONS}" -gt 0 ]; then
        exit 2
    else
        log_success "Documentation audit passed with no violations."
        exit 0
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi