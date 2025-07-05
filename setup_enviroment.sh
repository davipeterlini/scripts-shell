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

source "$(dirname "$0")/mac/setup/setup_basic_config.sh"
source "$(dirname "$0")/mac/setup/setup_iterm.sh"
source "$(dirname "$0")/mac/setup/setup_terminal.sh"
source "$(dirname "$0")/mac/setup/setup_abnt2_keyboard.sh"
source "$(dirname "$0")/mac/setup/enable_touchid_sudo.sh"

source "$(dirname "$0")/github/setup_github_accounts.sh"
#source "$(dirname "$0")/github/connect_git_ssh_account.sh"
#source "$(dirname "$0")/github/generate-classic-token-gh-local.sh"
source "$(dirname "$0")/bitbucket/setup_bitbucket_accounts.sh"
#source "$(dirname "$0")/github/connect_bitbucket_ssh_account.sh"
#source "$(dirname "$0")/github/generate-classic-token-bb-local.sh"
source "$(dirname "$0")/ssh-config/setup_ssh_config.sh"
source "$(dirname "$0")/gcloud/setup_gcloud.sh"
source "$(dirname "$0")/dev/setup_dev.sh"


_setup_github () {
    # Configuring multiple SSH keys for GitHub accounts...
    setup_github_accounts

    # Connecting to GitHub using SSH...
    #connect_git_ssh_account

    # Generating GitHub Personal Access Token...
    #generate-classic-token-gh-local.sh
}

_setup_bitbucket () {
    # Configuring multiple SSH keys for GitHub accounts...
    setup_bitbucket_accounts

    # Connecting to GitHub using SSH...
    #connect_bitbucket_ssh_account.sh

    # Generating GitHub Personal Access Token...
    #generate-classic-token-bb-local.sh
}

_setup_mac() {
    setup_basic_config
    setup_iterm
    # TODO - erro ao configurar       
        #- Failed to load settings from custom directory. Falling back to local copy.
        #- Missing or malformed file at "~/.iterm2"
    # TODO - não carrega o que foi carregado anteriormente 
    setup_terminal
    
    # Configuração do teclado ABNT2
    setup_abnt2_keyboard

    enable_touchid_sudo
}

# TODO - ajustar após ajustar scripts do mac e criar os do linux
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
    grant_permissions
    #install_apps "$os"

    
    # _setup_mac
    # #_setup_linux

    # _setup_github
    # _setup_bitbucket
    # setup_ssh_config
    #setup_gcloud

    setup_dev

    print_success "Success to Setup Enviroment!!!"
}

# Execute the script
setup_enviroment

# TODO - deve ter um mecanismo que ao interromper CTRL + C no terminal interrompe script por script