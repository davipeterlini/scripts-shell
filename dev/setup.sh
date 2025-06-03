#!/bin/bash

# Função para exibir mensagens de log
log() {
  echo "[SETUP] $1"
}

# Selecionar o profile
log "Selecionando o profile..."
source utils/choose_shell_profile.sh

# Detectar o sistema operacional e salvar em uma variável global
log "Detectando o sistema operacional..."
OS=$(source utils/detect_os.sh)
export OS

# Executar o script de configuração do projeto
log "Executando configuração do projeto..."
bash dev/project-folder/projesetup_project.sh

# Executar o script de configuração do Git e Bitbucket
log "Configurando Git e Bitbucket..."
bash dev/setup_git_and_bitbucket.sh

# Executar o script de configuração do Git e Bitbucket na subpasta git
log "Configurando Git e Bitbucket na subpasta git..."
bash dev/git/setup_git_and_bitbucket.sh

# Executar o script de configuração do SSH
log "Configurando SSH..."
bash dev/git/setup_ssh_config.sh

log "Setup concluído com sucesso!"