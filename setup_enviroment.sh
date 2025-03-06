#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/utils/load_env.sh"
load_env

# Load OS detection script
source "$(dirname "$0")/utils/detect_os.sh"

# Load colors message
source "$(dirname "$0")/utils/colors_message.sh"

# Function to Install and configure VSCode
setup_initial() {
    print_info "Granting permissions for all scripts..."
    ./grant_permissions.sh

    print_info "Install selected apps"
    ./install_apps.sh
}

setup_github () {
    print_info "Configuring multiple SSH keys for GitHub accounts..."
    ./github/configure_multi_ssh_github_keys.sh

    print_info "Connecting to GitHub using SSH..."
    ./github/connect_git_ssh_account.sh

    print_info "Generating GitHub Personal Access Token..."
    ./github/generate-classic-token-gh-local.sh
}

# Function to Install and configure VSCode
setup_vscode() {
    print_info "Setting up VSCode configurations..."
    ./vscode/vscode/setup_vscode.sh

    print_info "Installing VSCode extensions..."
    ./vscode/install_vscode_plugins.sh

    print_success "VSCode setup completed successfully."
}

# Function to install additional apps and configurations on macOS
setup_mac() {
    print_info "Setting up macOS configurations..."
    ./mac/setup/setup_iterm.sh
    print_info "Setting up terminal configurations..."
    ./mac/setup/setup_terminal.sh
    # TODO - falta configurações de teclado e de ajustes do mac os
}

# Function to install additional apps and configurations on Linux (Debian-based)
# setup_linux() {
#     # Add Linux-specific setup steps here
# }

# Detect the operating system and execute the corresponding script
detect_and_install_apps() {
    print_info "Detecting the operating system..."

    # Detect the operating system
    os=$(detect_os)
    print_info "Detected OS: $os"

    # TODO - testar no linux
    setup_initial
    setup_github
    setup_vscode

    case "$os" in
        macOS)
            print_info "macOS detected."
            setup_mac
            ;;
        Linux)
            print_info "Linux detected."
            setup_linux
            ;;
        *)
            print_error "Unsupported operating system."
            exit 1
            ;;
    esac
}

# Execute the script
detect_and_install_apps


# TODO - deve ter um mecanismo que ao interromper CTRL + C no terminal interrompe script por script