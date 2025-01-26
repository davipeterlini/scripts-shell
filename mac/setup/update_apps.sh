#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../../utils/load_env.sh"
load_env
source "$(dirname "$0")/install_homebrew.sh"

# Function to update all Homebrew packages
update_all_apps_mac() {
    echo "Updating Homebrew and all installed packages..."
    brew update
    brew upgrade
    brew cleanup
}

# Main function to handle the update process
main() {
    # Install Homebrew if not installed
    install_homebrew

    # Update all Homebrew packages
    update_all_apps_mac
}

main