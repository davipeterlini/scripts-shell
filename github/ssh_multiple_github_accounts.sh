#!/bin/bash

# Function to generate SSH key for a given email and label
generate_ssh_key() {
    local email="$1"
    local label="$2"
    local key_path="$HOME/.ssh/id_rsa_$label"

    if [[ -f "$key_path" ]]; then
        echo "SSH key for $label already exists."
    else
        echo "Generating SSH key for $label..."
        ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_path" -N ""
    fi

    # Add the SSH key to the ssh-agent
    eval "$(ssh-agent -s)"
    ssh-add "$key_path"
}

# Function to configure SSH config file
configure_ssh_config() {
    local label="$1"
    local key_path="$HOME/.ssh/id_rsa_$label"

    if ! grep -q "Host github.com-$label" ~/.ssh/config; then
        echo "Configuring SSH for $label..."
        cat >> ~/.ssh/config <<EOL

Host github.com-$label
    HostName github.com
    User git
    IdentityFile $key_path
EOL
    else
        echo "SSH config for $label already exists."
    fi
}

# Function to configure Git global settings
configure_git() {
    local label="$1"
    local email="$2"
    local name="$3"

    echo "Configuring Git for $label..."
    git config --global user.name "$name"
    git config --global user.email "$email"
}

# Main function to setup multiple GitHub accounts
setup_github_accounts() {
    echo "Setting up multiple GitHub accounts..."

    # Account 1
    read -p "Enter email for GitHub account 1: " email1
    read -p "Enter label for GitHub account 1 (e.g., work): " label1
    read -p "Enter name for GitHub account 1: " name1
    generate_ssh_key "$email1" "$label1"
    configure_ssh_config "$label1"
    configure_git "$label1" "$email1" "$name1"

    # Account 2
    read -p "Enter email for GitHub account 2: " email2
    read -p "Enter label for GitHub account 2 (e.g., personal): " label2
    read -p "Enter name for GitHub account 2: " name2
    generate_ssh_key "$email2" "$label2"
    configure_ssh_config "$label2"
    configure_git "$label2" "$email2" "$name2"

    echo "Setup completed. Please add the generated SSH keys to your GitHub accounts."
}

# Execute the setup
setup_github_accounts