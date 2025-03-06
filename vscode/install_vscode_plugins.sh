#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors message
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to install VSCode extensions
install_vscode_extensions() {
    print_info "Installing VSCode extensions..."

    for extension in "${VSCODE_EXTENSIONS[@]}"; do
        print_info "Installing extension: $extension"
        code --install-extension "$extension"
    done

    print_success "VSCode extensions installed successfully."
}

# Run the function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_vscode_extensions
fi