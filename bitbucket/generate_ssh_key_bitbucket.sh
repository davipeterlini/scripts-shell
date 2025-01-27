#!/bin/bash

# Function to prompt user to choose an identity
choose_identity() {
  echo "Available Projects:"
  echo "  1) personal"
  echo "  2) work"
  echo
  read -p "Please choose an identity by number: " IDENTITY_NUMBER

  case $IDENTITY_NUMBER in
    1)
      IDENTITY="personal"
      ;;
    2)
      IDENTITY="work"
      ;;
    *)
      echo "Invalid choice. Exiting..."
      exit 1
      ;;
  esac
}

# Choose identity
choose_identity

# Ask for the user's Bitbucket email address
read -p "Enter your Bitbucket email address: " bitbucket_email
echo "Setting up SSH key for the email address: $bitbucket_email"

# Check if the SSH key already exists
if [[ -f ~/.ssh/id_rsa_bitbucket_$IDENTITY.pub ]]; then
    echo "An SSH key for Bitbucket ($IDENTITY) already exists."
else
    # Generate a new SSH key for the provided email
    ssh-keygen -t rsa -b 4096 -C "$bitbucket_email" -f ~/.ssh/id_rsa_bitbucket_$IDENTITY

    # Ensure ssh-agent is running
    eval "$(ssh-agent -s)"

    # On macOS, configure SSH to use Keychain
    if [[ "$OSTYPE" == "darwin"* ]]; then
        [[ ! -d ~/.ssh ]] && mkdir ~/.ssh
        [[ ! -f ~/.ssh/config ]] && touch ~/.ssh/config
        echo "Host bitbucket.org-$IDENTITY
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa_bitbucket_$IDENTITY" >> ~/.ssh/config

        # Add the SSH key to the ssh-agent and store passphrase in keychain.
        ssh-add -K ~/.ssh/id_rsa_bitbucket_$IDENTITY
    else # For Linux
        # Add the SSH key to the ssh-agent
        ssh-add ~/.ssh/id_rsa_bitbucket_$IDENTITY
    fi
fi

# Copy the SSH public key to the clipboard for adding to Bitbucket
if command -v pbcopy >/dev/null; then
    pbcopy < ~/.ssh/id_rsa_bitbucket_$IDENTITY.pub
    echo "The SSH public key has been copied to your clipboard."
elif command -v xclip >/dev/null; then
    xclip -selection clipboard < ~/.ssh/id_rsa_bitbucket_$IDENTITY.pub
    echo "The SSH public key has been copied to your clipboard."
elif command -v xsel >/dev/null; then
    xsel --clipboard < ~/.ssh/id_rsa_bitbucket_$IDENTITY.pub
    echo "The SSH public key has been copied to your clipboard."
else
    echo "SSH public key:"
    cat ~/.ssh/id_rsa_bitbucket_$IDENTITY.pub
    echo "Please install xclip or xsel to copy the SSH public key automatically, or manually copy the key from above."
fi

echo "Please add this SSH key to your Bitbucket account. Navigate to Bitbucket Personal Settings -> SSH keys -> Add key."