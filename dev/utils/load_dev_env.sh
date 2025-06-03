#!/bin/bash

source "$SCRIPT_DIR/../../utils/colors_message.sh"

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Function to find the dev directory and env files
find_dev_env_files() {
  local dir="$SCRIPT_DIR"
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/dev" ]; then
      DEV_DIR="$dir/dev"
      ENV_PERSONAL_FILE="$DEV_DIR/.env.personal"
      ENV_WORK_FILE="$DEV_DIR/.env.work"
      return
    fi
    dir=$(dirname "$dir")
  done
  print_error "Diretório 'dev' não encontrado em nenhum diretório pai."
  exit 1
}

# Function to determine the operating system and set the HOME variable accordingly
set_home_based_on_os() {
  case "$(uname -s)" in
    Darwin)
      export HOME="/Users/$USER"
      ;;
    Linux)
      export HOME="/home/$USER"
      ;;
    *)
      print_error "Sistema operacional não suportado."
      exit 1
      ;;
  esac
}

# Function to create or update the .env.personal file with the HOME variable
update_env_personal_file() {
  if [ ! -f "$ENV_PERSONAL_FILE" ]; then
    echo "HOME=$HOME" > "$ENV_PERSONAL_FILE"
    print_success "Arquivo .env.personal criado com a variável HOME."
  else
    if grep -q '^HOME=' "$ENV_PERSONAL_FILE"; then
      sed -i '' "s|^HOME=.*|HOME=$HOME|" "$ENV_PERSONAL_FILE"
      print_success "Variável HOME atualizada no arquivo .env.personal."
    else
      echo "HOME=$HOME" >> "$ENV_PERSONAL_FILE"
      print_success "Variável HOME adicionada ao arquivo .env.personal."
    fi
  fi
}

# Function to load environment variables from .env.personal and .env.work files
load_dev_env() {
  find_dev_env_files

  # Create dev directory if it doesn't exist
  if [ -z "$DEV_DIR" ]; then
    DEV_DIR="$(dirname "$SCRIPT_DIR")/dev"
    mkdir -p "$DEV_DIR"
    print_info "Diretório 'dev' criado em: $DEV_DIR"
    ENV_PERSONAL_FILE="$DEV_DIR/.env.personal"
    ENV_WORK_FILE="$DEV_DIR/.env.work"
  fi

  # Handle .env.personal file
  if [ ! -f "$ENV_PERSONAL_FILE" ]; then
    touch "$ENV_PERSONAL_FILE"
    print_alert "Arquivo .env.personal vazio criado em: $ENV_PERSONAL_FILE"
  else
    print_info "Carregando variáveis de ambiente do arquivo .env.personal"
  fi

  set -a
  source "$ENV_PERSONAL_FILE"
  set +a

  # Handle .env.work file
  if [ ! -f "$ENV_WORK_FILE" ]; then
    touch "$ENV_WORK_FILE"
    print_alert "Arquivo .env.work vazio criado em: $ENV_WORK_FILE"
  else
    print_info "Carregando variáveis de ambiente do arquivo .env.work"
  fi

  set -a
  source "$ENV_WORK_FILE"
  set +a

  if [ -z "$HOME" ]; then
    set_home_based_on_os
    update_env_personal_file
  fi

  # Mark environment as loaded
  export DEV_ENV_LOADED=true
  print_success "Variáveis de ambiente de desenvolvimento carregadas com sucesso."
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [ -z "$DEV_ENV_LOADED" ]; then
    load_dev_env
    export DEV_ENV_LOADED=true
  fi
fi