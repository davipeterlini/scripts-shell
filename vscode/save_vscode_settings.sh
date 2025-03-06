#!/bin/bash

# Load the detect_os function
source "$(dirname "$0")/../utils/detect_os.sh"

# Function to save VSCode settings.json to the OS-specific location
save_vscode_settings() {
    local os=$(detect_os)
    local settings_path
    local source_settings="../.vscode/settings.json"

    case "$os" in
        macOS)
            settings_path="$HOME/Library/Application Support/Code/User/settings.json"
            ;;
        Linux)
            settings_path="$HOME/.config/Code/User/settings.json"
            ;;
        Windows)
            settings_path="$APPDATA/Code/User/settings.json"
            ;;
        *)
            echo "Unsupported operating system."
            exit 1
            ;;
    esac

    if [ -f "$source_settings" ]; then
        echo "Saving VSCode settings.json to OS-specific location..."
        mkdir -p "$(dirname "$settings_path")"
        cp "$source_settings" "$settings_path"
        echo "Settings saved to: $settings_path"
    else
        echo "Source settings.json not found at: $source_settings"
        echo "Please make sure the file exists in the .vscode folder."
        exit 1
    fi
}

# Run the function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    save_vscode_settings
fi