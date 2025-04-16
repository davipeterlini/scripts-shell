#!/bin/bash

# Load the script to install Homebrew if not already installed
source "$(dirname "$0")/install_homebrew.sh"


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

    # Install the provided apps
    install_brew_apps "$@"
}

main "$@"