#!/bin/bash

source "$(dirname "$0")/mac/install_homebrew.sh"

# Function to update all Homebrew packages
update_brew_apps() {
    echo "Updating all Homebrew packages..."
    brew update
    brew upgrade
    brew cleanup
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    #install_homebrew
    update_brew_apps
fi