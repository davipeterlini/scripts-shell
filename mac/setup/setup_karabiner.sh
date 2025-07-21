#!/bin/bash

# Corrigindo os caminhos para os arquivos de utilitários
if [[ -f "$(dirname "$0")/../utils/colors_message.sh" ]]; then
    source "$(dirname "$0")/../utils/colors_message.sh"
else
    source "$(dirname "$0")/utils/colors_message.sh"
fi

if [[ -f "$(dirname "$0")/../utils/bash_tools.sh" ]]; then
    source "$(dirname "$0")/../utils/bash_tools.sh"
else
    source "$(dirname "$0")/utils/bash_tools.sh"
fi

_check_brew_installed() {
    if ! command -v brew &> /dev/null; then
        print_alert "Homebrew is not installed."
        if get_user_confirmation "Do you want to install Homebrew now?"; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            print_error "Homebrew is required to continue. Aborting."
            exit 1
        fi
    else
        print_info "Homebrew is already installed."
    fi
}

_install_karabiner() {
    print_header_info "Karabiner-Elements"
    
    if brew list --cask karabiner-elements &>/dev/null; then
        print_success "Karabiner-Elements is already installed."
    else
        print_info "Karabiner-Elements is not installed."
        if get_user_confirmation "Do you want to install Karabiner-Elements now?"; then
            print_info "Installing Karabiner-Elements..."
            brew install --cask karabiner-elements
            
            if [ $? -eq 0 ]; then
                print_success "Karabiner-Elements installed successfully!"
            else
                print_error "Error installing Karabiner-Elements."
                exit 1
            fi
        else
            print_error "Karabiner-Elements is required to continue. Aborting."
            exit 1
        fi
    fi
}

_create_config_directory() {
    local config_dir="$HOME/.config/karabiner"
    
    if [ ! -d "$config_dir" ]; then
        print_info "Creating configuration directory..."
        mkdir -p "$config_dir"
    fi
    
    return 0
}

_find_base_config_file() {
    # Tenta encontrar o arquivo de configuração base em diferentes locais
    local possible_paths=(
        "$(dirname "$0")/karabine_config/base_config.json"
        "$(dirname "$0")/../mac/setup/karabine_config/base_config.json"
        "$(dirname "$0")/mac/setup/karabine_config/base_config.json"
        "$(pwd)/mac/setup/karabine_config/base_config.json"
    )
    
    for path in "${possible_paths[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    # Se não encontrar, retorna um caminho absoluto específico
    echo "/Users/$(whoami)/projects-personal/scripts-shell/mac/setup/karabine_config/base_config.json"
    return 0
}

_initialize_karabiner_config() {
    print_info "Initializing Karabiner-Elements configuration"
    
    local config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Tenta encontrar o arquivo de configuração base
    local base_config_file=$(_find_base_config_file)
    
    # Check if base configuration file exists
    if [ ! -f "$base_config_file" ]; then
        print_error "Base configuration file not found: $base_config_file"
        exit 1
    fi
    
    # Check if configuration file already exists
    if [ -f "$config_file" ]; then
        print_info "Configuration file found."
        if get_user_confirmation "Do you want to backup the current configuration?"; then
            local backup_file="${config_file}.backup.$(date +%Y%m%d%H%M%S)"
            cp "$config_file" "$backup_file"
            print_success "Backup created at: $backup_file"
        fi
        
        # Substituir o arquivo de configuração existente
        if get_user_confirmation "Do you want to replace with the base configuration file?"; then
            cp "$base_config_file" "$config_file"
            print_success "Configuration file replaced successfully."
        else
            print_info "Keeping existing configuration file."
        fi
    else
        print_info "Creating new configuration file..."
        # Copy the base configuration file
        cp "$base_config_file" "$config_file"
        print_success "Configuration file created at: $config_file"
    fi
    
    return 0
}

_ensure_jq_installed() {
    if ! command -v jq &> /dev/null; then
        print_alert "jq is not installed."
        if get_user_confirmation "Do you want to install jq now? (required to process JSON files)"; then
            print_info "Installing jq..."
            brew install jq
        else
            print_error "jq is required to continue. Aborting."
            exit 1
        fi
    fi
}

_restart_karabiner() {
    print_header "Restarting Karabiner-Elements"
    
    if get_user_confirmation "Do you want to restart Karabiner-Elements to apply the changes?"; then
        print_info "Trying to restart Karabiner-Elements..."
        
        # Method 1: Try to restart using launchctl
        if launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server &>/dev/null; then
            print_success "Karabiner-Elements restarted successfully!"
            return 0
        else
            print_alert "Could not restart the service using launchctl. Trying alternative method..."
        fi
        
        # Method 2: Try to quit and restart the application
        if pkill -f "karabiner"; then
            print_info "Karabiner processes terminated. Restarting the application..."
            sleep 2
        fi
        
        # Open the Karabiner-Elements application
        if open -a "Karabiner-Elements"; then
            print_success "Karabiner-Elements started successfully!"
            
            # Give time for Karabiner-Elements to start and detect devices
            print_info "Waiting for Karabiner-Elements to initialize (5 seconds)..."
            sleep 5
        else
            print_alert "Could not open Karabiner-Elements automatically."
            print_info "Please open Karabiner-Elements manually to apply the changes."
            print_info "You can find it in the Applications folder or using Spotlight (Cmd+Space)."
        fi
    else
        print_alert "The changes will only take effect after restarting Karabiner-Elements."
    fi
}

setup_karabiner() {
    if ! get_user_confirmation "Do you want to setup Karabiner-Elements?"; then
        print_info "Skipping Karabiner-Elements configuration"
        return 0
    fi
    
    _check_brew_installed
    _ensure_jq_installed
    _install_karabiner
    _create_config_directory
    _initialize_karabiner_config
    _restart_karabiner
    
    print_header "Configuration Completed"
    print_success "Karabiner-Elements has been configured successfully!"
    print_info "You can now open Karabiner-Elements to customize your keyboard settings."
    print_info "For more information, visit: https://karabiner-elements.pqrs.org/docs/"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_karabiner "$@"
fi