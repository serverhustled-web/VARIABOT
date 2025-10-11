#!/bin/bash
# run_all_audits.sh - Master Orchestrator for All VARIABOT Audits
# Executes all audit scripts sequentially and provides a final summary.
set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}"
AUDIT_LOG="${REPO_ROOT}/audit_results.log"
AUDIT_FAILURE=0

# --- Colors for Output ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Main Logic ---

# Initialize the master audit log
echo -e "${BOLD}=== VARIABOT Master Audit Started: $(date) ===${NC}" > "${AUDIT_LOG}"
echo "" >> "${AUDIT_LOG}"

# Function to run an audit script and check its exit code
run_audit() {
    local script_name=$1
    echo -e "\n${BOLD}--- Running Audit: ${script_name} ---${NC}"

    # Ensure the script is executable
    if [ ! -x "${script_name}" ]; then
        echo -e "${RED}ERROR: ${script_name} is not executable. Skipping.${NC}" | tee -a "${AUDIT_LOG}"
        AUDIT_FAILURE=1
        return
    fi

    # Run the script, teeing output to the master log.
    # We use `if ! ...; then` to catch non-zero exit codes.
    if ! ./"${script_name}" 2>&1 | tee -a "${AUDIT_LOG}"; then
        echo -e "${YELLOW}WARNING: ${script_name} reported issues or failed.${NC}" | tee -a "${AUDIT_LOG}"
        AUDIT_FAILURE=1 # Mark that at least one audit has failed or has warnings.
    else
        echo -e "${GREEN}SUCCESS: ${script_name} completed with no issues.${NC}" | tee -a "${AUDIT_LOG}"
    fi

    echo "--- End of Audit: ${script_name} ---" >> "${AUDIT_LOG}"
    echo "" >> "${AUDIT_LOG}"
}

# --- Execution ---
main() {
    # List of all audit scripts to run
    local audit_scripts=(
        "comprehensive_code_audit.sh"
        "audit_web_stack.sh"
        "audit_config_files.sh"
        "audit_documentation.sh"
    )

    for script in "${audit_scripts[@]}"; do
        run_audit "${script}"
    done

    # --- Final Summary ---
    echo -e "\n${BOLD}=== MASTER AUDIT SUMMARY ===${NC}"
    echo -e "Detailed logs are available in: ${BLUE}${AUDIT_LOG}${NC}"

    if [ "${AUDIT_FAILURE}" -ne 0 ]; then
        echo -e "${RED}❌ OVERALL AUDIT STATUS: One or more audits reported issues or failed.${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ OVERALL AUDIT STATUS: All audits passed successfully.${NC}"
        exit 0
    fi
}

main "$@"