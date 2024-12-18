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
PLIST_DEST="$LAUNCH_AGENTS_DIR/$PLIST_FILE"
SERVICE_NAME="com.codeclip.autorun"

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${SUCCESS} $1"
    else
        echo -e "${ERROR} $2"
        return 1
    fi
}

# Function to check if service is running
check_service() {
    launchctl list | grep -q "$SERVICE_NAME"
    return $?
}

# Function to kill process by label
kill_service_process() {
    local pid=$(launchctl list | grep "$SERVICE_NAME" | awk '{print $1}')
    if [ ! -z "$pid" ] && [ "$pid" -ne 0 ]; then
        echo -e "${WARN} Forcefully terminating process..."
        kill -9 "$pid" 2>/dev/null
        sleep 1
    fi
}

# Function to safely remove file
safe_remove() {
    local file="$1"
    if [ -f "$file" ]; then
        if ! rm -f "$file" 2>/dev/null; then
            echo -e "${INFO} Requesting admin privileges to remove file: $file"
            sudo rm -f "$file"
        fi
        return $?
    fi
    return 0
}

echo -e "${INFO} Starting uninstallation process..."

# Stop the service
if check_service; then
    echo -e "${INFO} Stopping service..."
    
    # Try normal unload first
    launchctl unload "$PLIST_DEST" 2>/dev/null
    sleep 1
    
    # If service is still running, try force unload
    if check_service; then
        echo -e "${WARN} Service still running, attempting force unload..."
        launchctl unload -w "$PLIST_DEST" 2>/dev/null
        sleep 1
    fi
    
    # If service is still running, try to kill the process
    if check_service; then
        kill_service_process
    fi
    
    # Final check
    if check_service; then
        echo -e "${ERROR} Failed to stop service completely"
        echo -e "${INFO} You may need to restart your computer to fully remove the service"
    else
        echo -e "${SUCCESS} Service stopped successfully"
    fi
else
    echo -e "${INFO} Service is not running"
fi

# Remove plist file
if [ -f "$PLIST_DEST" ]; then
    echo -e "${INFO} Removing launch agent configuration..."
    safe_remove "$PLIST_DEST"
    check_status "Removed launch agent configuration" "Failed to remove configuration file"
else
    echo -e "${INFO} Launch agent configuration not found"
fi

# Clean up log files
echo -e "${INFO} Cleaning up log files..."
safe_remove "$CURRENT_DIR/stdout.log"
safe_remove "$CURRENT_DIR/stderr.log"
check_status "Removed log files" "Failed to remove log files"

# Final verification
echo -e "\n${INFO} Verifying cleanup..."
CLEANUP_FAILED=0

if check_service; then
    echo -e "${ERROR} Service is still running."
    echo -e "${INFO} Please restart your computer to ensure complete removal."
    CLEANUP_FAILED=1
fi

if [ -f "$PLIST_DEST" ]; then
    echo -e "${ERROR} Launch agent configuration still exists at: $PLIST_DEST"
    echo -e "${INFO} You can try to remove it manually using:"
    echo -e "    sudo rm -f \"$PLIST_DEST\""
    CLEANUP_FAILED=1
fi

if [ -f "$CURRENT_DIR/stdout.log" ] || [ -f "$CURRENT_DIR/stderr.log" ]; then
    echo -e "${ERROR} Log files still exist in: $CURRENT_DIR"
    CLEANUP_FAILED=1
fi

if [ $CLEANUP_FAILED -eq 0 ]; then
    echo -e "\n${SUCCESS} Uninstallation completed successfully! 🧹"
    echo -e "${INFO} All components have been removed from your system."
else
    echo -e "\n${WARN} Uninstallation completed with warnings."
    echo -e "${INFO} Some components may need manual removal or a system restart."
fi