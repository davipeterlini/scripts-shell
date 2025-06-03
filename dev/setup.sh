#!/bin/bash

source "$(dirname "$0")/utils/load_env.sh"
load_env
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/execute_script.sh"
source "$(dirname "$0")/setup_projects.sh" 
source "$(dirname "$0")/setup_ssh_config.sh"

# Definir o diretório base dos scripts
SCRIPT_BASE_DIR="utils"
PROJECT_BASE_DIR="dev"

# Função para configurar Git e Bitbucket
setup_git_and_bitbucket() {
  # Habilitar modo de saída em caso de erro
  set -e

  # Definir variáveis para os caminhos dos scripts
  GITHUB_SCRIPT="github/configure_multi_ssh_github_keys.sh"
  BITBUCKET_SCRIPT="bitbucket/configure_multi_ssh_bitbucket_keys.sh"
  SSH_CONFIG_SCRIPT="dev/setup_ssh_config.sh"

  # Função para verificar se um script existe e é executável
  check_script_existence() {
      local script_path=$1
      if [[ ! -x "$script_path" ]]; then
          print_error "O script '$script_path' não existe ou não tem permissão de execução."
          exit 1
      fi
  }

  # Função para executar um script e verificar erros
  execute_script() {
      local script_path=$1
      local description=$2

      print_info "Executando: $description..."
      bash "$script_path" || {
          print_error "Erro ao executar '$description'."
          exit 1
      }
      print_success "Concluído: $description."
  }

  # Início do setup
  print_info "Iniciando o setup do Git e Bitbucket..."

  # Verificar e executar o script de configuração do GitHub
  check_script_existence "$GITHUB_SCRIPT"
  execute_script "$GITHUB_SCRIPT" "Configuração de múltiplas chaves SSH para GitHub"

  # Verificar e executar o script de configuração do Bitbucket
  check_script_existence "$BITBUCKET_SCRIPT"
  execute_script "$BITBUCKET_SCRIPT" "Configuração de múltiplas chaves SSH para Bitbucket"

  # Verificar e executar o script de configuração do SSH
  check_script_existence "$SSH_CONFIG_SCRIPT"
  execute_script "$SSH_CONFIG_SCRIPT" "Configuração do arquivo SSH"

  # Finalização
  print_success "Setup concluído com sucesso!"
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
  print_info "Operational System: $os"

  # Use the external choose_shell_profile script instead of the internal function
  choose_shell_profile

  # Create and config folders for work and personal
  setup_projects_main

  setup_git_and_bitbucket

  setup_ssh_config_main

  # Chamada da função setup_projects_main

  print_success "Setup concluído com sucesso!"
}

# Executar a função principal
main