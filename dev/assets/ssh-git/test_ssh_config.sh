#!/bin/bash

# Cores para melhor visualização
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testando configuração SSH para diferentes repositórios${NC}"
echo "Repositório atual:"
git remote -v | grep origin | grep fetch
echo ""

# Função para testar um padrão específico
test_pattern() {
  local pattern=$1
  local name=$2
  
  echo -e "${YELLOW}Testando padrão para $name:${NC}"
  echo "git remote -v 2>/dev/null | grep -E 'origin.*github.com[:/]$pattern' | grep fetch"
  
  result=$(git remote -v 2>/dev/null | grep -E "origin.*github.com[:/]$pattern" | grep fetch)
  
  if [ -n "$result" ]; then
    echo -e "${GREEN}✓ Padrão encontrado:${NC}"
    echo "$result"
    return 0
  else
    echo -e "${RED}✗ Padrão não encontrado${NC}"
    return 1
  fi
}

# Verificar configuração do Git
check_git_config() {
  echo -e "${YELLOW}Verificando configuração do Git:${NC}"
  
  if [ -f "$HOME/.gitconfig" ]; then
    echo -e "${GREEN}✓ Arquivo .gitconfig encontrado${NC}"
    
    # Verificar configurações de URL
    url_configs=$(grep -A2 "\[url" "$HOME/.gitconfig")
    
    if [ -n "$url_configs" ]; then
      echo -e "${GREEN}✓ Configurações de URL encontradas:${NC}"
      echo "$url_configs"
      
      # Verificar se as configurações estão no formato correto (SSH)
      ssh_url_count=$(grep -c "insteadOf = git@github.com:" "$HOME/.gitconfig")
      
      if [ "$ssh_url_count" -gt 0 ]; then
        echo -e "${GREEN}✓ Configurações de URL SSH encontradas: $ssh_url_count${NC}"
      else
        echo -e "${RED}✗ Nenhuma configuração de URL SSH encontrada${NC}"
        echo -e "${YELLOW}As configurações devem usar o formato:${NC}"
        echo '[url "git@github.com-work:username/"]'
        echo '    insteadOf = git@github.com:username/'
      fi
    else
      echo -e "${RED}✗ Nenhuma configuração de URL encontrada${NC}"
    fi
  else
    echo -e "${RED}✗ Arquivo .gitconfig não encontrado${NC}"
  fi
}

# Testar todos os padrões
echo ""
test_pattern "CI-T-HyperX" "CI-T-HyperX"
echo ""
test_pattern "davipeterlinicit" "davipeterlinicit"
echo ""
test_pattern "davipeterlini" "davipeterlini"
echo ""
test_pattern "futureit" "futureit"
echo ""
test_pattern "medicalclub" "medicalclub"
echo ""

# Verificar configuração do Git
check_git_config