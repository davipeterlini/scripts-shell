#!/bin/bash

# ====================================
# Karabiner Elements Setup Script
# ====================================
# Este script instala Karabiner-Elements e configura regras personalizadas
# a partir dos arquivos na pasta karabine_config

# ====================================
# Private Functions
# ====================================

_print_header() {
    echo "============================================"
    echo "$1"
    echo "============================================"
}

_check_brew_installed() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew não está instalado. Instalando..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew já está instalado."
    fi
}

_install_karabiner() {
    _print_header "Instalando Karabiner-Elements"
    
    if brew list --cask karabiner-elements &>/dev/null; then
        echo "Karabiner-Elements já está instalado."
    else
        echo "Instalando Karabiner-Elements..."
        brew install --cask karabiner-elements
        
        if [ $? -eq 0 ]; then
            echo "Karabiner-Elements instalado com sucesso!"
        else
            echo "Erro ao instalar Karabiner-Elements."
            exit 1
        fi
    fi
}

_create_config_directory() {
    local config_dir="$HOME/.config/karabiner"
    
    if [ ! -d "$config_dir" ]; then
        echo "Criando diretório de configuração..."
        mkdir -p "$config_dir"
    fi
    
    return 0
}

_initialize_karabiner_config() {
    _print_header "Inicializando configuração do Karabiner-Elements"
    
    local config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Verificar se o arquivo de configuração já existe
    if [ -f "$config_file" ]; then
        echo "Arquivo de configuração encontrado. Fazendo backup..."
        cp "$config_file" "${config_file}.backup.$(date +%Y%m%d%H%M%S)"
    else
        echo "Criando novo arquivo de configuração..."
        # Criar estrutura básica do arquivo de configuração
        cat > "$config_file" << EOF
{
    "global": {
        "check_for_updates_on_startup": true,
        "show_in_menu_bar": true,
        "show_profile_name_in_menu_bar": false
    },
    "profiles": [
        {
            "name": "Default profile",
            "selected": true,
            "simple_modifications": [],
            "complex_modifications": {
                "parameters": {
                    "basic.simultaneous_threshold_milliseconds": 50,
                    "basic.to_delayed_action_delay_milliseconds": 500,
                    "basic.to_if_alone_timeout_milliseconds": 1000,
                    "basic.to_if_held_down_threshold_milliseconds": 500,
                    "mouse_motion_to_scroll.speed": 100
                },
                "rules": []
            },
            "devices": [],
            "fn_function_keys": [],
            "virtual_hid_keyboard": {
                "country_code": 0,
                "mouse_key_xy_scale": 100
            }
        }
    ]
}
EOF
    fi
    
    return 0
}

_restart_karabiner() {
    _print_header "Reiniciando Karabiner-Elements"
    
    # Verificar se o Karabiner está em execução
    if pgrep -x "karabiner_console_user_server" > /dev/null; then
        echo "Reiniciando Karabiner-Elements..."
        launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server
        echo "Karabiner-Elements reiniciado com sucesso!"
    else
        echo "Iniciando Karabiner-Elements..."
        open -a "Karabiner-Elements"
        echo "Karabiner-Elements iniciado!"
    fi
}

_ensure_jq_installed() {
    if ! command -v jq &> /dev/null; then
        echo "jq não está instalado. Instalando..."
        brew install jq
    fi
}

# ====================================
# Config Functions - Cada função corresponde a um arquivo na pasta karabine_config
# ====================================

fn_input_switcher() {
    _print_header "Configurando: Use fn to switch input source"
    
    local config_file="$HOME/.config/karabiner/karabiner.json"
    local config_json_file="$(dirname "$0")/karabine_config/fn_input_switcher.json"
    local temp_file=$(mktemp)
    
    echo "Adicionando regra para usar fn para alternar fonte de entrada..."
    
    # Extrair as regras do arquivo JSON
    local rules=$(jq -c '.rules' "$config_json_file")
    
    # Adicionar as regras ao arquivo de configuração
    jq --argjson new_rules "$rules" '.profiles[0].complex_modifications.rules += $new_rules' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    echo "Configuração 'Use fn to switch input source' adicionada com sucesso!"
}

# Função para listar todas as configurações disponíveis
list_available_configs() {
    _print_header "Configurações Disponíveis"
    
    local config_dir="$(dirname "$0")/karabine_config"
    
    if [ ! -d "$config_dir" ]; then
        echo "Diretório de configurações não encontrado: $config_dir"
        return 1
    fi
    
    echo "As seguintes configurações estão disponíveis:"
    echo ""
    
    for config_file in "$config_dir"/*.json; do
        if [ -f "$config_file" ]; then
            local filename=$(basename "$config_file" .json)
            local title=$(jq -r '.title' "$config_file")
            echo "- $filename: $title"
        fi
    done
    
    echo ""
    echo "Para aplicar uma configuração específica, execute:"
    echo "  $0 <nome_da_configuração>"
    echo ""
    echo "Para aplicar todas as configurações, execute:"
    echo "  $0 all"
}

# Função para aplicar uma configuração específica
apply_config() {
    local config_name="$1"
    local function_name="${config_name}"
    
    # Verificar se a função existe
    if type "$function_name" &>/dev/null; then
        "$function_name"
    else
        echo "Erro: Configuração '$config_name' não encontrada."
        echo "Execute '$0 list' para ver as configurações disponíveis."
        return 1
    fi
}

# Função para aplicar todas as configurações
apply_all_configs() {
    local config_dir="$(dirname "$0")/karabine_config"
    
    if [ ! -d "$config_dir" ]; then
        echo "Diretório de configurações não encontrado: $config_dir"
        return 1
    fi
    
    for config_file in "$config_dir"/*.json; do
        if [ -f "$config_file" ]; then
            local filename=$(basename "$config_file" .json)
            apply_config "$filename"
        fi
    done
}

# ====================================
# Public Functions
# ====================================

setup_karabiner() {
    local command="$1"
    
    _check_brew_installed
    _install_karabiner
    _create_config_directory
    _initialize_karabiner_config
    _ensure_jq_installed
    
    # Se nenhum comando for fornecido, mostrar a lista de configurações
    if [ -z "$command" ]; then
        list_available_configs
        return 0
    fi
    
    # Processar o comando
    case "$command" in
        "list")
            list_available_configs
            ;;
        "all")
            apply_all_configs
            _restart_karabiner
            ;;
        *)
            apply_config "$command"
            _restart_karabiner
            ;;
    esac
    
    _print_header "Configuração Concluída"
    echo "Karabiner-Elements foi configurado com sucesso!"
}

# Executar o script apenas se não estiver sendo importado
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_karabiner "$@"
fi