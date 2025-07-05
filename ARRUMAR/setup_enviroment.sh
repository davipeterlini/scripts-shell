#!/bin/bash

# Load Scripts
set -e # Exit script if any command fails

# Source utility scripts with absolute paths
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="${SCRIPTS_DIR}/utils"

source "${UTILS_DIR}/load_env.sh"
source "${UTILS_DIR}/detect_os.sh"
source "${UTILS_DIR}/colors_message.sh"

source "${SCRIPTS_DIR}/grant_permissions.sh"
source "${SCRIPTS_DIR}/install_apps.sh"

source "$(dirname "$0")/github/setup_github_accounts.sh"
source "$(dirname "$0")/bitbucket/setup_bitbucket_accounts.sh"

setup_github () {
    print_info "Configuring multiple SSH keys for GitHub accounts..."
    ./github/configure_multi_ssh_github_keys.sh

    print_info "Connecting to GitHub using SSH..."
    ./github/connect_git_ssh_account.sh

    print_info "Generating GitHub Personal Access Token..."
    ./github/generate-classic-token-gh-local.sh
}

setup_bitbucket () {
    print_info "Configuring multiple SSH keys for GitHub accounts..."
    ./bitbucket/configure_multi_ssh_bitbucket_keys.sh

    print_info "Connecting to GitHub using SSH..."
    ./bitbucket/connect_bitbucket_ssh_account.sh

    print_info "Generating GitHub Personal Access Token..."
    ./bitbucket/generate-classic-token-bb-local.sh
}

setup_vscode() {
    print_info "Installing VSCode extensions..."
    ./vscode/install_vscode_plugins.sh

    print_info "Setting up VSCode configurations..."
    ./vscode/setup_vscode.sh

    print_info "Saving VSCode settings..."
    ./vscode/save_vscode_settings.sh

    print_success "VSCode setup completed successfully."
}

setup_mac() {
    print_info "Setting up macOS configurations..."
    ./mac/setup/setup_iterm.sh

    print_info "Setting up terminal configurations..."
    ./mac/setup/setup_terminal.sh
    
    # TODO - falta configurações de teclado e de ajustes do mac os
}

setup_linux() {
    print_info "Setting up terminal configurations..."
    ./mac/setup/setup_terminal.sh

    # TODO - criar mais scripts e colocar mais configurações
}

# Detect the operating system and execute the corresponding script
setup_enviroment() {
    print_info "Detecting the operating system..."
    load_env

    detect_os

    grant_permissions

    install_apps "$os"

    setup_github_accounts
    setup_bitbucket_accounts
    setup_ssh_config

    #setup_github
    #setup_bitbucket
    #setup_vscode
}

# Execute the script
setup_enviroment

# TODO - deve ter um mecanismo que ao interromper CTRL + C no terminal interrompe script por script