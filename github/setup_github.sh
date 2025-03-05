#!/bin/bash

# Script para configurar o ambiente GitHub seguindo a sequência recomendada.

# Função para exibir mensagens formatadas
function print_message() {
  echo "========================================"
  echo "$1"
  echo "========================================"
}

# Passo 1: Configurar duas chaves SSH para múltiplas contas GitHub
print_message "Passo 1: Configurando duas chaves SSH para múltiplas contas GitHub..."
if ./configure_two_ssh_github_keys.sh; then
  print_message "Passo 1 concluído com sucesso!"
else
  echo "Erro ao executar configure_two_ssh_github_keys.sh. Abortando."
  exit 1
fi

# Passo 2: Conectar uma conta GitHub usando SSH
print_message "Passo 2: Conectando uma conta GitHub usando SSH..."
if ./connect_git_ssh_account.sh; then
  print_message "Passo 2 concluído com sucesso!"
else
  echo "Erro ao executar connect_git_ssh_account.sh. Abortando."
  exit 1
fi

# Passo 3: Gerar um token clássico de acesso pessoal
print_message "Passo 3: Gerando um token clássico de acesso pessoal..."
if ./generate-classic-token-gh-local.sh; then
  print_message "Passo 3 concluído com sucesso!"
else
  echo "Erro ao executar generate-classic-token-gh-local.sh. Abortando."
  exit 1
fi

print_message "Configuração do ambiente GitHub concluída com sucesso!"