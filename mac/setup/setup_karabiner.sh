#!/bin/bash

# ====================================
# Karabiner Elements Setup Script
# ====================================
# Este script instala Karabiner-Elements e configura regras personalizadas
# a partir dos arquivos na pasta karabine_config/configs

# Importar utilitários de cores para mensagens
source "$(dirname "$0")/../../utils/colors_message.sh"
source "$(dirname "$0")/../../utils/bash_tools.sh"

# ====================================
# Private Functions
# ====================================

_check_brew_installed() {
    if ! command -v brew &> /dev/null; then
        print_alert "Homebrew não está instalado."
        if get_user_confirmation "Deseja instalar o Homebrew agora?"; then
            print_info "Instalando Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            print_error "Homebrew é necessário para continuar. Abortando."
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
        if get_user_confirmation "Deseja instalar o Karabiner-Elements agora?"; then
            print_info "Instalando Karabiner-Elements..."
            brew install --cask karabiner-elements
            
            if [ $? -eq 0 ]; then
                print_success "Karabiner-Elements instalado com sucesso!"
            else
                print_error "Erro ao instalar Karabiner-Elements."
                exit 1
            fi
        else
            print_error "Karabiner-Elements é necessário para continuar. Abortando."
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
    
    # Verificar se o arquivo de configuração base existe
    if [ ! -f "$base_config_file" ]; then
        print_error "Arquivo de configuração base não encontrado: $base_config_file"
        exit 1
    fi
    
    # Verificar se o arquivo de configuração já existe
    if [ -f "$config_file" ]; then
        print_info "Arquivo de configuração encontrado."
        if get_user_confirmation "Deseja fazer backup da configuração atual?"; then
            local backup_file="${config_file}.backup.$(date +%Y%m%d%H%M%S)"
            cp "$config_file" "$backup_file"
            print_success "Backup criado em: $backup_file"
        fi
    else
        print_info "Criando novo arquivo de configuração..."
        # Copiar o arquivo de configuração base
        cp "$base_config_file" "$config_file"
        print_success "Arquivo de configuração criado em: $config_file"
    fi
    
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
        print_alert "jq não está instalado."
        if get_user_confirmation "Deseja instalar o jq agora? (necessário para processar arquivos JSON)"; then
            print_info "Instalando jq..."
            brew install jq
        else
            print_error "jq é necessário para continuar. Abortando."
            exit 1
        fi
    fi
}

# Função para verificar se uma regra já existe na configuração
_rule_exists() {
    local config_file="$1"
    local rule_description="$2"
    
    # Verificar se a regra com a mesma descrição já existe
    local existing_rule=$(jq -r --arg desc "$rule_description" '.profiles[0].complex_modifications.rules[] | select(.description == $desc)' "$config_file")
    
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
    jq --arg desc "$rule_description" '.profiles[0].complex_modifications.rules = [.profiles[0].complex_modifications.rules[] | select(.description != $desc)]' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    return $?
}

# Função genérica para aplicar uma configuração a partir de um arquivo JSON
_apply_config_from_file() {
    local config_file_path="$1"
    local karabiner_config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Verificar se o arquivo de configuração existe
    if [ ! -f "$config_file_path" ]; then
        print_error "Arquivo de configuração não encontrado: $config_file_path"
        return 1
    fi
    
    # Mostrar descrição da configuração
    local title=$(jq -r '.title' "$config_file_path")
    local description=$(jq -r '.rules[0].description' "$config_file_path")
    
    print_header_info "Configurando: $title"
    print_info "Descrição: $description"
    
    # Verificar se a regra já existe
    if _rule_exists "$karabiner_config_file" "$description"; then
        print_alert "A regra '$description' já existe na configuração."
        if get_user_confirmation "Deseja sobrescrever a regra existente?"; then
            print_info "Removendo regra existente..."
            _remove_rule "$karabiner_config_file" "$description"
        else
            print_info "Mantendo a regra existente."
            return 0
        fi
    fi
    
    if get_user_confirmation "Deseja aplicar esta configuração?"; then
        local temp_file=$(mktemp)
        print_info "Adicionando regra: $description"
        
        # Extrair as regras do arquivo JSON
        local rules=$(jq -c '.rules' "$config_file_path")
        
        # Adicionar as regras ao arquivo de configuração
        jq --argjson new_rules "$rules" '.profiles[0].complex_modifications.rules += $new_rules' "$karabiner_config_file" > "$temp_file" && mv "$temp_file" "$karabiner_config_file"
        
        print_success "Configuração '$title' adicionada com sucesso!"
    else
        print_alert "Configuração '$title' não foi aplicada."
    fi
}

# Função para listar todas as configurações disponíveis
list_available_configs() {
    print_header "Configurações Disponíveis"
    
    local config_dir="$(dirname "$0")/karabine_config/configs"
    
    if [ ! -d "$config_dir" ]; then
        print_error "Diretório de configurações não encontrado: $config_dir"
        return 1
    fi
    
    print_info "As seguintes configurações estão disponíveis:"
    echo ""
    
    for config_file in "$config_dir"/*.json; do
        if [ -f "$config_file" ]; then
            local filename=$(basename "$config_file" .json)
            local title=$(jq -r '.title // "Sem título"' "$config_file")
            local description=$(jq -r '.rules[0].description // "Sem descrição"' "$config_file")
            print_yellow "- $filename: $title"
            print "  $description"
        fi
    done
    
    echo ""
    print "Para aplicar uma configuração específica, execute:"
    print_yellow "  $0 <nome_da_configuração>"
    echo ""
    print "Para aplicar todas as configurações, execute:"
    print_yellow "  $0 all"
}

# Função para aplicar uma configuração específica
apply_config() {
    local config_name="$1"
    local config_file="$(dirname "$0")/karabine_config/configs/${config_name}.json"
    
    # Verificar se o arquivo existe
    if [ -f "$config_file" ]; then
        _apply_config_from_file "$config_file"
    else
        print_error "Configuração '$config_name' não encontrada."
        print_info "Execute '$0 list' para ver as configurações disponíveis."
        return 1
    fi
}

# Função para aplicar todas as configurações
apply_all_configs() {
    local config_dir="$(dirname "$0")/karabine_config/configs"
    
    if [ ! -d "$config_dir" ]; then
        print_error "Diretório de configurações não encontrado: $config_dir"
        return 1
    fi
    
    if get_user_confirmation "Deseja aplicar TODAS as configurações disponíveis?"; then
        local count=0
        local total=$(find "$config_dir" -name "*.json" | wc -l)
        
        for config_file in "$config_dir"/*.json; do
            if [ -f "$config_file" ]; then
                count=$((count + 1))
                print_header "Configuração $count de $total"
                _apply_config_from_file "$config_file"
            fi
        done
        
        print_success "Todas as $count configurações foram processadas."
    else
        print_alert "Operação cancelada pelo usuário."
    fi
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
            # Verificar se o comando é um nome de arquivo sem extensão
            if [ -f "$(dirname "$0")/karabine_config/configs/${command}.json" ]; then
                apply_config "$command"
                _restart_karabiner
            else
                print_error "Comando ou configuração desconhecida: $command"
                print_info "Execute '$0 list' para ver as configurações disponíveis."
                return 1
            fi
            ;;
    esac
    
    print_header "Configuração Concluída"
    print_success "Karabiner-Elements foi configurado com sucesso!"
    print_info "Se o Karabiner-Elements não foi reiniciado automaticamente, por favor:"
    print_info "1. Abra o aplicativo Karabiner-Elements manualmente"
    print_info "2. Verifique se as configurações foram aplicadas corretamente"
    print_info "3. Se estiver usando um teclado externo, talvez seja necessário configurá-lo nas preferências do Karabiner-Elements"
    print_info "4. Certifique-se de que o teclado externo está habilitado na seção 'Devices' do Karabiner-Elements"
}

# Executar o script apenas se não estiver sendo importado
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_karabiner "$@"
fi