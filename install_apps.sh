#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/utils/load_env.sh"
load_env
source "$(dirname "$0")/utils/display_menu.sh"
source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/utils/detect_os.sh"

# Function to install apps on Linux
install_apps_linux() {
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

# Function to install apps on macOS
install_apps_mac() {
    # Install Homebrew if not installed
    install_homebrew
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

main() {
    # Detect the operating system
    os=$(detect_os)
    echo "Detected OS: $os"

    # Display menu and get user choices
    choices=$(display_menu)

    # Install selected apps based on OS and user choices
    if [[ "$os" == "macOS" ]]; then
        [[ "$choices" == *"1"* ]] && install_apps_mac $(echo "$INSTALL_APPS_BASIC_MAC" | tr ',' ' ')
        [[ "$choices" == *"2"* ]] && install_apps_mac $(echo "$INSTALL_APPS_DEV_MAC" | tr ',' ' ')
        [[ "$choices" == *"3"* ]] && install_apps_mac $(echo "$APPS_TO_INSTALL_MAC" | tr ',' ' ')
    elif [[ "$os" == "Linux" ]]; then
        [[ "$choices" == *"1"* ]] && install_apps_linux $(echo "$INSTALL_APPS_BASIC_LINUX_APT" | tr ',' ' ')
        [[ "$choices" == *"2"* ]] && install_apps_linux $(echo "$INSTALL_APPS_BASIC_LINUX_APT_DEV" | tr ',' ' ')
        [[ "$choices" == *"3"* ]] && install_apps_linux $(echo "$INSTALL_APPS_BASIC_LINUX_APT,$INSTALL_APPS_BASIC_LINUX_APT_DEV" | tr ',' ' ')
    else
        echo "Unsupported OS."
        exit 1
    fi
}

main