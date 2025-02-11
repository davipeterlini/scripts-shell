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

source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/display_menu.sh"
source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/mac/update_brew_apps.sh"
source "$(dirname "$0")/linux/install_flatpak.sh"
source "$(dirname "$0")/linux/install_flatpak_apps.sh"

main() {
    # Detect the operating system
    os=$(detect_os)
    echo "Operational System: $os"

    if [[ "$os" == "macOS" ]]; then
        # Update all Homebrew packages before installation
        update_all_apps_mac
        
        # Install Homebrew if not installed
        install_homebrew

        # Display menu and get user choices
        choices=$(display_menu)

        # Install selected apps
        if [[ "$choices" == *"1"* ]]; then
            ./mac/install_brew_apps.sh $(echo "$INSTALL_APPS_BASIC_MAC" | tr ',' ' ')
        fi
        if [[ "$choices" == *"2"* ]]; then
            ./mac/install_brew_apps.sh $(echo "$INSTALL_APPS_DEV_MAC" | tr ',' ' ')
        fi
        if [[ "$choices" == *"3"* ]]; then
            ./mac/install_brew_apps.sh $(echo "$APPS_TO_INSTALL_MAC" | tr ',' ' ')
        fi
    elif [[ "$os" == "Linux" ]]; then
        # Display menu and get user choices
        choices=$(display_menu)

        # Install selected apps
        if [[ "$choices" == *"1"* ]]; then
            ./linux/install_flatpak_apps.sh $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT" | tr ',' ' ')
            ./linux/install_flatpak_apps.sh $(echo "$INSTALL_APPS_BASIC_LINUX_APT" | tr ',' ' ')
        fi
        if [[ "$choices" == *"2"* ]]; then
            ./linux/install_flatpak_apps.sh $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT_DEV" | tr ',' ' ')
            ./linux/install_flatpak_apps.sh $(echo "$INSTALL_APPS_BASIC_LINUX_APT_DEV" | tr ',' ' ')
        fi
        if [[ "$choices" == *"3"* ]]; then
            ./linux/install_flatpak_apps.sh $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT" | tr ',' ' ')
            ./linux/install_flatpak_apps.sh $(echo "$INSTALL_APPS_BASIC_LINUX_FLAT_DEV" | tr ',' ' ')
        fi
    else
        echo "Unsupported OS."
        exit 1
    fi
}

main