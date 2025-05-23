#!/bin/bash

# Definição de cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor


# Função para verificar e criar o diretório ~/.coder-ide
create_coder_ide_directory() {
  if [ ! -d "$HOME/.coder-ide" ]; then
    echo -e "${YELLOW}Criando diretório ~/.coder-ide...${NC}"
    mkdir -p "$HOME/.coder-ide"
  fi
}

# Função para criar o arquivo .env.example, se não existir
create_env_example() {
  local env_example_path="$HOME/.coder-ide/.env.example"
  if [ ! -f "$env_example_path" ]; then
    echo -e "${YELLOW}Criando arquivo .env.example...${NC}"
    echo "# Exemplo de arquivo .env" > "$env_example_path"
    echo "VAR1=valor1" >> "$env_example_path"
    echo "VAR2=valor2" >> "$env_example_path"
  fi
}

# Função para criar o arquivo .env a partir do .env.example, se não existir
create_env_file() {
  local env_path="$HOME/.coder-ide/.env"
  if [ ! -f "$env_path" ]; then
    echo -e "${YELLOW}Criando arquivo .env...${NC}"
    cp "$HOME/.coder-ide/.env.example" "$env_path"
  fi
}

create_env_file() {
    local user_profile_dir="$HOME"
    local env_example_path="./dev/.env.example"
    local env_target_path="$user_profile_dir/.env"

    if [ -f "$env_example_path" ]; then
        cp "$env_example_path" "$env_target_path"
        echo ".env file created at $env_target_path"
    else
        echo "Error: $env_example_path does not exist."
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
  
  if ! grep -q "$export_line" "$profile_path"; then
    echo -e "${YELLOW}Adicionando linha de exportação ao $1...${NC}"
    echo "$export_line" >> "$profile_path"
  fi
}

# Função para imprimir as variáveis salvas no terminal
print_env_variables() {
  echo -e "${BLUE}Variáveis salvas no arquivo .env:${NC}"
  cat "$HOME/.env"
}

# Fluxo principal do script
main() {
    #create_coder_ide_directory
    #create_env_example
    #create_env_file
    create_env_file

  local profile
  profile=$(get_user_profile_choice)
  add_export_to_profile "$profile"

  # Recarregar o profile para aplicar as mudanças
  source "$HOME/$profile"
  print_env_variables
}

# Executar o script
main