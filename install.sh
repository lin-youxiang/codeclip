#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
INFO="${BLUE}[INFO]${NC}"
SUCCESS="${GREEN}[SUCCESS]${NC}"
ERROR="${RED}[ERROR]${NC}"
WARN="${YELLOW}[WARN]${NC}"

# Get the absolute path of the current directory
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="com.codeclip.autorun.plist"
PLIST_PATH="$CURRENT_DIR/$PLIST_FILE"
PLIST_DEST="$LAUNCH_AGENTS_DIR/$PLIST_FILE"

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${SUCCESS} $1"
    else
        echo -e "${ERROR} $2"
        exit 1
    fi
}

# Function to clean up existing installation
cleanup_existing() {
    echo -e "${INFO} Checking for existing installation..."
    
    # Check if service is loaded
    if launchctl list | grep -q "com.codeclip.autorun"; then
        echo -e "${WARN} Found running service, unloading..."
        launchctl unload "$PLIST_DEST" 2>/dev/null
        check_status "Unloaded existing service" "Failed to unload existing service"
    else
        echo -e "${INFO} No running service found"
    fi

    # Remove existing plist if it exists
    if [ -f "$PLIST_DEST" ]; then
        echo -e "${WARN} Found existing plist file, removing..."
        rm "$PLIST_DEST"
        check_status "Removed existing plist file" "Failed to remove existing plist file"
    fi

    # Clean up log files if they exist
    if [ -f "$CURRENT_DIR/stdout.log" ] || [ -f "$CURRENT_DIR/stderr.log" ]; then
        echo -e "${WARN} Found existing log files, cleaning up..."
        rm -f "$CURRENT_DIR/stdout.log" "$CURRENT_DIR/stderr.log"
        check_status "Cleaned up log files" "Failed to clean up log files"
    fi
}

# Create LaunchAgents directory if it doesn't exist
echo -e "${INFO} Checking LaunchAgents directory..."
if [ ! -d "$LAUNCH_AGENTS_DIR" ]; then
    mkdir -p "$LAUNCH_AGENTS_DIR"
    check_status "Created LaunchAgents directory" "Failed to create LaunchAgents directory"
fi

# Check if plist file exists
echo -e "${INFO} Checking plist file..."
if [ ! -f "$PLIST_PATH" ]; then
    echo -e "${ERROR} Plist file not found: $PLIST_PATH"
    exit 1
fi

# Clean up any existing installation
cleanup_existing

# Copy plist file to LaunchAgents directory
echo -e "${INFO} Installing new plist file..."
cp "$PLIST_PATH" "$PLIST_DEST"
check_status "Copied plist file to $LAUNCH_AGENTS_DIR" "Failed to copy plist file"

# Set correct permissions
echo -e "${INFO} Setting permissions..."
chmod 644 "$PLIST_DEST"
check_status "Set permissions" "Failed to set permissions"

# Load the launch agent
echo -e "${INFO} Loading launch agent..."
launchctl load "$PLIST_DEST"
check_status "Loaded launch agent successfully" "Failed to load launch agent"

echo -e "\n${SUCCESS} Installation completed successfully! 🎉"
echo -e "${INFO} Service status:"
launchctl list | grep "com.codeclip.autorun" || echo -e "${ERROR} Service not found in launchctl list"
echo -e "${INFO} You can check the logs at:"
echo -e "  - ${BLUE}$CURRENT_DIR/stdout.log${NC}"
echo -e "  - ${BLUE}$CURRENT_DIR/stderr.log${NC}"