#!/bin/bash

set -e

# Define colors for output
RED_BOLD='\033[1;31m'
GREEN_BOLD='\033[1;32m'
YELLOW_BOLD='\033[1;33m'
BLUE_BOLD='\033[0;34m'
NC='\033[0m' # No Color

PYTHON_VERSION="3.12.9"
PYENV_DIR="$HOME/.pyenv"
PYENV_VIRTUALENV_DIR="$PYENV_DIR/plugins/pyenv-virtualenv"
TEMP_DIR="./temp"

# Function to check if Python is installed globally
check_global_python() {
    echo -e "${YELLOW_BOLD}Checking for global Python installation...${NC}"
    if command -v python3 &> /dev/null; then
        global_version=$(python3 --version 2>&1 | awk '{print $2}')
        if [[ "$global_version" == "$PYTHON_VERSION" ]]; then
            echo -e "${BLUE}Python $PYTHON_VERSION is installed globally.${NC}"
            return 0
        else
            echo -e "${GREEN_BOLD}Global Python version is $global_version, not $PYTHON_VERSION. No removal needed.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN_BOLD}No global Python installation detected.${NC}"
        return 1
    fi
}

# Function to remove global Python installation
remove_global_python() {
    echo -e "${YELLOW_BOLD}Removing global Python $PYTHON_VERSION installation...${NC}"
    sudo rm -rf "/Library/Frameworks/Python.framework/Versions/$PYTHON_VERSION"
    sudo rm -rf "/Applications/Python $PYTHON_VERSION"
    echo -e "${GREEN_BOLD}Global Python $PYTHON_VERSION removed successfully.${NC}"
}

# Function to check if Python is installed with pyenv
check_pyenv_python() {
    echo -e "${YELLOW_BOLD}Checking for pyenv Python installation...${NC}"
    if [[ -d "$PYENV_DIR" ]]; then
        export PATH="$PYENV_DIR/bin:$PATH"
        if command -v pyenv &> /dev/null; then
            if pyenv versions --bare | grep -q "^$PYTHON_VERSION$"; then
                echo -e "${BLUE}Python $PYTHON_VERSION is installed with pyenv.${NC}"
                return 0
            else
                echo -e "${GREEN_BOLD}Python $PYTHON_VERSION is not installed with pyenv. No removal needed.${NC}"
                return 1
            fi
        else
            echo -e "${RED_BOLD}pyenv is installed but not functioning correctly.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN_BOLD}pyenv is not installed.${NC}"
        return 1
    fi
}

# Function to remove Python from pyenv
remove_pyenv_python() {
    echo -e "${YELLOW_BOLD}Removing Python $PYTHON_VERSION from pyenv...${NC}"
    pyenv uninstall -f "$PYTHON_VERSION"
    echo -e "${GREEN_BOLD}Python $PYTHON_VERSION removed from pyenv successfully.${NC}"
}

# Function to check and remove pyenv-virtualenv
remove_pyenv_virtualenv() {
    echo -e "${YELLOW_BOLD}Checking pyenv-virtualenv plugin...${NC}"
    if [[ -d "$PYENV_VIRTUALENV_DIR" ]]; then
        echo -e "${BLUE}Removing pyenv-virtualenv plugin...${NC}"
        rm -rf "$PYENV_VIRTUALENV_DIR"
        echo -e "${GREEN_BOLD}pyenv-virtualenv removed successfully.${NC}"
    else
        echo -e "${GREEN_BOLD}pyenv-virtualenv is not installed.${NC}"
    fi
}

# Function to remove pyenv
remove_pyenv() {
    echo -e "${YELLOW_BOLD}Removing pyenv installation...${NC}"
    if [[ -d "$PYENV_DIR" ]]; then
        rm -rf "$PYENV_DIR"
        echo -e "${GREEN_BOLD}pyenv removed successfully.${NC}"
    else
        echo -e "${GREEN_BOLD}pyenv is not installed.${NC}"
    fi
}

# Function to check if coder is installed and remove it
remove_coder_package() {
    echo -e "${YELLOW_BOLD}Checking if coder is installed...${NC}"
    PYENV_PYTHON_BIN="$PYENV_DIR/versions/$PYTHON_VERSION/bin/python3"
    if [[ -x "$PYENV_PYTHON_BIN" ]]; then
        if "$PYENV_PYTHON_BIN" -m pip show coder &> /dev/null; then
            echo -e "${BLUE}Removing coder package...${NC}"
            "$PYENV_PYTHON_BIN" -m pip uninstall -y coder
            echo -e "${GREEN_BOLD}Coder package removed successfully.${NC}"
        else
            echo -e "${GREEN_BOLD}Coder package is not installed.${NC}"
        fi
    else
        echo -e "${GREEN_BOLD}Python $PYTHON_VERSION binary not found in pyenv directory. Skipping coder removal.${NC}"
    fi
}

# Function to remove the /usr/local/bin/code file
remove_coder_binary() {
    echo -e "${YELLOW_BOLD}Checking for /usr/local/bin/coder binary...${NC}"
    if [[ -f "/usr/local/bin/coder" ]]; then
        echo -e "${BLUE}Removing /usr/local/bin/coder binary...${NC}"
        sudo rm -f "/usr/local/bin/coder"
        echo -e "${GREEN_BOLD}/usr/local/bin/coder binary removed successfully.${NC}"
    else
        echo -e "${GREEN_BOLD}/usr/local/bin/coder binary does not exist.${NC}"
    fi
}

# Main script execution
if check_global_python; then
    remove_global_python
else
    echo -e "${GREEN_BOLD}No global Python $PYTHON_VERSION installation found.${NC}"
fi

if check_pyenv_python; then
    remove_coder_package
    remove_pyenv_python
else
    echo -e "${GREEN_BOLD}No pyenv Python $PYTHON_VERSION installation found.${NC}"
fi

remove_coder_binary
remove_pyenv_virtualenv
remove_pyenv

echo -e "${GREEN_BOLD}Uninstallation process completed.${NC}"