#!/bin/bash

# Script para configurar o arquivo ~/.ssh/config com as configurações da pasta dev/assets/ssh-git
# Substitui as variáveis de ambiente $HOME pelo valor real do diretório home do usuário

# Importa o utilitário de cores
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/utils/colors_message.sh"

# Diretório dos assets
ASSETS_DIR="$PROJECT_ROOT/dev/assets/ssh-git"

# Função para criar o diretório ~/.ssh, se necessário
create_ssh_directory() {
    if [ ! -d "$HOME/.ssh" ]; then
        print_info "Criando diretório ~/.ssh..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        print_success "Diretório ~/.ssh criado com sucesso!"
    fi
}

# Função para fazer backup do arquivo ~/.ssh/config existente
backup_existing_config() {
    if [ -f "$HOME/.ssh/config" ]; then
        print_info "Fazendo backup do arquivo ~/.ssh/config existente..."
        local backup_file="$HOME/.ssh/config.backup.$(date +%Y%m%d%H%M%S)"
        cp "$HOME/.ssh/config" "$backup_file"
        print_success "Backup criado: $backup_file"
    fi
}

# Função para selecionar a versão do arquivo de configuração
select_config_version() {
    local config_files=($(ls "$ASSETS_DIR"))
    local num_files=${#config_files[@]}

    print_info "Seleção da Versão"
    echo -e "${BLUE}Selecione a versão do arquivo de configuração:${NC}"
    for i in $(seq 1 $num_files); do
        echo -e "${BLUE}${i})${NC} ${config_files[$((i-1))]}"
    done

    read -p "$(echo -e ${YELLOW}"Escolha (1-$num_files): "${NC})" choice

    if [[ $choice -ge 1 && $choice -le $num_files ]]; then
        echo "${config_files[$((choice-1))]}"
    else
        print_alert "Opção inválida. Usando a primeira configuração como padrão."
        echo "${config_files[0]}"
    fi
}

# Função para configurar o arquivo ~/.ssh/config
configure_ssh() {
    local config_file="$1"
    local config_path="$ASSETS_DIR/$config_file"

    if [ ! -f "$config_path" ]; then
        print_error "Arquivo de configuração $config_path não encontrado."
        exit 1
    fi

    print_success "Usando arquivo de configuração: $config_file"

    print_info "Configurando arquivo ~/.ssh/config..."
    sed "s|\$HOME|$HOME|g" "$config_path" > "$HOME/.ssh/config"

    chmod 600 "$HOME/.ssh/config"
    print_success "Permissões do arquivo definidas como 600 (leitura/escrita apenas para o proprietário)"
}

# Função para exibir o conteúdo do arquivo configurado
display_config_content() {
    print_info "Conteúdo do Arquivo Configurado"
    cat "$HOME/.ssh/config"
}

# Fluxo principal do script
setup_ssh_config_main() {
    print_info "Configuração do SSH para GitHub"

    create_ssh_directory
    backup_existing_config

    local selected_config_file
    selected_config_file=$(select_config_version)

    configure_ssh "$selected_config_file"
    display_config_content

    print_info "Operação Finalizada com Sucesso!"
}

# Executa o script
setup_ssh_config_main