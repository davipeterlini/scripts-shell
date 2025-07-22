#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/detect_os.sh"

# Scripts Dev Setup
source "$(dirname "$0")/grant_permissions.sh"
source "$(dirname "$0")/dev/setups/setup_gcloud.sh"
source "$(dirname "$0")/dev/setups/setup_global_env.sh"
source "$(dirname "$0")/dev/setups/setup_ides.sh"
source "$(dirname "$0")/dev/setups/setup_java.sh"
source "$(dirname "$0")/dev/setups/setup_node.sh"
source "$(dirname "$0")/dev/setups/setup_projects.sh"
source "$(dirname "$0")/dev/setups/setup_python.sh"
source "$(dirname "$0")/dev/setups/setup_projects.sh"
source "$(dirname "$0")/dev/setups/setup_vscode.sh"
source "$(dirname "$0")/dev/setups/sync_drive_folders.sh"
source "$(dirname "$0")/dev/installs/install_ai_tools.sh"
source "$(dirname "$0")/flow_coder/install_flow_coder_cli.sh"
source "$(dirname "$0")/flow_coder/install_flow_coder_ide.sh"

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

    setup_gcloud

    setup_node 

    setup_java

    setup_python

    setup_ides

    setup_vscode

    install_ai_tools

    install_flow_coder_cli

    install_flow_coder_ide

    # TODO - Adjust to open desired folders in terminal 
    #open_project_iterm

    print_success "Setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_dev "$@"
fi