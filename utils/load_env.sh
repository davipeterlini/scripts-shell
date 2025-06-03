#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Function to find the .env and .env.local files in the project root directory
find_env_files() {
  local dir="$SCRIPT_DIR"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.env" ]; then
      ENV_FILE="$dir/.env"
      ENV_LOCAL_FILE="$dir/.env.local"
      return
    fi
    dir=$(dirname "$dir")
  done
  print_error "Arquivo .env não encontrado em nenhum diretório pai."
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

# Function to create or update the .env.local file with the HOME variable
update_env_local_file() {
  if [ ! -f "$ENV_LOCAL_FILE" ]; then
    echo "HOME=$HOME" > "$ENV_LOCAL_FILE"
    print_success "Arquivo .env.local criado com a variável HOME."
  else
    if grep -q '^HOME=' "$ENV_LOCAL_FILE"; then
      sed -i '' "s|^HOME=.*|HOME=$HOME|" "$ENV_LOCAL_FILE"
      print_success "Variável HOME atualizada no arquivo .env.local."
    else
      echo "HOME=$HOME" >> "$ENV_LOCAL_FILE"
      print_success "Variável HOME adicionada ao arquivo .env.local."
    fi
  fi
}

# Function to load environment variables from .env and .env.local files
load_env() {
  find_env_files

  if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
  else
    print_error "Arquivo .env não encontrado. Saindo..."
    exit 1
  fi

  if [ ! -f "$ENV_LOCAL_FILE" ]; then
    touch "$ENV_LOCAL_FILE"
    print_alert "Arquivo .env.local vazio criado."
  fi

  set -a
  source "$ENV_LOCAL_FILE"
  set +a

  if [ -z "$HOME" ]; then
    set_home_based_on_os
    update_env_local_file
  fi

  # Mark environment as loaded
  export ENV_LOADED=true
}

# Main script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [ -z "$ENV_LOADED" ]; then
    load_env
    export ENV_LOADED=true
  fi
fi