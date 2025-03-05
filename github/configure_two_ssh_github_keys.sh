#!/bin/bash

# Load environment variables
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Function to check if configuration exists
check_config_exists() {
    local host=$1
    if grep -q "Host $host" ~/.ssh/config; then
        return 0
    else
        return 1
    fi
}

# Function to add or update SSH configuration
add_or_update_config() {
    local host=$1
    local identity_file=$2
    local user=$3

    if check_config_exists "$host"; then
        echo "Configuration for $host already exists in ~/.ssh/config"
        read -p "Do you want to overwrite it? (y/n): " overwrite
        if [[ $overwrite != "y" ]]; then
            echo "Skipping configuration for $host"
            return
        fi
        # Remove existing configuration
        sed -i.bak "/Host $host/,/Host /d" ~/.ssh/config
    fi

    echo "Adding configuration for $host to ~/.ssh/config"
    cat << EOF >> ~/.ssh/config

Host $host
    HostName github.com
    User $user
    IdentityFile $identity_file
EOF
}

# Main script
echo "Configuring SSH for two GitHub accounts..."

# Personal account
add_or_update_config "github.com-personal" "$SSH_KEY_PERSONAL" "git"

# Work account
add_or_update_config "github.com-work" "$SSH_KEY_WORK" "git"

echo "SSH configuration complete. Please ensure you have the correct SSH keys generated and added to your GitHub accounts."