#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting gshell setup in Termux...${NC}"

# Step 1: Verify gcloud installation
if ! command -v gcloud >/dev/null 2>&1; then
    echo -e "${RED}gcloud command not found. Please ensure the Google Cloud SDK is installed and configured in your PATH.${NC}"
    exit 1
fi
echo -e "${GREEN}gcloud command verified.${NC}"

# Step 2: Set the project configuration
# Using the specified project from the original script.
PROJECT_ID="nifty-acolyte-473302-v9"
echo -e "${YELLOW}Setting active gcloud project to: ${PROJECT_ID}${NC}"
gcloud config set project "${PROJECT_ID}"
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to set gcloud project. Please check your authentication and permissions.${NC}"
    exit 1
fi
echo -e "${GREEN}Successfully set project to ${PROJECT_ID}.${NC}"

# Step 3: Safely add or update the gshell alias in .bashrc
BASHRC_FILE="$HOME/.bashrc"
GSHELL_ALIAS="alias gshell='gcloud alpha cloud-shell ssh --force-key-file-overwrite'"

echo -e "${YELLOW}Checking for existing gshell alias in ${BASHRC_FILE}...${NC}"

# Check if the alias already exists and is correct
if grep -q "alias gshell=" "$BASHRC_FILE"; then
    if grep -qF -- "$GSHELL_ALIAS" "$BASHRC_FILE"; then
        echo -e "${GREEN}gshell alias is already correctly configured. No changes needed.${NC}"
    else
        echo -e "${YELLOW}An old gshell alias was found. Updating it now...${NC}"
        # Remove the old alias
        sed -i "/alias gshell=/d" "$BASHRC_FILE"
        # Add the new, correct alias
        echo "$GSHELL_ALIAS" >> "$BASHRC_FILE"
        echo -e "${GREEN}gshell alias has been updated.${NC}"
    fi
else
    echo -e "${YELLOW}gshell alias not found. Adding it to ${BASHRC_FILE}...${NC}"
    # Append the alias to the .bashrc file
    echo "" >> "$BASHRC_FILE" # Add a newline for better formatting
    echo "# Added by VARIABOT setup for easy Cloud Shell access" >> "$BASHRC_FILE"
    echo "$GSHELL_ALIAS" >> "$BASHRC_FILE"
    echo -e "${GREEN}gshell alias has been added successfully.${NC}"
fi

# Step 4: Safely configure SSH to prevent timeouts
SSH_CONFIG_FILE="$HOME/.ssh/config"
SSH_CONFIG_ENTRY="Host *\n    ServerAliveInterval 120\n    ServerAliveCountMax 40"

echo -e "${YELLOW}Checking SSH configuration to prevent timeouts...${NC}"
mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG_FILE" # Ensure the file exists

# Check if the configuration is already present
if grep -q "ServerAliveInterval" "$SSH_CONFIG_FILE"; then
    echo -e "${GREEN}SSH keep-alive settings are already configured.${NC}"
else
    echo -e "${YELLOW}Adding SSH keep-alive settings to ${SSH_CONFIG_FILE}...${NC}"
    # Append the settings to the config file
    echo -e "\n$SSH_CONFIG_ENTRY" >> "$SSH_CONFIG_FILE"
    echo -e "${GREEN}SSH configuration updated.${NC}"
fi

# Step 5: Final instructions for the user
echo -e "\n${GREEN}Setup complete!${NC}"
echo -e "${YELLOW}To apply the changes, please restart your Termux session or run:${NC}"
echo -e "  source ~/.bashrc"
echo -e "${YELLOW}After that, you can connect to Google Cloud Shell by simply typing:${NC}"
echo -e "  gshell"
echo -e "${YELLOW}If you encounter any issues, check your internet connection or run 'gcloud auth login' to re-authenticate.${NC}"

# References:
# - Internal: /reference_vault/PRODUCTION_GRADE_STANDARDS.md#scripting-best-practices
# - Internal: /reference_vault/linux_kali_android.md#termux-ssh-integration
# - Internal: AGENTS.md