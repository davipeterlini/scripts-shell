#!/bin/bash

# Script for installation and configuration of Google Cloud SDK (gcloud)

source "$(dirname "$0")/utils/colors_message.sh"
source "gcloud/install_gcloud_tools.sh"
source "gcloud/config_gcloud.sh"

setup_gcloud() {
    print_header "Starting Google Cloud SDK setup"
    
    # Install Google Cloud SDK
    install_gcloud_tools
    
    # Configure Google Cloud SDK
    config_gcloud
    
    print_success "Google Cloud SDK setup completed successfully!"
    
    return 0
}

# Execute main only if the script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_gcloud "$@"
fi