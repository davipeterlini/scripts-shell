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

# Function to set up VSCode configurations
setup_vscode_config() {
    local vscode_settings_dir="$HOME/.config/Code/User"
    local vscode_settings_file="$vscode_settings_dir/settings.json"
    local vscode_extensions_file="$vscode_settings_dir/extensions.json"

    # Create VSCode settings directory if it doesn't exist
    mkdir -p "$vscode_settings_dir"

    # Write VSCode settings
    cat > "$vscode_settings_file" <<EOL
{
    "terminal.integrated.tabs.enabled": true,
    "terminal.integrated.tabs.location": "left",
    "terminal.integrated.splitCwd": "inherited",
    "terminal.integrated.cwd": "\${workspaceFolder}",
    "terminal.integrated.persistentSessionScrollback": true,
    "terminal.integrated.persistentSessionRestore": true,
    "terminal.integrated.enablePersistentSessions": true
}
EOL

# TODO - precisa arrumar isso para pegar da forma correta
    # Write VSCode extensions recommendations
vscode_extensions_file=".vscode/extensions.json"
    cat > "$vscode_extensions_file" <<EOL
{
    "recommendations": [
        $(echo $VSCODE_EXTENSIONS | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')
    ]
}
EOL
}

# Main script execution
setup_vscode() {
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