#!/bin/bash

# Get the script directory and find project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Utils
source "$PROJECT_ROOT/utils/colors_message.sh"
source "$PROJECT_ROOT/utils/load_env.sh"
source "$PROJECT_ROOT/utils/detect_os.sh"
source "$PROJECT_ROOT/utils/bash_tools.sh"

# Set ROOT_DIR for compatibility with existing functions
export ROOT_DIR="$PROJECT_ROOT"

_check_vscode_installed() {
    print_info "Checking if Visual Studio Code is installed..."
    local vscode_found=false

    # Check for VS Code in PATH
    if command -v code > /dev/null 2>&1; then
        vscode_found=true
        print_success "Visual Studio Code is installed (command 'code')"
        print_info "VS Code version: $(code --version | head -n 1)"
    elif command -v code-insiders > /dev/null 2>&1; then
        vscode_found=true
        print_success "Visual Studio Code Insiders is installed"
        print_info "VS Code Insiders version: $(code-insiders --version | head -n 1)"
    # Check for VS Code app on macOS
    elif [[ "$OSTYPE" == "darwin"* ]] && [ -d "/Applications/Visual Studio Code.app" ]; then
        vscode_found=true
        print_success "Visual Studio Code is installed (macOS application)"
    fi

    if $vscode_found; then
        return 0
    else
        print_error "Visual Studio Code is not installed."
        print_info "Please install VSCode first using the setup_ides script or manually from https://code.visualstudio.com/download"
        return 1
    fi
}

_save_vscode_settings() {
    print_info "Saving VSCode global settings..."
    local os=$1
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
    
    local os=$1
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

setup_vscode() {
    print_header_info "Check Setup VS Code"

    if ! get_user_confirmation "Do you want to check Setup VS Code?"; then
        print_info "Skipping configuration"
        return 0
    fi

    # First, check if VSCode is installed
    if ! _check_vscode_installed; then
        print_error "Cannot proceed with VSCode setup. VSCode is not installed."
        print_info "Please run the setup_ides script first to install VSCode."
        return 1
    fi

    detect_os

    _save_vscode_settings "$os"

    _save_vscode_keybindings "$os"

    # Function to read extensions from assets/vscode/extension-list file
    _read_vscode_extensions

    _install_vscode_extensions 

    print_info "Setting up VSCode configurations..."

    print_success "VSCode setup completed successfully."
}

# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_vscode "$@"
fi