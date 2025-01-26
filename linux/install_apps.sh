#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env
source "$(dirname "$0")/../utils/display_menu.sh"
source "$(dirname "$0")/install_flatpak.sh"
source "$(dirname "$0")/update_apps.sh"

# Function to install apps on Linux
install_apps_linux() {
    # Install FlatPak if not installed
    install_flatpak
    # Check if dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        sudo apt-get install -y dialog
    fi

    local apps=("$@")
    for app in "${apps[@]}"; do
        sudo apt-get install -y "$app"
    done
}

# Main function to handle app installation based on user choice
main() {
    # Update all Homebrew packages before installation
    update_all_apps_linux
    
    # Install Homebrew if not installed
    install_homebrew

    # Display menu and get user choices
    choices=$(display_menu)

    # Install selected apps
    [[ "$choices" == *"1"* ]] && install_apps_linux $(echo "$INSTALL_APPS_BASIC_MAC" | tr ',' ' ')
    [[ "$choices" == *"2"* ]] && install_apps_linux $(echo "$INSTALL_APPS_DEV_MAC" | tr ',' ' ')
    [[ "$choices" == *"3"* ]] && install_apps_linux $(echo "$APPS_TO_INSTALL_MAC" | tr ',' ' ')
}

main