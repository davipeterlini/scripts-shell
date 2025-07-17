#!/bin/bash

# TODO - aplicar o autosave 
# TODO - aplicar o wrapper de linha

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/save_vscode_settings.sh"

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
        print_info "Saving VSCode settings.json to OS-specific location..."
        mkdir -p "$(dirname "$settings_path")"
        cp "$source_settings" "$settings_path"
        print_success "Settings saved to: $settings_path"
    else
        print_alert "Source settings.json not found at: $source_settings"
        print_error "Please make sure the file exists in the .vscode folder."
        exit 1
    fi
}

setup_vscode() {
    print_header_info "Setup VS Code Configuration"

    print_info "Install Extension in VSCode..."
    install_vscode_extensions 

    print_info "Saving VSCode global settings..."
    save_vscode_settings

    print_info "Setting up VSCode configurations..."
    setup_vscode_config



    echo "VSCode setup completed successfully."
}

# Run the function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_vscode
fi