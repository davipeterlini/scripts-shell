#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors message
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to configure multiple SSH keys for Bitbucket accounts
configure_multi_ssh_bitbucket_keys() {
    print_info "Configuring multiple SSH keys for Bitbucket accounts..."

    # Create .ssh directory if it doesn't exist
    mkdir -p ~/.ssh

    # Generate SSH key for personal account
    ssh-keygen -t rsa -b 4096 -C "your_personal_email@example.com" -f ~/.ssh/id_rsa_bitbucket_personal

    # Generate SSH key for work account
    ssh-keygen -t rsa -b 4096 -C "your_work_email@company.com" -f ~/.ssh/id_rsa_bitbucket_work

    # Create or update SSH config file
    cat << EOF > ~/.ssh/config
# Personal Bitbucket account
Host bitbucket.org-personal
    HostName bitbucket.org
    User git
    IdentityFile ~/.ssh/id_rsa_bitbucket_personal

# Work Bitbucket account
Host bitbucket.org-work
    HostName bitbucket.org
    User git
    IdentityFile ~/.ssh/id_rsa_bitbucket_work
EOF

    print_success "Multiple SSH keys for Bitbucket accounts configured successfully."
    print_info "Remember to add these public keys to your respective Bitbucket accounts."
}

# Execute the function
configure_multi_ssh_bitbucket_keys