#!/bin/bash

# Function to update all Flatpak applications
update_flatpak_apps() {
    echo "Updating Flatpak applications..."
    flatpak update -y
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "$0")/install_flatpak.sh"
    install_flatpak.sh "Call from Update"
    update_flatpak_apps
fi