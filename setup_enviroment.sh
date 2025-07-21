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

# Import Mac setup script
source "${SCRIPTS_DIR}/mac/setup_mac.sh"

source "$(dirname "$0")/github/setup_github_accounts.sh"
source "$(dirname "$0")/bitbucket/setup_bitbucket_accounts.sh"
source "$(dirname "$0")/ssh-config/setup_ssh_config.sh"
source "$(dirname "$0")/gcloud/setup_gcloud.sh"
source "$(dirname "$0")/dev/setup_dev.sh"


# TODO - adjust after fixing mac scripts and creating linux ones
# _setup_linux() {
#     print_info "Setting up terminal configurations..."
#     ./mac/setup/setup_terminal.sh

#     # TODO - criar mais scripts e colocar mais configurações
# }

setup_vscode() {
    print_info "Installing VSCode extensions..."
    ./vscode/install_vscode_plugins.sh

    print_info "Setting up VSCode configurations..."
    ./vscode/setup_vscode.sh

    print_info "Saving VSCode settings..."
    ./vscode/save_vscode_settings.sh

    print_success "VSCode setup completed successfully."
}

# Detect the operating system and execute the corresponding script
setup_enviroment() {
    print_info "Detecting the operating system..."
    load_env

    detect_os
    # grant_permissions
    # install_apps "$os"

    
    # if [[ "$os" == "macOS" ]]; then
    #     setup_mac
    # elif [[ "$os" == "linux" ]]; then
    #     # _setup_linux
    #     print_info "Linux setup not implemented yet"
    # else
    #     print_alert "Unsupported OS: $os"
    # fi

    setup_github_accounts
    setup_bitbucket_accounts
    setup_ssh_config
    setup_gcloud

    setup_dev

    print_success "Success to Setup Enviroment!!!"
}

# Execute the script
setup_enviroment