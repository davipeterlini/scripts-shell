#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

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
        print_info "Homebrew já está instalado."
    fi
}

_install_karabiner() {
    print_header "Karabiner-Elements"
    
    if brew list --cask karabiner-elements &>/dev/null; then
        print_success "Karabiner-Elements já está instalado."
    else
        print_info "Karabiner-Elements não está instalado."
        if get_user_confirmation "Do you want to install Karabiner-Elements now?"; then
            print_info "Instalando Karabiner-Elements..."
            brew install --cask karabiner-elements
            
            if [ $? -eq 0 ]; then
                print_success "Karabiner-Elements instalado com sucesso!"
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
        print_info "Criando diretório de configuração..."
        mkdir -p "$config_dir"
    fi
    
    return 0
}

_initialize_karabiner_config() {
    print_header "Inicializando configuração do Karabiner-Elements"
    
    local config_file="$HOME/.config/karabiner/karabiner.json"
    local base_config_file="$(dirname "$0")/karabine_config/base_config.json"
    
    # Check if base configuration file exists
    if [ ! -f "$base_config_file" ]; then
        print_error "Arquivo de configuração base não encontrado: $base_config_file"
        exit 1
    fi
    
    # Check if configuration file already exists
    if [ -f "$config_file" ]; then
        print_info "Arquivo de configuração encontrado."
        if get_user_confirmation "Deseja fazer backup da configuração atual?"; then
            local backup_file="${config_file}.backup.$(date +%Y%m%d%H%M%S)"
            cp "$config_file" "$backup_file"
            print_success "Backup criado em: $backup_file"
        fi
        
        # Check if file has the necessary structure
        if ! jq -e '.profiles[0].complex_modifications' "$config_file" > /dev/null 2>&1; then
            print_alert "The existing configuration file does not have the necessary structure."
            if get_user_confirmation "Deseja substituir pelo arquivo de configuração base?"; then
                cp "$base_config_file" "$config_file"
                print_success "Arquivo de configuração substituído com sucesso."
            else
                print_error "Cannot continue without the correct structure. Aborting."
                exit 1
            fi
        fi
    else
        print_info "Criando novo arquivo de configuração..."
        # Copiar o arquivo de configuração base
        cp "$base_config_file" "$config_file"
        print_success "Arquivo de configuração criado em: $config_file"
    fi
    
    # Garantir que a estrutura complex_modifications.rules exista
    local temp_file=$(mktemp)
    jq '
        if .profiles[0].complex_modifications.rules == null then
            .profiles[0].complex_modifications.rules = []
        else
            .
        end
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    return 0
}

_restart_karabiner() {
    print_header "Reiniciando Karabiner-Elements"
    
    if get_user_confirmation "Deseja reiniciar o Karabiner-Elements para aplicar as alterações?"; then
        print_info "Tentando reiniciar o Karabiner-Elements..."
        
        # Método 1: Tentar reiniciar usando launchctl
        if launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server &>/dev/null; then
            print_success "Karabiner-Elements reiniciado com sucesso!"
            return 0
        else
            print_alert "Não foi possível reiniciar o serviço usando launchctl. Tentando método alternativo..."
        fi
        
        # Método 2: Tentar encerrar e reiniciar o aplicativo
        if pkill -f "karabiner"; then
            print_info "Processos do Karabiner encerrados. Reiniciando o aplicativo..."
            sleep 2
        fi
        
        # Abrir o aplicativo Karabiner-Elements
        if open -a "Karabiner-Elements"; then
            print_success "Karabiner-Elements iniciado com sucesso!"
            
            # Dar tempo para o Karabiner-Elements iniciar e detectar os dispositivos
            print_info "Waiting for Karabiner-Elements to initialize (10 seconds)..."
            sleep 10
        else
            print_alert "Não foi possível abrir o Karabiner-Elements automaticamente."
            print_info "Por favor, abra o Karabiner-Elements manualmente para aplicar as alterações."
            print_info "Você pode encontrá-lo na pasta Aplicativos ou usando o Spotlight (Cmd+Espaço)."
        fi
    else
        print_alert "As alterações só terão efeito após reiniciar o Karabiner-Elements."
    fi
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

# Função para verificar se uma regra já existe na configuração
_rule_exists() {
    local config_file="$1"
    local rule_description="$2"
    
    # Verificar se a regra com a mesma descrição já existe
    # Primeiro verificamos se a estrutura complex_modifications.rules existe
    if ! jq -e '.profiles[0].complex_modifications.rules' "$config_file" > /dev/null 2>&1; then
        return 1  # Estrutura não existe, então a regra não existe
    fi
    
    # Agora verificamos se existe uma regra com a descrição especificada
    local existing_rule=$(jq -r --arg desc "$rule_description" '.profiles[0].complex_modifications.rules[] | select(.description == $desc) | .description' "$config_file")
    
    if [ -n "$existing_rule" ]; then
        return 0  # Regra existe
    else
        return 1  # Regra não existe
    fi
}

# Função para remover uma regra existente
_remove_rule() {
    local config_file="$1"
    local rule_description="$2"
    local temp_file=$(mktemp)
    
    # Remover a regra com a descrição especificada
    jq --arg desc "$rule_description" '
        if .profiles[0].complex_modifications.rules != null then
            .profiles[0].complex_modifications.rules = [.profiles[0].complex_modifications.rules[] | select(.description != $desc)]
        else
            .
        end
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    return $?
}

# Função para verificar se o Karabiner-Elements está em execução
_check_karabiner_running() {
    if ! pgrep -q "karabiner"; then
        print_alert "Karabiner-Elements não está em execução."
        if get_user_confirmation "Deseja iniciar o Karabiner-Elements agora?"; then
            print_info "Iniciando Karabiner-Elements..."
            open -a "Karabiner-Elements"
            
            # Dar tempo para o Karabiner-Elements iniciar e detectar os dispositivos
            print_info "Waiting for Karabiner-Elements to initialize (10 seconds)..."
            sleep 10
            
            # Verificar novamente se está em execução
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

# Function to initialize the default profile with all keyboards
_initialize_default_profile_with_all_keyboards() {
    local config_file="$HOME/.config/karabiner/karabiner.json"
    local temp_file=$(mktemp)
    
    print_info "Initializing default profile with all available keyboards..."
    
    # Verificar se o arquivo de configuração existe
    if [ ! -f "$config_file" ]; then
        print_error "Karabiner configuration file not found: $config_file"
        return 1
    fi
    
    # Verificar se há dispositivos na configuração
    if ! jq -e '.devices' "$config_file" > /dev/null 2>&1; then
        print_alert "No devices found in Karabiner configuration."
        print_info "Please wait while Karabiner-Elements detects your devices..."
        return 1
    fi
    
    # Criar uma lista de dispositivos para o perfil padrão
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

# Function to list available keyboards
_list_available_keyboards() {
    print_header "Available Keyboards"
    
    local config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Verificar se o arquivo de configuração existe
    if [ ! -f "$config_file" ]; then
        print_error "Karabiner configuration file not found: $config_file"
        return 1
    fi
    
    # Verificar se o Karabiner-Elements está em execução
    _check_karabiner_running || return 1
    
    # Extrair a lista de dispositivos
    local devices=$(jq -r '.devices[] | select(.is_keyboard == true or .is_keyboard == null) | "\(.vendor_id):\(.product_id):\(.name // "Keyboard without name")"' "$config_file" 2>/dev/null)
    
    if [ -z "$devices" ]; then
        print_alert "Nenhum teclado encontrado na configuração do Karabiner."
        print_info "Please check if your keyboards are connected and if Karabiner-Elements detected them."
        
        # Tentar inicializar o perfil com todos os dispositivos disponíveis
        if get_user_confirmation "Do you want to try using all available devices?"; then
            _initialize_default_profile_with_all_keyboards
            return 0
        else
            return 1
        fi
    fi
    
    # Exibir a lista de teclados
    print_info "The following keyboards are available:"
    echo ""
    
    local count=0
    while IFS=: read -r vendor_id product_id name; do
        count=$((count + 1))
        print_yellow "$count) $name"
        print "   ID: $vendor_id:$product_id"
    done <<< "$devices"
    
    echo ""
    return 0
}

# Function to select a keyboard
_select_keyboard() {
    local config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Extrair a lista de dispositivos
    local devices=$(jq -r '.devices[] | select(.is_keyboard == true or .is_keyboard == null) | "\(.vendor_id):\(.product_id):\(.name // "Keyboard without name")"' "$config_file" 2>/dev/null)
    
    if [ -z "$devices" ]; then
        print_error "Nenhum teclado encontrado na configuração do Karabiner."
        
        # Tentar usar o teclado interno como fallback
        if get_user_confirmation "Do you want to use the internal keyboard as fallback?"; then
            echo "1452:610:Apple Internal Keyboard"
            return 0
        else
            return 1
        fi
    fi
    
    # Contar o número de dispositivos
    local device_count=$(echo "$devices" | wc -l | tr -d ' ')
    
    # Solicitar ao usuário que selecione um teclado
    local selection
    while true; do
        print_info "Enter the number of the keyboard you want to configure (1-$device_count):"
        read -r selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "$device_count" ]; then
            break
        else
            print_error "Invalid selection. Please enter a number between 1 and $device_count."
        fi
    done
    
    # Obter o dispositivo selecionado
    local selected_device=$(echo "$devices" | sed -n "${selection}p")
    
    # Retornar o dispositivo selecionado
    echo "$selected_device"
    return 0
}

# Function to enable a specific keyboard for a profile
_enable_keyboard_for_profile() {
    local config_file="$HOME/.config/karabiner/karabiner.json"
    local device_info="$1"  # formato: vendor_id:product_id:name
    local profile_index="$2"  # índice do perfil (geralmente 0 para o perfil padrão)
    
    # Extrair vendor_id e product_id
    IFS=: read -r vendor_id product_id name <<< "$device_info"
    
    print_info "Enabling keyboard '$name' for the profile..."
    
    # Criar um arquivo temporário
    local temp_file=$(mktemp)
    
    # Verificar se o perfil já tem dispositivos configurados
    local has_devices=$(jq -r --argjson idx "$profile_index" '.profiles[$idx].devices != null' "$config_file")
    
    if [ "$has_devices" = "true" ]; then
        # Adicionar o dispositivo à lista existente
        jq --arg vendor "$vendor_id" --arg product "$product_id" --argjson profile_idx "$profile_index" '
            .profiles[$profile_idx].devices += [
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": $product,
                        "vendor_id": $vendor
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "simple_modifications": []
                }
            ]
        ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    else
        # Criar uma nova lista de dispositivos
        jq --arg vendor "$vendor_id" --arg product "$product_id" --argjson profile_idx "$profile_index" '
            .profiles[$profile_idx].devices = [
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": $product,
                        "vendor_id": $vendor
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "simple_modifications": []
                }
            ]
        ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Keyboard '$name' enabled successfully for the profile!"
        return 0
    else
        print_error "Error enabling keyboard '$name' for the profile."
        return 1
    fi
}

# Generic function to apply a configuration from a JSON file
_apply_config_from_file() {
    local config_file_path="$1"
    local auto_apply="$2"  # Se definido como "yes", aplica automaticamente sem perguntar
    local karabiner_config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Verificar se o arquivo de configuração existe
    if [ ! -f "$config_file_path" ]; then
        print_error "Configuration file not found: $config_file_path"
        return 1
    fi
    
    # Mostrar descrição da configuração
    local title=$(jq -r '.title' "$config_file_path")
    local description=$(jq -r '.rules[0].description' "$config_file_path")
    
    print_header_info "Configuring: $title"
    print_info "Description: $description"
    
    # Verificar se a regra já existe e removê-la automaticamente
    if _rule_exists "$karabiner_config_file" "$description"; then
        print_info "The rule '$description' already exists in the configuration. Removing to overwrite..."
        _remove_rule "$karabiner_config_file" "$description"
    fi
    
    if [ "$auto_apply" = "yes" ] || get_user_confirmation "Do you want to apply this configuration?"; then
        local temp_file=$(mktemp)
        print_info "Adding rule: $description"
        
        # Extrair as regras do arquivo JSON
        local rules=$(jq -c '.rules' "$config_file_path")
        
        # Adicionar as regras ao arquivo de configuração
        jq --argjson new_rules "$rules" '
            if .profiles[0].complex_modifications.rules == null then
                .profiles[0].complex_modifications.rules = $new_rules
            else
                .profiles[0].complex_modifications.rules += $new_rules
            end
        ' "$karabiner_config_file" > "$temp_file" && mv "$temp_file" "$karabiner_config_file"
        
        print_success "Configuration '$title' added successfully!"
    else
        print_alert "Configuration '$title' was not applied."
    fi
}

# Function to list all available configurations
list_available_configs() {
    print_header "Available Configurations"
    
    local config_dir="$(dirname "$0")/karabine_config/configs"
    
    if [ ! -d "$config_dir" ]; then
        print_error "Configurations directory not found: $config_dir"
        return 1
    fi
    
    print_info "The following configurations are available:"
    echo ""
    
    local count=0
    for config_file in "$config_dir"/*.json; do
        if [ -f "$config_file" ]; then
            count=$((count + 1))
            local filename=$(basename "$config_file" .json)
            local title=$(jq -r '.title // "No title"' "$config_file")
            local description=$(jq -r '.rules[0].description // "No description"' "$config_file")
            print_yellow "- $filename: $title"
            print "  $description"
        fi
    done
    
    if [ $count -eq 0 ]; then
        print_alert "No configurations found in directory: $config_dir"
    fi
    
    echo ""
    print "To apply a specific configuration, run:"
    print_yellow "  $0 <nome_da_configuração>"
    echo ""
    print "To apply all configurations, run:"
    print_yellow "  $0 all"
    print ""
    print "To apply all configurations without additional confirmations:"
    print_yellow "  $0 all auto"
}

# Função para aplicar uma configuração específica
apply_config() {
    local config_name="$1"
    local auto_apply="$2"  # Se definido como "yes", aplica automaticamente sem perguntar
    local config_file="$(dirname "$0")/karabine_config/configs/${config_name}.json"
    
    # Verificar se o arquivo existe
    if [ -f "$config_file" ]; then
        _apply_config_from_file "$config_file" "$auto_apply"
    else
        print_error "Configuration '$config_name' not found."
        print_info "Run '$0 list' to see available configurations."
        return 1
    fi
}

# Função para aplicar todas as configurações
apply_all_configs() {
    local auto_apply="$1"  # Se definido como "yes", aplica automaticamente sem perguntar
    local config_dir="$(dirname "$0")/karabine_config/configs"
    
    if [ ! -d "$config_dir" ]; then
        print_error "Configurations directory not found: $config_dir"
        return 1
    fi
    
    local file_count=$(find "$config_dir" -name "*.json" | wc -l | tr -d ' ')
    
    if [ "$file_count" -eq 0 ]; then
        print_alert "No configurations found in directory: $config_dir"
        return 1
    fi
    
    if [ "$auto_apply" = "yes" ] || get_user_confirmation "Do you want to apply ALL $file_count available configurations?"; then
        local count=0
        
        for config_file in "$config_dir"/*.json; do
            if [ -f "$config_file" ]; then
                count=$((count + 1))
                print_header "Configuration $count of $file_count"
                _apply_config_from_file "$config_file" "yes"  # Aplica automaticamente sem perguntar novamente
            fi
        done
        
        print_success "All $count configurations have been processed."
    else
        print_alert "Operation cancelled by user."
    fi
}

# Função para configurar teclados específicos
configure_keyboards() {
    local command="$1"
    local auto_apply="$2"
    
    # Verificar se o Karabiner-Elements está em execução
    _check_karabiner_running || return 1
    
    # Inicializar o perfil padrão com todos os teclados disponíveis
    _initialize_default_profile_with_all_keyboards
    
    # Listar os teclados disponíveis
    _list_available_keyboards || {
        print_alert "Could not list available keyboards."
        print_info "Applying configurations to all keyboards..."
        
        # Aplicar as configurações conforme o comando
        case "$command" in
            "list")
                list_available_configs
                ;;
            "all")
                apply_all_configs "$auto_apply"
                ;;
            *)
                # Verificar se o comando é um nome de arquivo sem extensão
                if [ -f "$(dirname "$0")/karabine_config/configs/${command}.json" ]; then
                    apply_config "$command" "$auto_apply"
                else
                    print_error "Comando ou configuração desconhecida: $command"
                    print_info "Run '$0 list' to see available configurations."
                    return 1
                fi
                ;;
        esac
        
        return 0
    }
    
    # Continuar configurando teclados até que o usuário decida parar
    local continue_config="yes"
    while [ "$continue_config" = "yes" ]; do
        # Selecionar um teclado
        local selected_keyboard=$(_select_keyboard)
        
        if [ -z "$selected_keyboard" ]; then
            print_error "Failed to select keyboard. Aborting."
            return 1
        fi
        
        # Extrair o nome do teclado
        local keyboard_name=$(echo "$selected_keyboard" | cut -d':' -f3)
        print_header "Configuring keyboard: $keyboard_name"
        
        # Habilitar o teclado para o perfil padrão (índice 0)
        _enable_keyboard_for_profile "$selected_keyboard" 0
        
        # Aplicar as configurações conforme o comando
        case "$command" in
            "list")
                list_available_configs
                ;;
            "all")
                apply_all_configs "$auto_apply"
                ;;
            *)
                # Verificar se o comando é um nome de arquivo sem extensão
                if [ -f "$(dirname "$0")/karabine_config/configs/${command}.json" ]; then
                    apply_config "$command" "$auto_apply"
                else
                    print_error "Comando ou configuração desconhecida: $command"
                    print_info "Run '$0 list' to see available configurations."
                    return 1
                fi
                ;;
        esac
        
        # Perguntar se deseja configurar outro teclado
        if ! get_user_confirmation "Do you want to configure another keyboard?"; then
            continue_config="no"
        fi
    done
    
    # Reiniciar o Karabiner-Elements para aplicar as alterações
    _restart_karabiner
    
    return 0
}

setup_karabiner() {
    local command="$1"
    local auto_mode="$2"  # Se definido como "auto", aplica automaticamente sem perguntar
    local auto_apply="no"
    
    if [ "$auto_mode" = "auto" ]; then
        auto_apply="yes"
    fi
    
    _check_brew_installed
    _ensure_jq_installed
    _install_karabiner
    _create_config_directory
    _initialize_karabiner_config
    
    # Se nenhum comando for fornecido, mostrar a lista de configurações
    if [ -z "$command" ]; then
        list_available_configs
        return 0
    fi
    
    # Configurar teclados específicos
    configure_keyboards "$command" "$auto_apply"
    
    print_header "Configuration Completed"
    print_success "Karabiner-Elements has been configured successfully!"
    print_info "If Karabiner-Elements was not automatically restarted, please:"
    print "1. Open the Karabiner-Elements application manually"
    print "2. Check if the configurations were applied correctly"
    print "3. If you are using an external keyboard, you may need to configure it in Karabiner-Elements preferences"
    print "4. Make sure the external keyboard is enabled in the 'Devices' section of Karabiner-Elements"
    print "For language switching configurations to work, check if the keyboard shortcut"
    print "is configured correctly in System Preferences > Keyboard > Shortcuts > Input Sources."
}

# Run the script only if not being imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_karabiner "$@"
fi