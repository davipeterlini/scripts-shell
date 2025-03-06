#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/utils/load_env.sh"
load_env

# Load OS detection script
source "$(dirname "$0")/utils/detect_os.sh"

# Load colors message
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to Install and configure VSCode
setup_initial() {
    echo "Granting permissions for all scripts..."
    ./grant_permissions.sh

    echo "Install selected apps"
    ./install_apps.sh
}

setup_github () {
    echo "Configuring multiple SSH keys for GitHub accounts..."
    ./github/configure_multi_ssh_github_keys.sh

    echo "Connecting to GitHub using SSH..."
    ./github/connect_git_ssh_account.sh

    echo "Generating GitHub Personal Access Token..."
    ./github/generate-classic-token-gh-local.sh
}

# Function to Install and configure VSCode
setup_vscode() {
    echo "Setting up VSCode configurations..."
    ./vscode/vscode/setup_vscode.sh

    echo "Installing VSCode extensions..."
    ./vscode/install_vscode_plugins.sh

    echo "VSCode setup completed successfully."
    ./grant_permissions.sh
    ./vscode/setup/setup_iterm.sh
    ./mac/setup/setup_terminal.sh
    # TODO - falta configurações de teclado e de ajustes do mac os
}

# Function to install additional apps and configurations on macOS
setup_mac() {
    ./mac/setup/setup_iterm.sh
    ./mac/setup/setup_terminal.sh
    # TODO - falta configurações de teclado e de ajustes do mac os
}

# Function to install additional apps and configurations on Linux (Debian-based)
# setup_linux() {
#     # Add Linux-specific setup steps here
# }

# Detect the operating system and execute the corresponding script
detect_and_install_apps() {
    echo "Detecting the operating system..."

    # Detect the operating system
    os=$(detect_os)
    echo "Detected OS: $os"

    # TODO - testar no linux
    setup_initial
    setup_github
    setup_vscode

    case "$os" in
        macOS)
            echo "macOS detected."
            setup_mac
            
            ;;
        Linux)
            echo "Linux detected."
            setup_linux
            ;;
        *)
            echo "Unsupported operating system."
            exit 1
            ;;
    esac
}

# Execute the script
detect_and_install_apps


# TODO - deve ter um mecanismo que ao interromper CTRL + C no terminal interrompe script por script