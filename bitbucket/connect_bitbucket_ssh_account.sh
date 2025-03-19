#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors message
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to connect to Bitbucket SSH account
connect_bitbucket_ssh() {
    print_info "Connecting to Bitbucket SSH account..."

    # Test the SSH connection to Bitbucket
    ssh -T git@bitbucket.org

    if [ $? -eq 0 ]; then
        print_success "Successfully connected to Bitbucket via SSH."
    else
        print_error "Failed to connect to Bitbucket via SSH. Please check your SSH key and Bitbucket account settings."
    fi
}

# Execute the function
connect_bitbucket_ssh