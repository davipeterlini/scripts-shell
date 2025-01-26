#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/utils/load_env.sh"
load_env
source "$(dirname "$0")/utils/display_menu.sh"
source "$(dirname "$0")/utils/detect_os.sh"

main() {
    # Detect the operating system
    os=$(detect_os)
    echo "Detected OS: $os"

    # Display menu and get user choices
    choices=$(display_menu)

    # Install selected apps based on OS and user choices
    if [[ "$os" == "macOS" ]]; then
        ./mac/install_apps.sh
    elif [[ "$os" == "Linux" ]]; then
        ./linux/install_apps.sh
    else
        echo "Unsupported OS."
        exit 1
    fi
}

main