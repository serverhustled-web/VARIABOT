#!/bin/bash
# audit_config_files.sh - Audits YAML and JSON configuration files.
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
log_info() { echo -e "${BLUE}[CONF-INFO]${NC} $1"; echo "[CONF-INFO] $1" >> "${AUDIT_LOG}"; }
log_warning() { echo -e "${YELLOW}[CONF-WARN]${NC} $1"; echo "[CONF-WARN] $1" >> "${AUDIT_LOG}"; ((VIOLATIONS_FOUND++)); }
log_error() { echo -e "${RED}[CONF-ERROR]${NC} $1"; echo "[CONF-ERROR] $1" >> "${AUDIT_LOG}"; ((CRITICAL_VIOLATIONS++)); }
log_success() { echo -e "${GREEN}[CONF-SUCCESS]${NC} $1"; echo "[CONF-SUCCESS] $1" >> "${AUDIT_LOG}"; }

# --- Prerequisite Checks ---
check_config_prerequisites() {
    log_info "Checking config audit prerequisites..."
    local missing_tools=()
    command -v yamllint >/dev/null 2>&1 || missing_tools+=("yamllint")

    # JSONLint is an npm package, so we need node/npm.
    command -v npm >/dev/null 2>&1 || missing_tools+=("npm")

    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing prerequisites: ${missing_tools[*]}. Please install them."
        return 1
    fi

    # Install jsonlint globally if not available
    if ! command -v jsonlint >/dev/null 2>&1; then
        log_warning "jsonlint not found. Attempting to install globally via npm..."
        sudo npm install -g jsonlint
    fi

    # Final check
    command -v yamllint >/dev/null 2>&1 || { log_error "yamllint installation failed. It can often be installed with 'pip install yamllint'."; return 1; }
    command -v jsonlint >/dev/null 2>&1 || { log_error "jsonlint installation failed."; return 1; }
    log_success "Config audit prerequisites are met."
}

# --- Audit Functions ---

# Audit YAML files
audit_yaml() {
    log_info "Auditing YAML files (*.yml, *.yaml)..."
    local files
    files=$(find . -path ./node_modules -prune -o -name "*.yml" -o -name "*.yaml" -print)
    if [ -z "$files" ]; then
        log_info "No YAML files found."
        return
    fi

    log_info "Running yamllint..."
    if ! yamllint -f colored .; then
        log_warning "yamllint found issues. Please review the output above."
    else
        log_success "yamllint audit passed."
    fi
}

# Audit JSON files
audit_json() {
    log_info "Auditing JSON files (*.json)..."
    local files
    # Exclude node_modules and other irrelevant paths
    files=$(find . -path ./node_modules -prune -o -name "*.json" -print)
    if [ -z "$files" ]; then
        log_info "No JSON files found."
        return
    fi

    log_info "Running jsonlint for syntax and style validation..."
    local has_error=0
    for file in $files; do
        # Skip package-lock.json as it is auto-generated and can be noisy
        if [ "$(basename "$file")" == "package-lock.json" ]; then
            log_info "Skipping package-lock.json"
            continue
        fi

        if ! jsonlint -q "$file"; then
            log_error "JSON linting failed for: $file. See errors above."
            has_error=1
        fi
    done

    if [ "$has_error" -eq 0 ]; then
        log_success "All JSON files passed linting."
    else
        log_warning "JSON linting found issues. Please review the output."
    fi
}

# --- Main Execution ---
main() {
    echo "" >> "${AUDIT_LOG}"
    log_info "--- Starting Config File Audit ---"

    if ! check_config_prerequisites; then
        exit 1
    fi

    audit_yaml
    audit_json

    log_info "--- Config File Audit Finished ---"

    if [ "${VIOLATIONS_FOUND}" -gt 0 ] || [ "${CRITICAL_VIOLATIONS}" -gt 0 ]; then
        exit 2
    else
        log_success "Config file audit passed with no violations."
        exit 0
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi