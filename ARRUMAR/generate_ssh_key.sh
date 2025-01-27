#!/bin/bash

# Ask for the user's Gmail address
read -p "Enter your Gmail username (before @gmail.com): " gmail_username
email="$gmail_username@gmail.com"
echo "Setting up SSH key for the email address: $email"

# Check if the SSH key already exists
if [[ -f ~/.ssh/id_rsa.pub ]]; then
    echo "An SSH key already exists."
else
    # Generate a new SSH key for the provided email
    ssh-keygen -t rsa -b 4096 -C "$email"

    # Ensure ssh-agent is running
    eval "$(ssh-agent -s)"

    # On macOS, configure SSH to use Keychain
    if [[ "$OSTYPE" == "darwin"* ]]; then
        [[ ! -d ~/.ssh ]] && mkdir ~/.ssh
        [[ ! -f ~/.ssh/config ]] && touch ~/.ssh/config
        echo "Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config

        # Add the SSH key to the ssh-agent and store passphrase in keychain.
        ssh-add -K ~/.ssh/id_rsa
    else # For Linux
        # Add the SSH key to the ssh-agent
        ssh-add ~/.ssh/id_rsa
    fi
fi

# Copy the SSH public key to the clipboard for adding to GitHub
if command -v pbcopy >/dev/null; then
    pbcopy < ~/.ssh/id_rsa.pub
    echo "The SSH public key has been copied to your clipboard."
elif command -v xclip >/dev/null; then
    xclip -selection clipboard < ~/.ssh/id_rsa.pub
    echo "The SSH public key has been copied to your clipboard."
elif command -v xsel >/dev/null; then
    xsel --clipboard < ~/.ssh/id_rsa.pub
    echo "The SSH public key has been copied to your clipboard."
else
    echo "SSH public key:"
    cat ~/.ssh/id_rsa.pub
    echo "Please install xclip or xsel to copy the SSH public key automatically, or manually copy the key from above."
fi

echo "Please add this SSH key to your GitHub account. Navigate to GitHub Settings -> SSH and GPG keys -> New SSH key."
