#!/bin/bash

# Load environment variables and utility functions if not already loaded
if [ -z "$ENV_LOADED" ]; then
    source "$(dirname "$0")/utils/load_env.sh"
    load_env
    export ENV_LOADED=true
fi
source "$(dirname "$0")/utils/detect_os.sh"

main() {
    # Detect the operating system
    os=$(detect_os)
    echo "Detected OS: $os"

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