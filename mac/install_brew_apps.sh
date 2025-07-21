#!/bin/bash

source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/utils/colors_message.sh"

_install_brew_apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        brew install "$app"
    done
}

install_brew_apps() {
    install_homebrew

    # Display the list of apps to be installed
    print_info "The following applications will be installed:"
    for app in "$@"; do
        print "- $app"
    done
    
    # Ask for confirmation before proceeding
    read -p "Do you want to continue with the installation? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Starting installation..."
        _install_brew_apps "$@"
    else
        print_alert "Installation cancelled."
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_brew_apps "$@"
fi