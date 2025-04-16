#!/bin/bash

# Script to configure multiple SSH keys for Bitbucket accounts
# TODO - esse script precisa fazer como é feito no script do github 
# e abrir o terminal e depois salvar a chave no https://bitbucket.org/account/settings/ssh-keys/
# TODO - não está gerando o token da forma correta

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors message
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to generate an SSH key
generate_ssh_key() {
  local email="$1"
  local label="$2"
  local ssh_key_path="$HOME/.ssh/id_rsa_bb_${label}"

  print_info "Generating SSH key for $email with label $label..."
  # Generate the SSH key automatically without prompts
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

  print_info "Adding the SSH key to the agent..."
  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key_path"

  print_success "Generated public key:"
  cat "${ssh_key_path}.pub"
}

add_or_update_config() {
  local label="$1"
  local ssh_key_path="$HOME/.ssh/id_rsa_bb_${label}"
  local ssh_config_path="$HOME/.ssh/config"

  print_info "Checking configuration for bitbucket.org-${label}..."
  if grep -q "Host bitbucket.org-${label}" "$ssh_config_path"; then
    print_alert "Configuration for bitbucket.org-${label} already exists."
    read -p "Do you want to overwrite it? (y/n): " overwrite
    if [[ $overwrite != "y" ]]; then
      print_info "Skipping configuration for bitbucket.org-${label}"
      return
    fi
    # Remove existing configuration
    sed -i.bak "/Host bitbucket.org-${label}/,/^$/d" "$ssh_config_path"
    print_info "Existing configuration removed."
  fi

  # Ensure there's exactly one blank line at the end of the file
  sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$ssh_config_path"
  echo "" >> "$ssh_config_path"

  print_info "Configuring SSH config file for label $label..."
  {
    echo "Host bitbucket.org-${label}"
    echo "  HostName bitbucket.org"
    echo "  User git"
    echo "  IdentityFile $ssh_key_path"
  } >> "$ssh_config_path"

  print_success "Configuration for bitbucket.org-${label} added to SSH config file."
}

# Function to configure Git
configure_git() {
    local label=$1
    local email=$2
    local name=$3

    # Add the new method call here
    print_info "Associating generated SSH key with remote account"
    handle_bitbucket_cli_auth
    associate_ssh_key_with_bitbucket "$label"

    print_success "Bitbucket configuration completed for username: $name email: $email."
}

# Function to handle Bitbucket CLI authentication
handle_bitbucket_cli_auth() {
    if [ -n "$BITBUCKET_TOKEN" ]; then
        print_info "BITBUCKET_TOKEN environment variable detected."
        print_info "To have Bitbucket CLI store credentials, you need to clear this variable."
        read -p "Do you want to clear BITBUCKET_TOKEN and let Bitbucket CLI handle authentication? (y/n): " clear_token
        if [ "$clear_token" = "y" ]; then
            # TODO - precisa ter o gh auth logout
            unset BITBUCKET_TOKEN
            print_success "BITBUCKET_TOKEN has been cleared. Bitbucket CLI will now prompt for authentication."
        else
            print_info "BITBUCKET_TOKEN remains set. Bitbucket CLI will use this for authentication."
        fi
    else
        print_info "No BITBUCKET_TOKEN detected. Bitbucket CLI will handle authentication normally."
    fi
}

# Function to associate SSH key with Bitbucket
associate_ssh_key_with_bitbucket() {
    local label=$1
    #local email=$2
    local ssh_key_path="$HOME/.ssh/id_rsa_bb_${label}"

    ensure_gh_installed

    print_info "Associating SSH key with Bitbucket for $label..."
    
    # Alert the user to log in with the correct account
    print_alert "IMPORTANT: Please ensure you are logged into the correct Bitbucket account in your browser."
    print_info "The account should match the email and name you provided for $label."

    print_info "Please authenticate with Bitbucket CLI:"
    print_info "Generating Bitbucket token with repo and workflow permissions..."
    gh auth login -s repo,workflow

    # Add the SSH key to Bitbucket
    gh ssh-key add "$ssh_key_path.pub" --title "SSH key for $label"

    if [ $? -eq 0 ]; then
        print_success "SSH key successfully associated with Bitbucket for $label."
    else
        print_error "Failed to associate SSH key with Bitbucket for $label."
    fi
}

# Function to check if gh is installed and install it if not
ensure_gh_installed() {
    if ! command -v gh &> /dev/null; then
        print_info "Bitbucket CLI (gh) is not installed. Installing..."
        if [[ "$(uname)" == "Darwin" ]]; then
            brew install gh
        elif [[ "$(uname)" == "Linux" ]]; then
            # For Ubuntu/Debian-based systems
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh
        else
            print_error "Unsupported operating system for automatic gh installation."
            print_info "Please install Bitbucket CLI (gh) manually and run this script again."
            exit 1
        fi
    fi
}

# Main function to configure multiple Bitbucket accounts
setup_bitbucket_accounts() {
  print_info "Setting up multiple Bitbucket accounts..."

  while true; do
    # Account
    read -p "Enter email for Bitbucket account: " email
    read -p "Enter label for Bitbucket account (e.g., work, personal, ...): " label
    read -p "Enter username for Bitbucket account: " name

    generate_ssh_key "$email" "$label"
    add_or_update_config "$label"
    configure_git "$label" "$email" "$name"

    print_success "Setup completed for $label. Please add the generated SSH keys to your Bitbucket account."

    # Ask if the user wants to configure another Bitbucket account
    read -p "Do you want to configure another Bitbucket account? (Y/N): " choice
    case "$choice" in
      [Yy]* ) continue ;;
      [Nn]* ) break ;;
          * ) echo -e "${RED}Please answer Y (yes) or N (no).${NC}" ;;
    esac
  done

  print_success "Multiple Bitbucket accounts configuration completed!"
}

# Execute the main function
setup_bitbucket_accounts