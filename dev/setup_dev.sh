#!/bin/bash

# Utils - definindo os caminhos para apontar para a raiz do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_DIR="$(cd "$SCRIPT_DIR/../" && pwd)"

# Carrega as utilidades necessárias
source "$ROOT_DIR/utils/colors_message.sh"
source "$ROOT_DIR/utils/load_env.sh"
source "$ROOT_DIR/utils/detect_os.sh"

# Scripts Dev - importando os scripts necessários
source "$ROOT_DIR/grant_permissions.sh"
source "$SCRIPT_DIR/setups/setup_projects.sh"
source "$SCRIPT_DIR/setups/sync_drive_folders.sh"
source "$SCRIPT_DIR/setups/setup_global_env.sh"
source "$SCRIPT_DIR/setups/setup_node.sh"
source "$SCRIPT_DIR/setups/setup_java.sh"
source "$SCRIPT_DIR/setups/setup_ides.sh"
source "$SCRIPT_DIR/setups/setup_vscode.sh"
source "$SCRIPT_DIR/installs/install_ai_tools.sh"
source "$SCRIPT_DIR/setups/setup_python.sh"
source "$ROOT_DIR/flow_coder/install_flow_coder_cli.sh"
source "$ROOT_DIR/flow_coder/install_flow_coder_ide.sh"
#source "$SCRIPT_DIR/open_project_iterm.sh"

# Função principal
setup_dev() {
    print_header "Start Setup for Development Enviroment"
    load_env

    detect_os
    # TODO - arrumar para que seja chamado apenas quando o script for chamado diretamente
    #grant_permissions

    sync_drive_folders

    # TODO - ajustar script para que grave o .env na pasta sincronizada do drive 
    setup_global_env

    setup_projects

    setup_node 

    setup_java

    setup_ides

    setup_python

    setup_vscode

    install_ai_tools

    install_flow_coder_cli

    # TODO - Testar
    #install_flow_coder_ide

    # TODO - Ajustar para abrir as pastas desejadas no terminal 
    #open_project_iterm

    print_success "Setup concluído com sucesso!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_dev "$@"
fi