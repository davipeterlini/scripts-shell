#!/bin/bash

# Habilitar modo de saída em caso de erro
set -e

# Definir variáveis para os caminhos dos scripts
GITHUB_SCRIPT="github/configure_multi_ssh_github_keys.sh"
BITBUCKET_SCRIPT="bitbucket/configure_multi_ssh_bitbucket_keys.sh"
SSH_CONFIG_SCRIPT="dev/setup_ssh_config.sh"

# Função para verificar se um script existe e é executável
check_script_existence() {
    local script_path=$1
    if [[ ! -x "$script_path" ]]; then
        echo "Erro: O script '$script_path' não existe ou não tem permissão de execução."
        exit 1
    fi
}

# Função para executar um script e verificar erros
execute_script() {
    local script_path=$1
    local description=$2

    echo "Executando: $description..."
    bash "$script_path" || {
        echo "Erro ao executar '$description'."
        exit 1
    }
    echo "Concluído: $description."
}

# Início do setup
echo "Iniciando o setup do Git e Bitbucket..."

# Verificar e executar o script de configuração do GitHub
check_script_existence "$GITHUB_SCRIPT"
execute_script "$GITHUB_SCRIPT" "Configuração de múltiplas chaves SSH para GitHub"

# Verificar e executar o script de configuração do Bitbucket
check_script_existence "$BITBUCKET_SCRIPT"
execute_script "$BITBUCKET_SCRIPT" "Configuração de múltiplas chaves SSH para Bitbucket"

# Verificar e executar o script de configuração do SSH
check_script_existence "$SSH_CONFIG_SCRIPT"
execute_script "$SSH_CONFIG_SCRIPT" "Configuração do arquivo SSH"

# Finalização
echo "Setup concluído com sucesso!"