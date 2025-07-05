#!/bin/bash

# Script to set up and test Flow Coder
# This script orchestrates the Flow Coder setup and testing process

# Imports Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/detect_os.sh"
source "$(dirname "$0")/utils/generic_utils.sh"
source "$(dirname "$0")/utils/grant_permissions.sh"
# Imports Scripts
source "$(dirname "$0")/install_ides.sh"
source "$(dirname "$0")/install_flow_coder.sh"
source "$(dirname "$0")/open_ides.sh"
source "$(dirname "$0")/test_flow_coder.sh"


setup() {
    print_header "Starting Setup Test with VM Flow Coder installation..."

    detect_os

    grant_permissions
    install_ides "$os"
    install_flow_coder "$os"
    open_ides "$os"
    test_flow_coder "$os"

    print_success "Flow Coder installation process completed."
}

# Execute the setup function
setup