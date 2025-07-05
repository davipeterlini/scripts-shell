#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/detect_os.sh"
#source "$(dirname "$0")/utils/generic_utils.sh"

# Scripts Dev
source "$(dirname "$0")/grant_permissions.sh"
source "$(dirname "$0")/dev/setup_projects.sh"
source "$(dirname "$0")/dev/sync_drive_folders.sh"
source "$(dirname "$0")/dev/setup_global_env.sh"
#source "$(dirname "$0")/dev/install_flow_coder.sh"
#source "$(dirname "$0")/dev/open_project_iterm.sh"

# Função principal
setup_dev() {
    print_info "Start Setup for Development Enviroment"
    load_env

    detect_os
    grant_permissions

    setup_projects

    sync_drive_folders
    
    # TODO - ajustar script para que grave o .env na pasta sincronizada do drive 
    setup_global_env

    #install_flow_coder

    # TODO - Ajustar para abrir as pastas desejadas no terminal 
    #open_project_iterm

    print_success "Setup concluído com sucesso!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_dev "$@"
fi