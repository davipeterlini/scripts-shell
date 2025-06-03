#!/bin/bash


source "$(dirname "$0")/utils/load_env.sh"
load_env
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/execute_script.sh"

# Definir o diretório base dos scripts
SCRIPT_BASE_DIR="utils"
PROJECT_BASE_DIR="dev"


# Função para detectar o sistema operacional
detect_operating_system() {
  local os_script="$SCRIPT_BASE_DIR/detect_os.sh"
  if [ -f "$os_script" ]; then
    log "Detectando o sistema operacional..."
    OS=$(source "$os_script")
    export OS
  else
    error_exit "O script $os_script não foi encontrado. Abortando."
  fi
}

# Função para configurar o projeto
setup_project_configuration() {
  local project_script="$PROJECT_BASE_DIR/project-folder/projesetup_project.sh"
  execute_script "$project_script" "Executando configuração do projeto..."
}

# Função para configurar Git e Bitbucket
setup_git_and_bitbucket() {
  local git_script="$PROJECT_BASE_DIR/setup_git_and_bitbucket.sh"
  execute_script "$git_script" "Configurando Git e Bitbucket..."
}

# Função para configurar Git e Bitbucket na subpasta git
setup_git_and_bitbucket_in_subfolder() {
  local git_subfolder_script="$PROJECT_BASE_DIR/git/setup_git_and_bitbucket.sh"
  execute_script "$git_subfolder_script" "Configurando Git e Bitbucket na subpasta git..."
}

# Função para configurar SSH
setup_ssh_configuration() {
  local ssh_script="$PROJECT_BASE_DIR/git/setup_ssh_config.sh"
  execute_script "$ssh_script" "Configurando SSH..."
}

# Função principal
main() {

  # Detect the operating system
  os=$(detect_os)
  echo "Operational System: $os"

  # Use the external choose_shell_profile script instead of the internal function
  choose_shell_profile

  detect_operating_system
  setup_project_configuration
  setup_git_and_bitbucket
  setup_git_and_bitbucket_in_subfolder
  setup_ssh_configuration
  log "Setup concluído com sucesso!"
}

# Executar a função principal
main