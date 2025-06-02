#!/bin/bash

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Função para exibir mensagens de informação
function print_info() {
  echo -e "\n${BLUE}ℹ️  $1${NC}"
}

# Função para exibir mensagens de sucesso
function print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

# Função para exibir mensagens de erro
function print_alert() {
  echo -e "\n${YELLOW}⚠️  $1${NC}"
}

# Função para exibir mensagens de erro
function print_error() {
  echo -e "${RED}❌ Erro: $1${NC}"
}

# Função para exibir mensagens formatadas
# function print_message() {
#   echo -e "\n${YELLOW}========================================${NC}"
#   echo -e "${GREEN}$1${NC}"
#   echo -e "${YELLOW}========================================${NC}"
# }