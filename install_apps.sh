#!/bin/bash

# Load environment variables and utility functions if not already loaded
if [ -z "$ENV_LOADED" ]; then
    source "$(dirname "$0")/utils/load_env.sh"
    load_env
    export ENV_LOADED=true
fi

# Load OS detection script if not already loaded
if [ -z "$OS_DETECTED" ]; then
    source "$(dirname "$0")/utils/detect_os.sh"
    export OS_DETECTED=true
fi


# Utils
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/display_menu.sh"

# MAC
source "$(dirname "$0")/mac/install_brew_apps.sh"
source "$(dirname "$0")/mac/install_homebrew.sh"

# Linux
source "$(dirname "$0")/linux/install_flatpak.sh"
source "$(dirname "$0")/linux/update_flatpak_apps.sh"
source "$(dirname "$0")/linux/update_aptget_apps.sh"

install_dialog() {
    # Check if dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y dialog
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install dialog
        else
            echo "Unsupported OS."
            exit 1
        fi
    fi
}

main() {
    # Detect the operating system
    os=$(detect_os)
    echo "Operational System: $os"

    if [[ "$os" == "macOS" ]]; then        
        # Install Homebrew if not installed
        install_homebrew
        install_dialog

        # Display menu and get user choices
        choices=$(display_menu)

        if [[ "$choices" == *"1"* ]]; then
            install_brew_apps $(echo "$INSTALL_APPS_BASIC_MAC" | tr ',' ' ')
        fi
        if [[ "$choices" == *"2"* ]]; then
            install_brew_apps $(echo "$INSTALL_APPS_DEV_MAC" | tr ',' ' ')
        fi
        if [[ "$choices" == *"3"* ]]; then
            install_brew_apps $(echo "$OTHER_APPS_TO_INSTALL_MAC" | tr ',' ' ')
        fi
    elif [[ "$os" == "Linux" ]]; then
        echo "LINUX detected."
        # Update all Flatpak and apt-get packages before installation
        update_flatpak_apps
        update_aptget_apps

        # Display menu and get user choices
        choices=$(display_menu)

        if [[ "$choices" == *"1"* ]]; then
            install_flatpak_apps $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT" | tr ',' ' ')
            install_aptget_apps $(echo "$INSTALL_APPS_BASIC_LINUX_APT" | tr ',' ' ')
        fi
        if [[ "$choices" == *"2"* ]]; then
            install_flatpak_apps $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT_DEV" | tr ',' ' ')
            install_aptget_apps $(echo "$INSTALL_APPS_BASIC_LINUX_APT_DEV" | tr ',' ' ')
        fi
        if [[ "$choices" == *"3"* ]]; then
            install_flatpak_apps $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT" | tr ',' ' ')
            install_flatpak_apps $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT_DEV" | tr ',' ' ')
            install_aptget_apps $(echo "$INSTALL_APPS_BASIC_LINUX_APT" | tr ',' ' ')
            install_aptget_apps $(echo "$INSTALL_APPS_BASIC_LINUX_APT_DEV" | tr ',' ' ')
        fi
    else
        echo "Unsupported OS."
        exit 1
    fi
}

main