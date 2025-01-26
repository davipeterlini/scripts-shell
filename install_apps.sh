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

main() {
    # Detect the operating system
    os=$(detect_os)
    echo "Operational System: $os"

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