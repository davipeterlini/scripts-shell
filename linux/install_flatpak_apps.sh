#!/bin/bash

# Load the install_flatpak script
source "$(dirname "$0")/install_flatpak.sh"

# Function to install apps using flatpak
install_flatpak_apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        echo "Installing $app via flatpak..."
        sudo flatpak install -y "$app"
    done
}

# Main script execution
main() {
    # Install Homebflatpakrew if not installed
    install_flatpak

    # Install the provided apps
    install_flatpak_apps "$@"
}

main "$@"