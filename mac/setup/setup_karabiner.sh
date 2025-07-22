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

_find_configs_dir() {
    # Tenta encontrar o diretório de configurações em diferentes locais
    local possible_paths=(
        "$(dirname "$0")/karabine_config/configs"
        "$(dirname "$0")/../mac/setup/karabine_config/configs"
        "$(dirname "$0")/mac/setup/karabine_config/configs"
        "$(pwd)/mac/setup/karabine_config/configs"
    )
    
    for path in "${possible_paths[@]}"; do
        if [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    # Se não encontrar, retorna um caminho absoluto específico
    echo "/Users/$(whoami)/projects-personal/scripts-shell/mac/setup/karabine_config/configs"
    return 0
}

_list_available_configs() {
    local configs_dir=$(_find_configs_dir)
    
    if [ ! -d "$configs_dir" ]; then
        print_error "Configurations directory not found: $configs_dir"
        return 1
    fi
    
    local config_files=("$configs_dir"/*.json)
    local file_count=${#config_files[@]}
    
    if [ $file_count -eq 0 ]; then
        print_alert "No configurations found in directory: $configs_dir"
        return 1
    fi
    
    print_header "Available Configurations"
    print_info "The following configurations are available:"
    echo ""
    
    local count=0
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            count=$((count + 1))
            local title=$(jq -r '.title' "$config_file")
            local description=$(jq -r '.rules[0].description' "$config_file")
            local filename=$(basename "$config_file")
            
            print_info "$count) $title"
            print "   File: $filename"
            print "   Description: $description"
            echo ""
        fi
    done
    
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
        
        # Listar as configurações disponíveis
        print_info "Listing available configurations..."
        _ensure_jq_installed
        _list_available_configs
        
        if get_user_confirmation "Do you want to backup the current configuration?"; then
            local config_file="$HOME/.config/karabiner/karabiner.json"
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
        
        # Listar as configurações disponíveis
        print_info "Listing available configurations..."
        _ensure_jq_installed
        _list_available_configs
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

_check_karabiner_running() {
    if ! pgrep -q "karabiner"; then
        print_alert "Karabiner-Elements is not running."
        if get_user_confirmation "Do you want to start Karabiner-Elements now?"; then
            print_info "Starting Karabiner-Elements..."
            open -a "Karabiner-Elements"
            
            # Give time for Karabiner-Elements to start and detect devices
            print_info "Waiting for Karabiner-Elements to initialize (10 seconds)..."
            sleep 10
            
            # Check again if it's running
            if ! pgrep -q "karabiner"; then
                print_error "Could not start Karabiner-Elements. Please start it manually."
                return 1
            fi
        else
            print_error "Karabiner-Elements needs to be running to continue. Aborting."
            return 1
        fi
    fi
    
    return 0
}

_list_available_keyboards() {
    print_header "Available Keyboards"
    
    local config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Check if the configuration file exists
    if [ ! -f "$config_file" ]; then
        print_error "Karabiner configuration file not found: $config_file"
        return 1
    fi
    
    # Check if Karabiner-Elements is running
    _check_karabiner_running || return 1
    
    # Extract the list of devices
    local devices=$(jq -r '.devices[] | select(.is_keyboard == true or .is_keyboard == null) | "\(.vendor_id):\(.product_id):\(.name // "Keyboard without name")"' "$config_file" 2>/dev/null)
    
    if [ -z "$devices" ]; then
        print_alert "No keyboards found in Karabiner configuration."
        print_info "Please check if your keyboards are connected and if Karabiner-Elements detected them."
        print_info "Applying all configurations automatically since no keyboards were detected..."
        _apply_all_configs
        return 2  # Return code 2 indicates no keyboards found but configs applied
    fi
    
    # Display the list of keyboards
    print_info "The following keyboards are available:"
    echo ""
    
    local count=0
    while IFS=: read -r vendor_id product_id name; do
        count=$((count + 1))
        print_alert "$count) $name"
        print "   ID: $vendor_id:$product_id"
    done <<< "$devices"
    
    echo ""
    return 0
}

_initialize_default_profile_with_all_keyboards() {
    local config_file="$HOME/.config/karabiner/karabiner.json"
    local temp_file=$(mktemp)
    
    print_info "Initializing default profile with all available keyboards..."
    
    # Check if the configuration file exists
    if [ ! -f "$config_file" ]; then
        print_error "Karabiner configuration file not found: $config_file"
        return 1
    fi
    
    # Check if there are devices in the configuration
    if ! jq -e '.devices' "$config_file" > /dev/null 2>&1 || [ "$(jq '.devices | length' "$config_file")" -eq 0 ]; then
        print_alert "No devices found in Karabiner configuration."
        print_info "Creating a default profile without specific device settings."
        
        # Create a default profile without specific device settings
        jq '
            if .profiles[0].name == null then
                .profiles[0].name = "Default profile"
            else
                .
            end
        ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
        
        print_success "Default profile initialized without specific device settings."
        print_info "Configurations will be applied to all connected keyboards."
        return 0
    fi
    
    # Create a list of devices for the default profile
    jq '
        if .devices then
            .profiles[0].devices = [
                .devices[] | 
                select(.is_keyboard == true or .is_keyboard == null) | 
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": .product_id,
                        "vendor_id": .vendor_id
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "simple_modifications": []
                }
            ]
        else
            .
        end
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    if [ $? -eq 0 ]; then
        print_success "Default profile initialized with all available keyboards!"
        return 0
    else
        print_error "Error initializing the default profile."
        return 1
    fi
}

_rule_exists() {
    local config_file="$1"
    local rule_description="$2"
    
    # Check if a rule with the same description already exists
    # First we check if the complex_modifications.rules structure exists
    if ! jq -e '.profiles[0].complex_modifications.rules' "$config_file" > /dev/null 2>&1; then
        return 1  # Structure doesn't exist, so the rule doesn't exist
    fi
    
    # Now we check if there's a rule with the specified description
    local existing_rule=$(jq -r --arg desc "$rule_description" '.profiles[0].complex_modifications.rules[] | select(.description == $desc) | .description' "$config_file")
    
    if [ -n "$existing_rule" ]; then
        return 0  # Rule exists
    else
        return 1  # Rule doesn't exist
    fi
}

_remove_rule() {
    local config_file="$1"
    local rule_description="$2"
    local temp_file=$(mktemp)
    
    # Remove the rule with the specified description
    jq --arg desc "$rule_description" '
        if .profiles[0].complex_modifications.rules != null then
            .profiles[0].complex_modifications.rules = [.profiles[0].complex_modifications.rules[] | select(.description != $desc)]
        else
            .
        end
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    return $?
}

_ensure_complex_modifications_structure() {
    local config_file="$1"
    local temp_file=$(mktemp)
    
    # Ensure the complex_modifications structure exists
    jq '
        if .profiles[0].complex_modifications == null then
            .profiles[0].complex_modifications = {"rules": []}
        elif .profiles[0].complex_modifications.rules == null then
            .profiles[0].complex_modifications.rules = []
        else
            .
        end
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    return $?
}

_apply_config_from_file() {
    local config_file_path="$1"
    local karabiner_config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Check if the configuration file exists
    if [ ! -f "$config_file_path" ]; then
        print_error "Configuration file not found: $config_file_path"
        return 1
    fi
    
    # Show configuration description
    local title=$(jq -r '.title' "$config_file_path")
    local description=$(jq -r '.rules[0].description' "$config_file_path")
    
    print_header_info "Configuring: $title"
    print_info "Description: $description"
    
    # Ensure the complex_modifications structure exists
    _ensure_complex_modifications_structure "$karabiner_config_file"
    
    # Check if the rule already exists and remove it automatically
    if _rule_exists "$karabiner_config_file" "$description"; then
        print_info "The rule '$description' already exists in the configuration. Removing to overwrite..."
        _remove_rule "$karabiner_config_file" "$description"
    fi
    
    local temp_file=$(mktemp)
    print_info "Adding rule: $description"
    
    # Extract the rules from the JSON file
    local rules=$(jq -c '.rules' "$config_file_path")
    
    # Add the rules to the configuration file
    jq --argjson new_rules "$rules" '
        if .profiles[0].complex_modifications.rules == null then
            .profiles[0].complex_modifications.rules = $new_rules
        else
            .profiles[0].complex_modifications.rules += $new_rules
        end
    ' "$karabiner_config_file" > "$temp_file" && mv "$temp_file" "$karabiner_config_file"
    
    print_success "Configuration '$title' added successfully!"
}

_apply_selected_configs() {
    local configs_dir=$(_find_configs_dir)
    
    if [ ! -d "$configs_dir" ]; then
        print_error "Configurations directory not found: $configs_dir"
        return 1
    fi
    
    local config_files=("$configs_dir"/*.json)
    local file_count=${#config_files[@]}
    
    if [ $file_count -eq 0 ]; then
        print_alert "No configurations found in directory: $configs_dir"
        return 1
    fi
    
    # Mostrar as configurações disponíveis
    _list_available_configs
    
    # Solicitar ao usuário que escolha as configurações
    print_info "Enter the numbers of the configurations you want to apply (e.g., '1 3 5'), 'a' for all, or 'q' to quit:"
    read -r selection
    
    # Verificar se o usuário quer sair
    if [[ "$selection" == "q" ]]; then
        print_info "No configurations applied."
        return 0
    fi
    
    # Verificar se o usuário quer aplicar todas as configurações
    if [[ "$selection" == "a" ]]; then
        _apply_all_configs
        return $?
    fi
    
    # Aplicar as configurações selecionadas
    local selected_indices=($selection)
    local applied_count=0
    
    for index in "${selected_indices[@]}"; do
        # Verificar se o índice é um número válido
        if ! [[ "$index" =~ ^[0-9]+$ ]]; then
            print_error "Invalid selection: $index. Must be a number."
            continue
        fi
        
        # Verificar se o índice está dentro do intervalo válido
        if [ "$index" -lt 1 ] || [ "$index" -gt $file_count ]; then
            print_error "Invalid selection: $index. Must be between 1 and $file_count."
            continue
        fi
        
        # Aplicar a configuração selecionada
        local config_file="${config_files[$((index-1))]}"
        print_header "Applying configuration $index of $file_count"
        _apply_config_from_file "$config_file"
        applied_count=$((applied_count + 1))
    done
    
    if [ $applied_count -gt 0 ]; then
        print_success "Applied $applied_count configuration(s)."
        # Reiniciar o Karabiner automaticamente após aplicar as configurações
        _restart_karabiner_auto
    else
        print_alert "No configurations were applied."
    fi
    
    return 0
}

_apply_all_configs() {
    # Encontrar o diretório de configurações
    local configs_dir=$(_find_configs_dir)
    
    if [ ! -d "$configs_dir" ]; then
        print_error "Configurations directory not found: $configs_dir"
        return 1
    fi
    
    local file_count=$(find "$configs_dir" -name "*.json" | wc -l | tr -d ' ')
    
    if [ "$file_count" -eq 0 ]; then
        print_alert "No configurations found in directory: $configs_dir"
        return 1
    fi
    
    print_info "Applying $file_count configurations from $configs_dir..."
    
    local count=0
    for config_file in "$configs_dir"/*.json; do
        if [ -f "$config_file" ]; then
            count=$((count + 1))
            print_header "Configuration $count of $file_count"
            _apply_config_from_file "$config_file"
        fi
    done
    
    print_success "All $count configurations have been applied."
    
    # Reiniciar o Karabiner automaticamente após aplicar as configurações
    _restart_karabiner_auto
    
    return 0
}

# Função para reiniciar o Karabiner automaticamente sem perguntar ao usuário
_restart_karabiner_auto() {
    print_header "Restarting Karabiner-Elements"
    print_info "Restarting Karabiner-Elements to apply the changes..."
    
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
}

# Função original que pergunta ao usuário se deseja reiniciar
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
    
    # Verificar se o Karabiner está em execução
    _check_karabiner_running
    
    # Inicializar o perfil padrão com todos os teclados disponíveis
    _initialize_default_profile_with_all_keyboards
    
    # Listar os teclados disponíveis
    _list_available_keyboards
    
    # Perguntar ao usuário como deseja aplicar as configurações
    print_header "Configuration Options"
    print_info "How would you like to apply the configurations?"
    print_info "1) Apply all configurations"
    print_info "2) Select specific configurations to apply"
    print_info "3) Skip applying configurations"
    
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            _apply_all_configs
            ;;
        2)
            _apply_selected_configs
            ;;
        3)
            print_info "Skipping configuration application."
            ;;
        *)
            print_error "Invalid choice. Skipping configuration application."
            ;;
    esac
    
    print_header "Configuration Completed"
    print_success "Karabiner-Elements has been configured successfully!"
    print_info "You can now open Karabiner-Elements to customize your keyboard settings."
    print_info "For more information, visit: https://karabiner-elements.pqrs.org/docs/"
}

# Função para aplicar uma configuração específica pelo nome do arquivo
apply_specific_config() {
    local config_name="$1"
    local configs_dir=$(_find_configs_dir)
    
    if [ ! -d "$configs_dir" ]; then
        print_error "Configurations directory not found: $configs_dir"
        return 1
    fi
    
    local config_file="$configs_dir/$config_name"
    
    # Verificar se o arquivo existe
    if [ ! -f "$config_file" ]; then
        # Tentar adicionar a extensão .json se não foi fornecida
        if [ ! -f "${config_file}.json" ]; then
            print_error "Configuration file not found: $config_name"
            return 1
        else
            config_file="${config_file}.json"
        fi
    fi
    
    # Verificar se o Karabiner está em execução
    _check_karabiner_running
    
    # Inicializar o perfil padrão com todos os teclados disponíveis
    _initialize_default_profile_with_all_keyboards
    
    # Aplicar a configuração específica
    print_header "Applying specific configuration: $(basename "$config_file")"
    _apply_config_from_file "$config_file"
    
    # Reiniciar o Karabiner automaticamente para aplicar as alterações
    _restart_karabiner_auto
    
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Verificar se foi passado um parâmetro específico
    if [ $# -gt 0 ]; then
        # Verificar se é para listar as configurações disponíveis
        if [ "$1" == "--list" ] || [ "$1" == "-l" ]; then
            _check_brew_installed
            _ensure_jq_installed
            _list_available_configs
        # Verificar se é para aplicar uma configuração específica
        elif [ "$1" == "--apply" ] || [ "$1" == "-a" ]; then
            if [ -z "$2" ]; then
                print_error "No configuration specified. Usage: $0 --apply <config_name>"
                exit 1
            fi
            _check_brew_installed
            _ensure_jq_installed
            _install_karabiner
            _create_config_directory
            _initialize_karabiner_config
            apply_specific_config "$2"
        else
            # Assumir que o primeiro parâmetro é o nome da configuração
            _check_brew_installed
            _ensure_jq_installed
            _install_karabiner
            _create_config_directory
            _initialize_karabiner_config
            apply_specific_config "$1"
        fi
    else
        # Sem parâmetros, executar o setup completo
        setup_karabiner
    fi
fi