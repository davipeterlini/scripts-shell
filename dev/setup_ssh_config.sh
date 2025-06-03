#!/bin/bash

# Script para configurar o arquivo ~/.ssh/config com as configurações da pasta dev/assets/ssh-git
# Substitui as variáveis de ambiente $HOME pelo valor real do diretório home do usuário

# Importa o utilitário de cores
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/utils/colors_message.sh"

# Diretório dos assets
ASSETS_DIR="$PROJECT_ROOT/dev/assets/ssh-git"

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

# Conta o número de arquivos na pasta de configurações
CONFIG_FILES=($(ls "$ASSETS_DIR"))
NUM_FILES=${#CONFIG_FILES[@]}

# Seleciona a versão do arquivo de configuração
print_info "Seleção da Versão"
echo -e "${BLUE}Selecione a versão do arquivo de configuração:${NC}"
for i in $(seq 1 $NUM_FILES); do
    echo -e "${BLUE}${i})${NC} ${CONFIG_FILES[$((i-1))]}"
done
read -p "$(echo -e ${YELLOW}"Escolha (1-$NUM_FILES): "${NC})" choice

if [[ $choice -ge 1 && $choice -le $NUM_FILES ]]; then
    CONFIG_FILE="${CONFIG_FILES[$((choice-1))]}"
else
    print_alert "Opção inválida. Usando a primeira configuração como padrão."
    CONFIG_FILE="${CONFIG_FILES[0]}"
fi

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