#!/bin/bash

# Load the script to install Homebrew if not already installed
source "$(dirname "$0")/install_homebrew.sh"
source "$(dirname "$0")/update_all_apps_mac.sh.sh"

# Function to install apps using Homebrew
install_brew_apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        brew install "$app"
    done
}

# Main script execution
main() {
    # Install Homebrew if not installed
    install_homebrew

    update_all_apps_mac

    # Install the provided apps
    install_brew_apps "$@"
}

main "$@"