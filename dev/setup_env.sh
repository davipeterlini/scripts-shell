#!/bin/bash

# Definição de cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

create_env_file() {
    local user_profile_dir="$HOME"
    local env_example_path="./dev/.env.example"
    local env_target_path="$user_profile_dir/.env"

    if [ -f "$env_example_path" ]; then
        cp "$env_example_path" "$env_target_path"
        echo -e "${GREEN}.env file created at $env_target_path${NC}"
    else
        echo -e "${RED}Error: $env_example_path does not exist.${NC}"
        exit 1
    fi
}

# Função para perguntar ao usuário qual profile deseja usar
get_user_profile_choice() {
  echo -e "${BLUE}Escolha o profile onde deseja salvar as configurações:${NC}"
  echo -e "${GREEN}1. .zshrc${NC}"
  echo -e "${GREEN}2. .bashrc${NC}"
  read -p "Digite 1 ou 2: " profile_option

  case "$profile_option" in
    1) echo ".zshrc" ;;
    2) echo ".bashrc" ;;
    *) 
      echo -e "${RED}Opção inválida. Por favor, execute o script novamente e escolha entre 1 ou 2.${NC}"
      exit 1
      ;;
  esac
}

# Função para adicionar a linha de exportação ao profile
add_export_to_profile() {
  local profile_path="$HOME/$1"
  local export_line="export \$(grep -v '^#' ~/.env | xargs)"
  
  if [ -f "$profile_path" ]; then
    if ! grep -q "$export_line" "$profile_path"; then
      echo -e "${YELLOW}Adicionando linha de exportação ao $1...${NC}"
      echo "$export_line" >> "$profile_path"
    else
      echo -e "${GREEN}A linha de exportação já existe no $1.${NC}"
    fi
  else
    echo -e "${RED}O arquivo $1 não existe. Certifique-se de que o shell correto está configurado.${NC}"
    exit 1
  fi
}

# Função para imprimir as variáveis salvas no terminal
print_env_variables() {
  echo -e "${BLUE}Variáveis salvas no arquivo .env:${NC}"
  cat "$HOME/.env"
}

# Fluxo principal do script
main() {
    create_env_file

    local profile
    profile=$(get_user_profile_choice)
    add_export_to_profile "$profile"

    # Recarregar o profile para aplicar as mudanças
    if [ -f "$HOME/$profile" ]; then
      echo -e "${YELLOW}Recarregando o arquivo de profile $profile...${NC}"
      source "$HOME/$profile"
    else
      echo -e "${RED}Não foi possível recarregar o arquivo de profile $profile porque ele não existe.${NC}"
      exit 1
    fi

    print_env_variables
}

# Executar o script
main