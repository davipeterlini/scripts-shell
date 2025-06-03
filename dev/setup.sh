#!/bin/bash

# Função para exibir mensagens de log
log() {
  echo "[SETUP] $1"
}

# Função para verificar se um arquivo existe antes de executá-lo
execute_script() {
  local script_path=$1
  local description=$2

  if [ -f "$script_path" ]; then
    log "$description"
    bash "$script_path"
  else
    log "[ERRO] O script $script_path não foi encontrado. Abortando."
    exit 1
  fi
}

# Função para selecionar o profile
select_profile() {
  local profile_script="utils/choose_shell_profile.sh"
  execute_script "$profile_script" "Selecionando o profile..."
}

# Função para detectar o sistema operacional
detect_os() {
  local os_script="utils/detect_os.sh"
  if [ -f "$os_script" ]; then
    log "Detectando o sistema operacional..."
    OS=$(source "$os_script")
    export OS
  else
    log "[ERRO] O script $os_script não foi encontrado. Abortando."
    exit 1
  fi
}

# Função para configurar o projeto
setup_project() {
  local project_script="dev/project-folder/projesetup_project.sh"
  execute_script "$project_script" "Executando configuração do projeto..."
}

# Função para configurar Git e Bitbucket
setup_git_and_bitbucket() {
  local git_script="dev/setup_git_and_bitbucket.sh"
  execute_script "$git_script" "Configurando Git e Bitbucket..."
}

# Função para configurar Git e Bitbucket na subpasta git
setup_git_and_bitbucket_subfolder() {
  local git_subfolder_script="dev/git/setup_git_and_bitbucket.sh"
  execute_script "$git_subfolder_script" "Configurando Git e Bitbucket na subpasta git..."
}

# Função para configurar SSH
setup_ssh() {
  local ssh_script="dev/git/setup_ssh_config.sh"
  execute_script "$ssh_script" "Configurando SSH..."
}

# Função principal
main() {
  select_profile
  detect_os
  setup_project
  setup_git_and_bitbucket
  setup_git_and_bitbucket_subfolder
  setup_ssh

  log "Setup concluído com sucesso!"
}

# Executar a função principal
main