#!/bin/bash

# Script para configurar o arquivo ~/.ssh/config com as configurações da pasta github/assets
# Substitui as variáveis de ambiente $HOME pelo valor real do diretório home do usuário

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/assets"

# Verifica se o diretório ~/.ssh existe, se não, cria
if [ ! -d "$HOME/.ssh" ]; then
    echo "Criando diretório ~/.ssh..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
fi

# Faz backup do arquivo de configuração existente, se houver
if [ -f "$HOME/.ssh/config" ]; then
    echo "Fazendo backup do arquivo ~/.ssh/config existente..."
    cp "$HOME/.ssh/config" "$HOME/.ssh/config.backup.$(date +%Y%m%d%H%M%S)"
fi

# Seleciona a versão do arquivo de configuração
echo "Selecione a versão do arquivo de configuração:"
echo "1) Versão 1"
echo "2) Versão 2"
echo "3) Versão 3"
read -p "Escolha (1-3): " choice

case $choice in
    1) CONFIG_FILE="config-ssh-v1" ;;
    2) CONFIG_FILE="config-ssh-v2" ;;
    3) CONFIG_FILE="config-ssh-v3" ;;
    *) echo "Opção inválida. Usando versão 2 como padrão."; CONFIG_FILE="config-ssh-v2" ;;
esac

CONFIG_PATH="$ASSETS_DIR/$CONFIG_FILE"

if [ ! -f "$CONFIG_PATH" ]; then
    echo "Erro: Arquivo de configuração $CONFIG_PATH não encontrado."
    exit 1
fi

echo "Usando arquivo de configuração: $CONFIG_PATH"

# Substitui a variável $HOME pelo valor real e salva no arquivo ~/.ssh/config
echo "Configurando arquivo ~/.ssh/config..."
sed "s|\$HOME|$HOME|g" "$CONFIG_PATH" > "$HOME/.ssh/config"

# Define as permissões corretas para o arquivo de configuração
chmod 600 "$HOME/.ssh/config"

echo "Configuração concluída com sucesso!"
echo "O arquivo ~/.ssh/config foi configurado usando $CONFIG_FILE"
echo "As variáveis de ambiente \$HOME foram substituídas pelo valor real: $HOME"

# Exibe o conteúdo do arquivo configurado
echo "Conteúdo do arquivo ~/.ssh/config:"
echo "----------------------------------------"
cat "$HOME/.ssh/config"
echo "----------------------------------------"