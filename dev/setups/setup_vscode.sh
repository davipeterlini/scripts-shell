#!/bin/bash



# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/detect_os.sh"

# Function to read extensions from assets/vscode/extension-list file
_read_vscode_extensions() {
    print_info "Reading VSCode extensions list..."
    local extension_file="$ROOT_DIR/assets/vscode/extension-list"
    
    if [ ! -f "$extension_file" ]; then
        print_error "Extension list file not found at: $extension_file"
        return 1
    fi
    
    print_info "Reading VSCode extensions from $extension_file"
    
    # Initialize empty array for extensions
    VSCODE_EXTENSIONS=()
    
    # Read the file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Extract extension name from the line (remove quotes, spaces, and comments)
        if [[ "$line" =~ \"([^\"]+)\" ]]; then
            extension="${BASH_REMATCH[1]}"
            # Skip commented out extensions
            if [[ ! "$line" =~ ^[[:space:]]*# ]]; then
                VSCODE_EXTENSIONS+=("$extension")
            fi
        fi
    done < "$extension_file"
    
    print_info "Found ${#VSCODE_EXTENSIONS[@]} extensions to install"
    export VSCODE_EXTENSIONS
}

_install_vscode_extensions() {
    print_info "Installing VSCode extensions..."

    for extension in "${VSCODE_EXTENSIONS[@]}"; do
        print_info "Installing extension: $extension"
        code --install-extension "$extension"
    done

    print_success "VSCode extensions installed successfully."
}

_save_vscode_settings() {
    print_info "Saving VSCode global settings..."

    local os=$(detect_os)
    local settings_path
    local source_settings="$ROOT_DIR/assets/vscode/settings.json"

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
        print_error "Please make sure the file exists in the assets/vscode folder."
        exit 1
    fi
}

_save_vscode_keybindings() {
    print_info "Saving VSCode keybindings..."
    
    local os=$(detect_os)
    local keybindings_path
    local source_keybindings="$ROOT_DIR/assets/vscode/keybindings.json"

    case "$os" in
        macOS)
            keybindings_path="$HOME/Library/Application Support/Code/User/keybindings.json"
            ;;
        Linux)
            keybindings_path="$HOME/.config/Code/User/keybindings.json"
            ;;
        Windows)
            keybindings_path="$APPDATA/Code/User/keybindings.json"
            ;;
        *)
            print_error "Unsupported operating system."
            return 1
            ;;
    esac

    if [ -f "$source_keybindings" ]; then
        print_info "Saving VSCode keybindings.json to OS-specific location..."
        mkdir -p "$(dirname "$keybindings_path")"
        cp "$source_keybindings" "$keybindings_path"
        print_success "Keybindings saved to: $keybindings_path"
    else
        print_alert "Source keybindings.json not found at: $source_keybindings"
        print_error "Please make sure the file exists in the assets/vscode folder."
        return 1
    fi
}

setup_vscode() {
    print_header_info "Check Setup VS Code"

    if ! get_user_confirmation "Do you want heck Setup VS Code?"; then
        print_info "Skipping configuration"
        return 0
    fi

    _read_vscode_extensions
    
    _install_vscode_extensions 

    _save_vscode_settings

    _save_vscode_keybindings

    print_info "Setting up VSCode configurations..."
    setup_vscode_config

    print_success "VSCode setup completed successfully."
}

# Run the function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_vscode
fi