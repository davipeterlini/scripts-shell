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

# Function to install basic apps
install_basic_apps() {
    echo "Installing basic apps..."
    IFS=',' read -r -a basic_apps <<< "$INSTALL_APPS_BASIC_MAC"
    install_apps_mac "${basic_apps[@]}"
}

# Function to install development apps
install_dev_apps() {
    echo "Installing development apps..."
    IFS=',' read -r -a dev_apps <<< "$INSTALL_APPS_DEV_MAC"
    install_apps_mac "${dev_apps[@]}"
}

# Function to install all macOS apps
install_all_mac_apps() {
    echo "Installing all macOS apps..."
    IFS=',' read -r -a mac_apps <<< "$APPS_TO_INSTALL_MAC"
    install_apps_mac "${mac_apps[@]}"
}

main() {
    # Install Homebrew if not installed
    install_homebrew

    # Display menu and get user choices
    choices=$(display_menu)

    if [[ "$choices" == *"1"* ]]; then
        install_basic_apps
    fi

    if [[ "$choices" == *"2"* ]]; then
        install_dev_apps
    fi

    if [[ "$choices" == *"3"* ]]; then
        install_all_mac_apps
    fi
}

main