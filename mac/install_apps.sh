#!/bin/bash

# Load environment variables and utility functions if not already loaded
if [ -z "$ENV_LOADED" ]; then
    source "$(dirname "$0")/utils/load_env.sh"
    load_env
    export ENV_LOADED=true
fi
source "$(dirname "$0")/../utils/display_menu.sh"
source "$(dirname "$0")/install_homebrew.sh"
source "$(dirname "$0")/update_apps.sh"

# Function to install apps on macOS
install_apps_mac() {
    # Check if dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        brew install dialog
    fi

    local apps=("$@")
    for app in "${apps[@]}"; do
        brew install "$app"
    done
}

# Main function to handle app installation based on user choice
main() {
    # Update all Homebrew packages before installation
    update_all_apps_mac
    
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