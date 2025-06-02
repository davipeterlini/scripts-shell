#!/bin/bash

# Script para configurar o arquivo ~/.ssh/config com as configurações da pasta github/assets
# Substitui as variáveis de ambiente $HOME pelo valor real do diretório home do usuário

# Importa o utilitário de cores
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/utils/colors_message.sh"

# Diretório dos assets
ASSETS_DIR="$SCRIPT_DIR/assets"

print_info "Configuração do SSH para GitHub"

# Verifica se o diretório ~/.ssh existe, se não, cria
if [ ! -d "$HOME/.ssh" ]; then
    print_info "Criando diretório ~/.ssh..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    print_success "Diretório ~/.ssh criado com sucesso!"
fi

# Faz backup do arquivo de configuração existente, se houver
if [ -f "$HOME/.ssh/config" ]; then
    print_info "Fazendo backup do arquivo ~/.ssh/config existente..."
    BACKUP_FILE="$HOME/.ssh/config.backup.$(date +%Y%m%d%H%M%S)"
    cp "$HOME/.ssh/config" "$BACKUP_FILE"
    print_success "Backup criado: $BACKUP_FILE"
fi

# Seleciona a versão do arquivo de configuração
print_info "Seleção da Versão"
echo -e "${BLUE}Selecione a versão do arquivo de configuração:${NC}"
echo -e "${BLUE}1)${NC} Versão 1"
echo -e "${BLUE}2)${NC} Versão 2"
echo -e "${BLUE}3)${NC} Versão 3"
read -p "$(echo -e ${YELLOW}"Escolha (1-3): "${NC})" choice

case $choice in
    1) CONFIG_FILE="config-ssh-v1" ;;
    2) CONFIG_FILE="config-ssh-v2" ;;
    3) CONFIG_FILE="config-ssh-v3" ;;
    *) print_alert "Opção inválida. Usando versão 2 como padrão."; CONFIG_FILE="config-ssh-v2" ;;
esac

CONFIG_PATH="$ASSETS_DIR/$CONFIG_FILE"

if [ ! -f "$CONFIG_PATH" ]; then
    print_error "Arquivo de configuração $CONFIG_PATH não encontrado."
    exit 1
fi

print_success "Usando arquivo de configuração: $CONFIG_FILE"

# Substitui a variável $HOME pelo valor real e salva no arquivo ~/.ssh/config
print_info "Configurando SSH"
print_info "Configurando arquivo ~/.ssh/config..."
sed "s|\$HOME|$HOME|g" "$CONFIG_PATH" > "$HOME/.ssh/config"

# Define as permissões corretas para o arquivo de configuração
chmod 600 "$HOME/.ssh/config"
print_success "Permissões do arquivo definidas como 600 (leitura/escrita apenas para o proprietário)"

print_info "Configuração Concluída"
print_success "O arquivo ~/.ssh/config foi configurado usando $CONFIG_FILE"
print_info "As variáveis de ambiente \$HOME foram substituídas pelo valor real: $HOME"

# Exibe o conteúdo do arquivo configurado
print_info "Conteúdo do Arquivo Configurado"
cat "$HOME/.ssh/config"

print_info "Operação Finalizada com Sucesso!"