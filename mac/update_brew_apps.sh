#!/bin/bash

# Function to update all Homebrew packages
update_all_apps_mac() {
    echo "Updating all Homebrew packages..."
    brew update
    brew upgrade
    brew cleanup
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "$0")/install_homebrew.sh"
    install_homebrew "Call from Update"
    update_all_apps_mac
fi