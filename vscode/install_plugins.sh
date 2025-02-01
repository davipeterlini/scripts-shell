#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Function to install VSCode extensions
install_vscode_extensions() {
    for extension in "${VSCODE_EXTENSIONS[@]}"; do
        code --install-extension "$extension"
    done
}

# Main script execution
install_vscode_extensions