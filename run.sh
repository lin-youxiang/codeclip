#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color
INFO="${BLUE}[INFO]${NC}"
SUCCESS="${GREEN}[SUCCESS]${NC}"
ERROR="${RED}[ERROR]${NC}"

# Export project directory as environment variable
export CODECLIP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo -e "${INFO} Project directory: $CODECLIP_DIR"

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${SUCCESS} $1"
    else
        echo -e "${ERROR} $2"
        exit 1
    fi
}

# Check if Python file exists
echo -e "${INFO} Checking Python file..."
if [ ! -f "$CODECLIP_DIR/message.py" ]; then
    echo -e "${ERROR} Python file message.py not found"
    exit 1
fi

# Check if requirements.txt exists
echo -e "${INFO} Checking requirements file..."
if [ ! -f "$CODECLIP_DIR/requirements.txt" ]; then
    echo -e "${ERROR} requirements.txt not found"
    exit 1
fi

# Check and create virtual environment if needed
if [ ! -d "$CODECLIP_DIR/.venv" ]; then
    echo -e "${INFO} Virtual environment not found, creating..."
    python3 -m venv "$CODECLIP_DIR/.venv"
    check_status "Created virtual environment" "Failed to create virtual environment"
else
    echo -e "${INFO} Virtual environment already exists"
fi

# Activate virtual environment
echo -e "${INFO} Activating virtual environment..."
source "$CODECLIP_DIR/.venv/bin/activate"
check_status "Activated virtual environment" "Failed to activate virtual environment"

# Install or upgrade pip
echo -e "${INFO} Upgrading pip..."
python -m pip install --upgrade pip >/dev/null 2>&1
check_status "Upgraded pip" "Failed to upgrade pip"

# Install requirements
echo -e "${INFO} Installing requirements..."
pip install -r "$CODECLIP_DIR/requirements.txt" >/dev/null 2>&1
check_status "Installed requirements" "Failed to install requirements"

# Run the Python script
echo -e "${INFO} Running Python script..."
python "$CODECLIP_DIR/message.py"
check_status "Successfully ran Python script" "Failed to run Python script"

# Deactivate virtual environment
echo -e "${INFO} Deactivating virtual environment..."
deactivate
check_status "Deactivated virtual environment" "Failed to deactivate virtual environment"

echo -e "\n${SUCCESS} All tasks completed successfully! 🎉"