#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/utils/load_env.sh"
load_env
source "$(dirname "$0")/utils/display_menu.sh"
source "$(dirname "$0")/utils/install_homebrew.sh"
source "$(dirname "$0")/utils/detect_os.sh"

# Function to install apps on Linux
install_apps_linux() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        sudo apt-get install -y "$app"
    done
}

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
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        IFS=',' read -r -a basic_apps <<< "$INSTALL_APPS_BASIC_LINUX_APT"
        install_apps_linux "${basic_apps[@]}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        IFS=',' read -r -a basic_apps <<< "$INSTALL_APPS_BASIC_MAC"
        install_apps_mac "${basic_apps[@]}"
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# Function to install development apps
install_dev_apps() {
    echo "Installing development apps..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        IFS=',' read -r -a dev_apps <<< "$INSTALL_APPS_BASIC_LINUX_APT_DEV"
        install_apps_linux "${dev_apps[@]}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        IFS=',' read -r -a dev_apps <<< "$INSTALL_APPS_DEV_MAC"
        install_apps_mac "${dev_apps[@]}"
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# Function to install all macOS apps
install_all_mac_apps() {
    echo "Installing all macOS apps..."
    IFS=',' read -r -a mac_apps <<< "$APPS_TO_INSTALL_MAC"
    install_apps_mac "${mac_apps[@]}"
}

main() {
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