#!/bin/bash

# Load Scripts
set -e # Exit script if any command fails

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/detect_os.sh"

# Universal Scripts
source "$(dirname "$0")/grant_permissions.sh"
source "$(dirname "$0")/install_apps.sh"

# Mac scripts
source "$(dirname "$0")/mac/setup_mac.sh"

# Repository Scripts
source "$(dirname "$0")/github/setup_github_accounts.sh"
source "$(dirname "$0")/bitbucket/setup_bitbucket_accounts.sh"
source "$(dirname "$0")/ssh-config/setup_ssh_config.sh"

# Dev Scripts
source "$(dirname "$0")/dev/setup_dev.sh"


setup_enviroment() {
    print_info "Detecting the operating system..."
    load_env

    detect_os
    grant_permissions
    # install_apps "$os"

    
    # if [[ "$os" == "macOS" ]]; then
    #     setup_mac
    # elif [[ "$os" == "linux" ]]; then
    #     # TODO - create de function setup_linux
    #     print_info "Linux setup not implemented yet"
    # else
    #     print_alert "Unsupported OS: $os"
    # fi

    # setup_github_accounts
    # setup_bitbucket_accounts
    # setup_ssh_config

    setup_dev

    print_success "Success to Setup Enviroment!!!"
}

setup_enviroment