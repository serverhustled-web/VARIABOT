#!/bin/bash
# audit_web_stack.sh - Audits HTML, CSS, JS, and TS files.
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
# Appends to a master log file, does not create its own.
log_info() { echo -e "${BLUE}[WEB-INFO]${NC} $1"; echo "[WEB-INFO] $1" >> "${AUDIT_LOG}"; }
log_warning() { echo -e "${YELLOW}[WEB-WARN]${NC} $1"; echo "[WEB-WARN] $1" >> "${AUDIT_LOG}"; ((VIOLATIONS_FOUND++)); }
log_error() { echo -e "${RED}[WEB-ERROR]${NC} $1"; echo "[WEB-ERROR] $1" >> "${AUDIT_LOG}"; ((CRITICAL_VIOLATIONS++)); }
log_success() { echo -e "${GREEN}[WEB-SUCCESS]${NC} $1"; echo "[WEB-SUCCESS] $1" >> "${AUDIT_LOG}"; }

# --- Prerequisite and Dependency Management ---
check_web_prerequisites() {
    log_info "Checking web stack audit prerequisites..."

    # Check for Node.js and npm
    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        log_error "Node.js and/or npm are not installed. They are required for this audit."
        log_error "Please install them and run the audit again."
        return 1
    fi

    # Create a package.json if it doesn't exist to manage local dependencies
    if [ ! -f "${REPO_ROOT}/package.json" ]; then
        log_warning "No package.json found. Creating a default one."
        npm init -y >/dev/null 2>&1
    fi

    # Install required npm packages if they aren't in node_modules
    local packages_to_install=()
    [ ! -d "node_modules/eslint" ] && packages_to_install+=("eslint@8")
    [ ! -d "node_modules/@typescript-eslint/parser" ] && packages_to_install+=("@typescript-eslint/parser")
    [ ! -d "node_modules/@typescript-eslint/eslint-plugin" ] && packages_to_install+=("@typescript-eslint/eslint-plugin")
    [ ! -d "node_modules/stylelint" ] && packages_to_install+=("stylelint")
    [ ! -d "node_modules/stylelint-config-standard" ] && packages_to_install+=("stylelint-config-standard")
    [ ! -d "node_modules/html-validator-cli" ] && packages_to_install+=("html-validator-cli")

    if [ ${#packages_to_install[@]} -ne 0 ]; then
        log_info "Installing required npm audit tools: ${packages_to_install[*]}"
        npm install --save-dev "${packages_to_install[@]}"
    fi

    log_success "All web stack audit prerequisites are met."
}

# --- Audit Functions ---

# Audit JavaScript and TypeScript files
audit_js_ts() {
    log_info "Auditing JavaScript and TypeScript files..."
    local files
    files=$(find . -path ./node_modules -prune -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -print)
    if [ -z "$files" ]; then
        log_info "No JavaScript or TypeScript files found."
        return
    fi

    if [ ! -f "${REPO_ROOT}/.eslintrc.json" ]; then
        log_error "Configuration file .eslintrc.json not found. Skipping JS/TS audit."
        return
    fi

    log_info "Running ESLint..."
    if ! npx eslint --ext .js,.jsx,.ts,.tsx . ; then
        log_warning "ESLint found issues. Please review the output above."
    else
        log_success "ESLint audit passed."
    fi
}

# Audit CSS files
audit_css() {
    log_info "Auditing CSS files..."
    local files
    files=$(find . -path ./node_modules -prune -o -name "*.css" -print)
    if [ -z "$files" ]; then
        log_info "No CSS files found."
        return
    fi

    if [ ! -f "${REPO_ROOT}/.stylelintrc.json" ]; then
        log_error "Configuration file .stylelintrc.json not found. Skipping CSS audit."
        return
    fi

    log_info "Running Stylelint..."
    if ! npx stylelint "**/*.css"; then
        log_warning "Stylelint found issues. Please review the output above."
    else
        log_success "Stylelint audit passed."
    fi
}

# Audit HTML files
audit_html() {
    log_info "Auditing HTML files..."
    local files
    files=$(find . -path ./node_modules -prune -o -name "*.html" -print)
    if [ -z "$files" ]; then
        log_info "No HTML files found."
        return
    fi

    log_info "Running HTML Validator..."
    # The html-validator-cli can be noisy, so we'll check its exit code.
    # We'll run it on all found files.
    npx html-validator --files $files --format=json | (
        # We use a subshell to process the JSON output
        local has_error=0
        while IFS= read -r line; do
            # Process JSON output to make it readable
            if echo "$line" | grep -q '"type": "error"'; then
                has_error=1
                local file
                file=$(echo "$line" | grep -o '"url": "[^"]*' | sed 's/"url": "//')
                local message
                message=$(echo "$line" | grep -o '"message": "[^"]*' | sed 's/"message": "//')
                log_error "HTML Validation Error in ${file}: ${message}"
            fi
        done
        if [ "$has_error" -eq 0 ]; then
            log_success "HTML validation passed for all files."
        fi
    )
}

# --- Main Execution ---
main() {
    # Initialize Log
    echo "" >> "${AUDIT_LOG}"
    log_info "--- Starting Web Stack Audit ---"

    if ! check_web_prerequisites; then
        exit 1 # Exit with critical error if setup fails
    fi

    audit_js_ts
    audit_css
    audit_html

    log_info "--- Web Stack Audit Finished ---"

    # Exit with a code that the main orchestrator can interpret.
    # For this script, we'll consider all findings as "warnings" for simplicity.
    if [ "${VIOLATIONS_FOUND}" -gt 0 ] || [ "${CRITICAL_VIOLATIONS}" -gt 0 ]; then
        exit 2 # Non-critical warnings, as the script will log them.
    else
        log_success "Web stack audit passed with no violations."
        exit 0 # Success
    fi
}

# Run the audit only if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi