#!/bin/bash

# Load environment variables from .env file
source "$(dirname "$(realpath "$0")")/../utils/load_env.sh"
load_env

# Function to prompt user to choose a repository manager
choose_repo_manager() {
  echo "Available Repository Managers:"
  local index=1
  for repo_manager in $(env | grep '^REPO_MANAGER_' | sed 's/^REPO_MANAGER_//' | sed 's/=.*//'); do
    echo "  $index) $(echo $repo_manager | tr '[:upper:]' '[:lower:]')"  # Convert to lowercase
    index=$((index + 1))
  done
  echo
  read -p "Please choose a repository manager by number: " REPO_MANAGER_NUMBER

  local index=1
  for repo_manager in $(env | grep '^REPO_MANAGER_' | sed 's/^REPO_MANAGER_//' | sed 's/=.*//'); do
    if [ "$index" -eq "$REPO_MANAGER_NUMBER" ]; then
      REPO_MANAGER=$(echo $repo_manager | tr '[:upper:]' '[:lower:]')
      break
    fi
    index=$((index + 1))
  done

  if [ -z "$REPO_MANAGER" ]; then
    echo "Invalid choice. Exiting..."
    exit 1
  fi
}

# Choose repository manager
choose_repo_manager

# Function to generate SSH key for a given email and label
generate_ssh_key() {
    local email="$1"
    local label="$2"
    local key_path="$HOME/.ssh/id_rsa_${REPO_MANAGER}_$label"

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
    local key_path="$HOME/.ssh/id_rsa_${REPO_MANAGER}_$label"

    if ! grep -q "Host ${REPO_MANAGER}.org-$label" ~/.ssh/config; then
        echo "Configuring SSH for $label..."
        cat >> ~/.ssh/config <<EOL

Host ${REPO_MANAGER}.org-$label
    HostName ${REPO_MANAGER}.org
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

# Function to generate add_identity script
generate_add_identity_script() {
    local label="$1"
    local email="$2"
    local token_var="${REPO_MANAGER^^}_TOKEN_${label^^}"  # Convert repo manager and label to uppercase for the token variable
    local ssh_key="$HOME/.ssh/id_rsa_${REPO_MANAGER}_$label"

    cat > "add_identity_${label}.sh" <<EOL
#!/bin/bash
./add_identity.sh $label $ssh_key \$$token_var
EOL

    chmod +x "add_identity_${label}.sh"
    echo "Script add_identity_${label}.sh generated."
}

# Main function to setup multiple repository accounts
setup_repo_accounts() {
    echo "Setting up multiple ${REPO_MANAGER^} accounts..."

    # Account 1
    read -p "Enter email for ${REPO_MANAGER^} account 1: " email1
    read -p "Enter label for ${REPO_MANAGER^} account 1 (e.g., work): " label1
    read -p "Enter name for ${REPO_MANAGER^} account 1: " name1
    generate_ssh_key "$email1" "$label1"
    configure_ssh_config "$label1"
    configure_git "$label1" "$email1" "$name1"
    generate_add_identity_script "$label1" "$email1"

    # Account 2
    read -p "Enter email for ${REPO_MANAGER^} account 2: " email2
    read -p "Enter label for ${REPO_MANAGER^} account 2 (e.g., personal): " label2
    read -p "Enter name for ${REPO_MANAGER^} account 2: " name2
    generate_ssh_key "$email2" "$label2"
    configure_ssh_config "$label2"
    configure_git "$label2" "$email2" "$name2"
    generate_add_identity_script "$label2" "$email2"

    echo "Setup completed. Please add the generated SSH keys to your ${REPO_MANAGER^} accounts."
}

# Execute the setup
setup_repo_accounts