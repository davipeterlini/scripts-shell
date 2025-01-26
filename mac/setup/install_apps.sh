#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../../utils/load_env.sh"
load_env
source "$(dirname "$0")/../../utils/display_menu.sh"
source "$(dirname "$0")/install_homebrew.sh"

# Function to install apps on macOS
install_apps_mac() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        brew install "$app"
    done
}

# Main function to handle app installation based on user choice
main() {
    # Install Homebrew if not installed
    install_homebrew

    # Display menu and get user choices
    choices=$(display_menu)

    # Install selected apps
    [[ "$choices" == *"1"* ]] && install_apps_mac $(echo "$INSTALL_APPS_BASIC_MAC" | tr ',' ' ')
    [[ "$choices" == *"2"* ]] && install_apps_mac $(echo "$INSTALL_APPS_DEV_MAC" | tr ',' ' ')
    [[ "$choices" == *"3"* ]] && install_apps_mac $(echo "$APPS_TO_INSTALL_MAC" | tr ',' ' ')
}

main