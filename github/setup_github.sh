#!/bin/bash

# Script para configurar o ambiente GitHub seguindo a sequência recomendada.

# Cores para mensagens no terminal
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # Sem cor

# Diretório base do script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Função para exibir mensagens formatadas
function print_message() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${YELLOW}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

# Função para exibir mensagens de sucesso
function print_success() {
  echo -e "${GREEN}$1${NC}"
}

# Função para exibir mensagens de erro
function print_error() {
  echo -e "${RED}Erro: $1${NC}"
}

# Passo 1: Configurar duas chaves SSH para múltiplas contas GitHub
print_message "Passo 1: Configurando duas chaves SSH para múltiplas contas GitHub..."
if "${BASE_DIR}/configure_two_ssh_github_keys.sh"; then
  print_success "Passo 1 concluído com sucesso!"
else
  print_error "Erro ao executar configure_two_ssh_github_keys.sh. Abortando."
  exit 1
fi

# Passo 2: Conectar uma conta GitHub usando SSH
print_message "Passo 2: Conectando uma conta GitHub usando SSH..."
if "${BASE_DIR}/connect_git_ssh_account.sh"; then
  print_success "Passo 2 concluído com sucesso!"
else
  print_error "Erro ao executar connect_git_ssh_account.sh. Abortando."
  exit 1
fi

# Passo 3: Gerar um token clássico de acesso pessoal
print_message "Passo 3: Gerando um token clássico de acesso pessoal..."
if "${BASE_DIR}/generate-classic-token-gh-local.sh"; then
  print_success "Passo 3 concluído com sucesso!"
else
  print_error "Erro ao executar generate-classic-token-gh-local.sh. Abortando."
  exit 1
fi

print_message "Configuração do ambiente GitHub concluída com sucesso!"