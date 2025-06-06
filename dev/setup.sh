#!/bin/bash

# Utils
source "$(dirname "$0")/../utils/load_env.sh"
load_env
source "$(dirname "$0")/../utils/detect_os.sh"
source "$(dirname "$0")/../utils/colors_message.sh"
source "$(dirname "$0")/../utils/choose_shell_profile.sh"

# Scripts
source "$(dirname "$0")/setup_projects.sh" 
source "$(dirname "$0")/setup_ssh_config.sh"
source "$(dirname "$0")/../github/configure_multi_ssh_bitbucket_keys.sh"
source "$(dirname "$0")/../bitbucket/configure_multi_ssh_bitbucket_keys.sh"
#source "$(dirname "$0")/setup_global_env.sh"
#source "$(dirname "$0")/open_project_iterm.sh"


# Função principal
main() {

  # Detect the operating system
  os=$(detect_os)
  print_info "Operational System: $os"

  # Use the external choose_shell_profile script instead of the internal function
  choose_shell_profile

  # Create and config folders for work and personal
  #setup_projects_main

  setup_github_accounts

  setup_bitbucket_accounts

  setup_ssh_config_main

  #setup_global_env_main

  #open_project_iterm

  # Chamada da função setup_projects_main

  print_success "Setup concluído com sucesso!"
}

# Executar a função principal
main