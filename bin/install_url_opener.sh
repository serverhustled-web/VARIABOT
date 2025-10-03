#!/data/data/com.termux/files/usr/bin/bash
# Install VARIABOT Termux URL Opener
# Automated installation script for termux-url-opener

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}VARIABOT Termux URL Opener Installation${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if running in Termux
if [ -z "${TERMUX_VERSION:-}" ]; then
    echo -e "${RED}ERROR: This script must be run in Termux${NC}"
    exit 1
fi

TERMUX_HOME="${TERMUX__HOME:-/data/data/com.termux/files/home}"
BIN_DIR="$TERMUX_HOME/bin"
VARIABOT_DIR="$TERMUX_HOME/VARIABOT"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Installation Details:${NC}"
echo -e "  Termux Home: $TERMUX_HOME"
echo -e "  Bin Directory: $BIN_DIR"
echo -e "  VARIABOT Directory: $VARIABOT_DIR"
echo ""

# Create bin directory if it doesn't exist
if [ ! -d "$BIN_DIR" ]; then
    echo -e "${YELLOW}Creating bin directory...${NC}"
    mkdir -p "$BIN_DIR"
    echo -e "${GREEN}✓ Bin directory created${NC}"
else
    echo -e "${GREEN}✓ Bin directory exists${NC}"
fi

# Copy termux-url-opener to bin directory
echo -e "${YELLOW}Installing termux-url-opener...${NC}"
if [ -f "$SCRIPT_DIR/termux-url-opener" ]; then
    cp "$SCRIPT_DIR/termux-url-opener" "$BIN_DIR/termux-url-opener"
    chmod +x "$BIN_DIR/termux-url-opener"
    echo -e "${GREEN}✓ termux-url-opener installed${NC}"
else
    echo -e "${RED}ERROR: termux-url-opener not found in $SCRIPT_DIR${NC}"
    echo -e "${YELLOW}Make sure you're running this from the VARIABOT/bin directory${NC}"
    exit 1
fi

# Create VARIABOT directories
echo -e "${YELLOW}Creating VARIABOT directories...${NC}"
mkdir -p "$TERMUX_HOME/.variabot/logs"
mkdir -p "$TERMUX_HOME/.variabot/cache/urls"
echo -e "${GREEN}✓ VARIABOT directories created${NC}"

# Create default configuration if it doesn't exist
CONFIG_FILE="$TERMUX_HOME/.variabot/url_opener.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Creating default configuration...${NC}"
    cat > "$CONFIG_FILE" << 'EOF'
# VARIABOT URL Opener Configuration
# Customize URL handling behavior

# Enable/disable automatic processing
AUTO_PROCESS=true

# Enable/disable notifications
ENABLE_NOTIFICATIONS=true

# Default action for URLs (process, save, download)
DEFAULT_ACTION="process"

# Enable/disable URL caching
ENABLE_CACHE=true

# Maximum cache size in MB
MAX_CACHE_SIZE=100

# VARIABOT interface to use (auto, web, terminal)
VARIABOT_INTERFACE="auto"

# Enable/disable automatic VARIABOT launch
AUTO_LAUNCH_VARIABOT=false
EOF
    echo -e "${GREEN}✓ Default configuration created${NC}"
else
    echo -e "${GREEN}✓ Configuration already exists${NC}"
fi

# Check if termux-api is installed
echo ""
echo -e "${BLUE}Checking optional dependencies...${NC}"
if command -v termux-notification &> /dev/null; then
    echo -e "${GREEN}✓ termux-api installed (notifications enabled)${NC}"
else
    echo -e "${YELLOW}⚠ termux-api not installed (notifications disabled)${NC}"
    echo -e "${YELLOW}  Install with: pkg install termux-api${NC}"
fi

if command -v wget &> /dev/null; then
    echo -e "${GREEN}✓ wget installed (download support enabled)${NC}"
else
    echo -e "${YELLOW}⚠ wget not installed (download support disabled)${NC}"
    echo -e "${YELLOW}  Install with: pkg install wget${NC}"
fi

# Test installation
echo ""
echo -e "${YELLOW}Testing installation...${NC}"
if "$BIN_DIR/termux-url-opener" --version &> /dev/null; then
    echo -e "${GREEN}✓ Installation successful!${NC}"
else
    echo -e "${RED}✗ Installation test failed${NC}"
    exit 1
fi

# Display usage information
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo -e "  1. Share a URL to Termux from any app"
echo -e "  2. The URL will be automatically processed"
echo ""
echo -e "${BLUE}Manual usage:${NC}"
echo -e "  termux-url-opener https://example.com"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  Edit: $CONFIG_FILE"
echo -e "  View: termux-url-opener --config"
echo ""
echo -e "${BLUE}Logs:${NC}"
echo -e "  Location: $TERMUX_HOME/.variabot/logs/"
echo ""
echo -e "${BLUE}Recommendations:${NC}"
if ! command -v termux-notification &> /dev/null; then
    echo -e "  ${YELLOW}• Install termux-api for notifications:${NC}"
    echo -e "    pkg install termux-api"
fi
if ! command -v wget &> /dev/null; then
    echo -e "  ${YELLOW}• Install wget for download support:${NC}"
    echo -e "    pkg install wget"
fi
echo ""
echo -e "${CYAN}For help: termux-url-opener --help${NC}"
echo ""

# References:
# - Internal: /reference_vault/PRODUCTION_GRADE_STANDARDS.md#deployment-standards
# - Internal: /reference_vault/linux_kali_android.md#termux-optimization
# - External: Termux Wiki — https://wiki.termux.com/wiki/Termux-url-opener
