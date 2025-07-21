#!/bin/bash

# Utils - defining paths to point to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_DIR="$(cd "$SCRIPT_DIR/../" && pwd)"

# Load necessary utilities
source "$ROOT_DIR/utils/colors_message.sh"
source "$ROOT_DIR/utils/load_env.sh"
source "$ROOT_DIR/utils/detect_os.sh"

# Dev Scripts - importing necessary scripts
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

# Main function
setup_dev() {
    print_header "Start Setup for Development Enviroment"
    load_env

    detect_os
    # TODO - fix so it's only called when script is run directly
    #grant_permissions

    sync_drive_folders

    # TODO - adjust script to save .env in synchronized drive folder 
    setup_global_env

    setup_projects

    setup_node 

    setup_java

    setup_ides

    setup_python

    setup_vscode

    install_ai_tools

    install_flow_coder_cli

    # TODO - Test
    #install_flow_coder_ide

    # TODO - Adjust to open desired folders in terminal 
    #open_project_iterm

    print_success "Setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_dev "$@"
fi