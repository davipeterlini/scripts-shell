#!/bin/bash

# Load environment variables and utility functions
# Load environment variables and utility functions if not already loaded
if [ -z "$ENV_LOADED" ]; then
    source "$(dirname "$0")/utils/load_env.sh"
    load_env
    export ENV_LOADED=true
fi
source "$(dirname "$0")/install_flatpak.sh"

# Function to update and upgrade existing packages
update_all_apps_linux() {
    echo "Updating package lists..."
    sudo apt-get update

    echo "Upgrading installed packages..."
    sudo apt-get upgrade -y

    echo "Autoremove unnecessary packages..."
    sudo apt-get autoremove -y

    echo "Autoclean package cache..."
    sudo apt-get autoclean -y
}

# Main function to handle the update process
main() {
    # Install Homebrew if not installed
	install_flatpak

    # Update all Homebrew packages
    update_all_apps_linux
}

main