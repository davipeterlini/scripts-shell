#!/bin/bash

# Utils
source "$(dirname "$0")/../utils/load_env.sh"
load_env
source "$(dirname "$0")/../utils/colors_message.sh"
source "$(dirname "$0")/../utils/detect_os.sh"
source "$(dirname "$0")/../utils/choose_shell_profile.sh"

# Scripts
source "$(dirname "$0")/../github/configure_multi_ssh_bitbucket_keys.sh"
source "$(dirname "$0")/../bitbucket/configure_multi_ssh_bitbucket_keys.sh"
source "$(dirname "$0")/setup_ssh_config.sh"
source "$(dirname "$0")/setup_projects.sh"
source "$(dirname "$0")/sync_drive_folders.sh"
#source "$(dirname "$0")/setup_global_env.sh"
#source "$(dirname "$0")/open_project_iterm.sh"


# Função principal
main() {

  # Detect the operating system
  os=$(detect_os)
  print_info "Operational System: $os"

  # Use the external choose_shell_profile script instead of the internal function
  choose_shell_profile

  # Config SSH key for github
  setup_github_accounts

  # Config SSH key for bitbucket
  setup_bitbucket_accounts

  # Config Multi account with git
  setup_ssh_config

  # Create and config folders for work and personal
  setup_projects

  # Create and Sync folder for google drive
  #sync_drive_folders

  # TODO - ajustar script para que grave o .env na pasta sincronizada do drive 
  #setup_global_env

  # TODO - Ajustar para abrir as pastas desejadas no terminal 
  #open_project_iterm

  print_success "Setup concluído com sucesso!"
}

# Executar a função principal
main