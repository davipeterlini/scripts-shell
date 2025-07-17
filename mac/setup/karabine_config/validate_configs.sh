#!/bin/bash

# Script para validar os arquivos de configuração do Karabiner-Elements

# Cores para melhor visualização
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/configs"

# Verifica se o jq está instalado
if ! command -v jq &> /dev/null; then
    echo -e "${RED}O utilitário 'jq' não está instalado, mas é necessário para este script.${NC}"
    echo "Por favor, instale o jq primeiro:"
    echo "  brew install jq"
    exit 1
fi

echo "=== Validando arquivos de configuração do Karabiner-Elements ==="

# Verifica se o diretório de configurações existe
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}Diretório de configurações não encontrado: $CONFIG_DIR${NC}"
    exit 1
fi

# Lista todos os arquivos de configuração
configs=("$CONFIG_DIR"/*.json)
if [ ${#configs[@]} -eq 0 ]; then
    echo -e "${YELLOW}Nenhum arquivo de configuração encontrado em $CONFIG_DIR${NC}"
    exit 1
fi

all_valid=true

# Valida cada arquivo de configuração
for config in "${configs[@]}"; do
    echo -n "Validando $(basename "$config")... "
    
    # Verifica se o arquivo é um JSON válido
    if ! jq empty "$config" 2>/dev/null; then
        echo -e "${RED}Falha: JSON inválido${NC}"
        all_valid=false
        continue
    fi
    
    # Verifica se o arquivo tem o campo 'title'
    if ! jq -e '.title' "$config" >/dev/null 2>&1; then
        echo -e "${RED}Falha: Campo 'title' não encontrado${NC}"
        all_valid=false
        continue
    fi
    
    # Verifica se o arquivo tem o campo 'rules'
    if ! jq -e '.rules' "$config" >/dev/null 2>&1; then
        echo -e "${RED}Falha: Campo 'rules' não encontrado${NC}"
        all_valid=false
        continue
    fi
    
    # Verifica se 'rules' é um array
    if ! jq -e 'if .rules | type == "array" then true else false end' "$config" >/dev/null 2>&1; then
        echo -e "${RED}Falha: Campo 'rules' não é um array${NC}"
        all_valid=false
        continue
    fi
    
    echo -e "${GREEN}OK${NC}"
done

if $all_valid; then
    echo -e "\n${GREEN}Todos os arquivos de configuração são válidos!${NC}"
    exit 0
else
    echo -e "\n${RED}Alguns arquivos de configuração são inválidos. Por favor, corrija os erros acima.${NC}"
    exit 1
fi