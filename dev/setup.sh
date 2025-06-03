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

# Função principal
main() {
  select_profile
  detect_os

  execute_script "dev/project-folder/setup_project.sh" "Executando configuração do projeto..."
  execute_script "dev/setup_git_and_bitbucket.sh" "Configurando Git e Bitbucket..."
  execute_script "dev/git/setup_git_and_bitbucket.sh" "Configurando Git e Bitbucket na subpasta git..."
  execute_script "dev/git/setup_ssh_config.sh" "Configurando SSH..."

  log "Setup concluído com sucesso!"
}

# Executar a função principal
main