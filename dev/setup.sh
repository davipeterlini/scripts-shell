#!/bin/bash


source "$(dirname "$0")/utils/load_env.sh"
load_env
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/colors_message.sh"

# Definir o diretório base dos scripts
SCRIPT_BASE_DIR="utils"
PROJECT_BASE_DIR="dev"

# Função para exibir mensagens de log
log() {
  echo "[SETUP] $1"
}

# Função para exibir mensagens de erro e encerrar o script
error_exit() {
  echo "[ERRO] $1"
  exit 1
}

# Função para verificar se um arquivo existe antes de executá-lo
execute_script() {
  local script_path=$1
  local description=$2

  if [ -f "$script_path" ]; then
    log "$description"
    bash "$script_path"
  else
    error_exit "O script $script_path não foi encontrado. Abortando."
  fi
}

# Função para selecionar o profile
select_shell_profile() {
  local profile_script="$SCRIPT_BASE_DIR/choose_shell_profile.sh"
  execute_script "$profile_script" "Selecionando o profile..."
}

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
  log "Iniciando o processo de setup..."
  select_shell_profile
  detect_operating_system
  setup_project_configuration
  setup_git_and_bitbucket
  setup_git_and_bitbucket_in_subfolder
  setup_ssh_configuration
  log "Setup concluído com sucesso!"
}

# Executar a função principal
main