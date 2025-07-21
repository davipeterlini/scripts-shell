#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/detect_os.sh"

# Scripts Mac Setup
source "$(dirname "$0")/mac/setup/setup_basic_config.sh"
source "$(dirname "$0")/mac/setup/setup_iterm.sh"
source "$(dirname "$0")/mac/setup/setup_terminal.sh"
source "$(dirname "$0")/mac/setup/enable_touchid_sudo.sh"
source "$(dirname "$0")/mac/setup/setup_karabiner.sh"

setup_mac() {
    print_header "Starting Setup for Mac Environment"
    load_env

    detect_os
    
    # Check if we are on a Mac system
    if [[ "$os" != "macOS" ]]; then
        print_error "This script should only be run on macOS systems"
        exit 1
    fi

    setup_basic_config
    
    setup_iterm
    
    setup_terminal
    
    enable_touchid_sudo

    setup_karabiner all

    print_success "Mac setup completed successfully!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_mac "$@"
fi