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

    print_info "Associating generated SSH key with remote account"
    associate_ssh_key_with_bitbucket "$label" "$email"

    print_success "Bitbucket configuration completed for username: $name email: $email."
}

# Function to check if curl is installed
ensure_curl_installed() {
    if ! command -v curl &> /dev/null; then
        print_info "curl is not installed. Installing..."
        if [[ "$(uname)" == "Darwin" ]]; then
            brew install curl
        elif [[ "$(uname)" == "Linux" ]]; then
            sudo apt update
            sudo apt install -y curl
        else
            print_error "Unsupported operating system for automatic curl installation."
            print_info "Please install curl manually and run this script again."
            exit 1
        fi
    fi
}

# Function to associate SSH key with Bitbucket
associate_ssh_key_with_bitbucket() {
    local label=$1
    local email=$2
    local ssh_key_path="$HOME/.ssh/id_rsa_bb_${label}"

    ensure_curl_installed

    print_info "Associating SSH key with Bitbucket for $label..."
    
    print_alert "IMPORTANT: Please ensure you have your Bitbucket App Password ready."
    print_info "You can create an App Password at: https://bitbucket.org/account/settings/app-passwords/"
    
    read -p "Enter your Bitbucket username: " bb_username
    read -s -p "Enter your Bitbucket App Password: " bb_app_password
    echo

    # Read the public key content
    local key_content=$(cat "${ssh_key_path}.pub")

    # Create a temporary file for the JSON payload
    local temp_file=$(mktemp)
    cat > "$temp_file" << EOF
{
    "key": "$key_content",
    "label": "SSH key for $label"
}
EOF

    # Add the SSH key to Bitbucket using the REST API
    local response=$(curl -s -u "${bb_username}:${bb_app_password}" \
         -X POST \
         -H "Content-Type: application/json" \
         -d @"$temp_file" \
         https://api.bitbucket.org/2.0/users/${bb_username}/ssh-keys)

    # Clean up the temporary file
    rm "$temp_file"

    if echo "$response" | grep -q "error"; then
        print_error "Failed to associate SSH key with Bitbucket for $label."
        print_error "Response: $response"
    else
        print_success "SSH key successfully associated with Bitbucket for $label."
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

    print_success "Setup completed for $label."

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