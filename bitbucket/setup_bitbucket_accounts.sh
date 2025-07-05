#!/bin/bash

# Script to configure multiple SSH keys for Bitbucket accounts
# Following Clean Code and Clean Architecture principles

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

BITBUCKET_API_URL="https://api.bitbucket.org/2.0"
BITBUCKET_WEB_URL="https://bitbucket.org"

# Define SSH directory
SSH_DIR="${HOME}/.ssh"

# Ensure SSH directory exists
_ensure_ssh_dir() {
  if [ ! -d "$SSH_DIR" ]; then
    print_info "Creating SSH directory at $SSH_DIR"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
  fi
}

# ===== SSH KEY MANAGEMENT =====
_generate_ssh_key() {
  local email="$1"
  local label="$2"
  local ssh_key_path="${SSH_DIR}/id_rsa_bb_${label}"

  print_info "BitBucket - Generating SSH key for $email with label $label..."
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

  print_info "Adding the SSH key to the agent..."
  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key_path"

  print_success "Generated public key:"
  cat "${ssh_key_path}.pub"
}

# ===== SSH CONFIG MANAGEMENT =====
_update_ssh_config() {
  local label="$1"
  local ssh_key_path="${SSH_DIR}/id_rsa_bb_${label}"
  local ssh_config_path="${SSH_DIR}/config"

  # Create config file if it doesn't exist
  if [ ! -f "$ssh_config_path" ]; then
    print_info "Creating SSH config file at $ssh_config_path"
    touch "$ssh_config_path"
    chmod 600 "$ssh_config_path"
  fi

  print_info "Checking configuration for bitbucket.org-${label}..."
  
  if grep -q "Host bitbucket.org-${label}" "$ssh_config_path"; then
    if ! confirm_action "Configuration for bitbucket.org-${label} already exists. Do you want to overwrite it?"; then
      print_info "Skipping configuration for bitbucket.org-${label}"
      return 0
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
  
  return 0
}

# ===== MAIN WORKFLOW =====
_configure_git_account() {
  local label="$1"
  local email="$2"
  local username="$3"

  # Associate generated SSH key with remote account
  print_info "Associating generated SSH key with remote account"
  __handle_bitbucket_auth
  __associate_ssh_key_with_bitbucket "$label" "$username"

  print_success "Bitbucket configuration completed for username: $username email: $email."
  
  return 0
}

# ===== BITBUCKET API INTEGRATION =====
__handle_bitbucket_auth() {
  if [ -n "$BITBUCKET_APP_PASSWORD" ]; then
    print_info "BITBUCKET_APP_PASSWORD environment variable detected."
    print_info "To use a different App Password, you need to clear this variable."
    
    if confirm_action "Do you want to clear BITBUCKET_APP_PASSWORD and enter a new one?"; then
      unset BITBUCKET_APP_PASSWORD
      print_success "BITBUCKET_APP_PASSWORD has been cleared. You will be prompted for a new App Password."
    else
      print_info "BITBUCKET_APP_PASSWORD remains set. This will be used for authentication."
    fi
  else
    print_info "No BITBUCKET_APP_PASSWORD detected. You will be prompted for an App Password."
  fi
  
  return 0
}

__associate_ssh_key_with_bitbucket() {
  local label="$1"
  local username="$2"
  local ssh_key_path="${SSH_DIR}/id_rsa_bb_${label}"
  
  # Ensure required tools are installed
  ___ensure_curl_installed
  ___ensure_jq_installed
  
  print_info "Associating SSH key with Bitbucket for $label..."
  
  # Get app password (from env or user input)
  local app_password="${BITBUCKET_APP_PASSWORD:-APP_PASSWORD}"
  
  print_alert "IMPORTANT: Please ensure you are logged into the correct Bitbucket account in your browser."
  
  if [[ "$app_password" == "APP_PASSWORD" ]]; then
    ____prompt_for_app_password
    app_password="$APP_PASSWORD"
  fi
  
  # Read and prepare the SSH key
  local key_content_file="${ssh_key_path}.pub"
  
  print
  read -p "Enter a name for the SSH key: " api_key_name
  
  # Add the key to Bitbucket
  local response=$(___add_key_to_bitbucket "$username" "$app_password" "$key_content_file" "$api_key_name")
  
  # Process the response
  ___process_bitbucket_api_response "$response" "$label" "$key_content_file"
}

___ensure_curl_installed() {
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
  
  return 0
}

___ensure_jq_installed() {
  if ! command -v jq &> /dev/null; then
    print_info "jq is not installed. Installing..."
    if [[ "$(uname)" == "Darwin" ]]; then
      brew install jq
    elif [[ "$(uname)" == "Linux" ]]; then
      sudo apt update
      sudo apt install -y jq
    else
      print_error "Unsupported operating system for automatic jq installation."
      print_info "Please install jq manually and run this script again."
      exit 1
    fi
  fi
  
  return 0
}

____prompt_for_app_password() {
  # Get the appropriate open command for the OS
  local open_cmd=$(_____get_open_command)
  if [ $? -eq 0 ]; then
    read -p "Press Enter to open Bitbucket App Password settings in your browser... "
    $open_cmd "${BITBUCKET_WEB_URL}/account/settings/app-passwords/" &> /dev/null
  else
    print_info "Please manually open: ${BITBUCKET_WEB_URL}/account/settings/app-passwords/"
  fi
  
  print_info "Create an App Password with 'Account: Write' permission."
  local app_password
  read -s -p "Enter your Bitbucket App Password: " app_password
  echo
  
  # Save app password to .env.local
  _____save_app_password_to_env "$app_password"
  
  export APP_PASSWORD="$app_password"
}

_____get_open_command() {
  if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v open &> /dev/null; then
      print_error "The 'open' command is not available on your system."
      return 1
    fi
    echo "open"
  elif [[ "$(uname)" == "Linux" ]]; then
    if command -v xdg-open &> /dev/null; then
      echo "xdg-open"
    elif command -v gnome-open &> /dev/null; then
      echo "gnome-open"
    else
      print_error "No suitable command to open URLs found on your system."
      print_info "Please install xdg-open or manually open the URL in your browser."
      return 1
    fi
  else
    print_error "Unsupported operating system."
    return 1
  fi
  
  return 0
}

_____save_app_password_to_env() {
  local app_password="$1"
  
  # Create ENV_LOCAL_FILE if it doesn't exist
  if [ -z "$ENV_LOCAL_FILE" ]; then
    ENV_LOCAL_FILE=".env.local"
  fi
  
  # Create directory for ENV_LOCAL_FILE if it doesn't exist
  local env_dir=$(dirname "$ENV_LOCAL_FILE")
  if [ ! -d "$env_dir" ] && [ "$env_dir" != "." ]; then
    mkdir -p "$env_dir"
  fi
  
  # Create file if it doesn't exist
  if [ ! -f "$ENV_LOCAL_FILE" ]; then
    touch "$ENV_LOCAL_FILE"
  fi
  
  if grep -q "^BITBUCKET_APP_PASSWORD=" "$ENV_LOCAL_FILE"; then
    sed -i.bak "/^BITBUCKET_APP_PASSWORD=/d" "$ENV_LOCAL_FILE"
  fi
  echo "BITBUCKET_APP_PASSWORD=$app_password" >> "$ENV_LOCAL_FILE"
  print_success "App password saved to $ENV_LOCAL_FILE."
  
  return 0
}

___add_key_to_bitbucket() {
  local username="$1"
  local app_password="$2"
  local key_content_file="$3"
  local api_key_name="$4"
  
  # Create a JSON payload for the API request
  local temp_file=$(mktemp)
  # Lê o conteúdo da chave pública e remove quebras de linha
  key_content=$(cat "$key_content_file" | tr -d '\n')
  
  # Cria o arquivo JSON temporário com o conteúdo da chave
  cat > "$temp_file" << EOF
{
  "key": "$key_content",
  "label": "$api_key_name"
}
EOF

  # Add the SSH key to Bitbucket using the REST API
  print_info "Adding SSH key to Bitbucket..."
  
  # Create auth header with proper Base64 encoding
  local auth_header="Authorization: Basic $(echo -n "${username}:${app_password}" | base64)"
  
  local response=$(curl -s \
       -X POST \
       -H "Content-Type: application/json" \
       -H "$auth_header" \
       -d @"$temp_file" \
       "${BITBUCKET_API_URL}/users/${username}/ssh-keys")
  
  # Check for errors in the response
  if echo "$response" | grep -q "error"; then
    print_error "Failed to add SSH key to Bitbucket:"
    echo "$response" | jq -r '.error.message' 2>/dev/null || echo "$response"
    print_info "Please verify that your SSH key is valid and in the correct format."
    print_info "The key should be a valid SSH public key (typically starting with ssh-rsa, ssh-ed25519, etc.)"
    return 1
  else
    print_success "SSH key successfully added to Bitbucket!"
  fi
  
  # Clean up the temporary file
  rm "$temp_file"
  
  echo "$response"
}

___process_bitbucket_api_response() {
  local response="$1"
  local label="$2"
  local key_content="$3"
  
  # Check if the key was added successfully
  if echo "$response" | grep -q "\"uuid\""; then
    ____handle_successful_key_addition "$response" "$label"
  else
    ____handle_failed_key_addition "$response" "$key_content"
  fi
  
  return 0
}

____handle_successful_key_addition() {
  local response="$1"
  local label="$2"
  
  print_success "SSH key successfully added to your Bitbucket account!"
  
  # Extract and display the key UUID
  local key_uuid=$(echo "$response" | grep -o '"uuid": *"[^"]*"' | cut -d'"' -f4)
  print_info "Key UUID: $key_uuid"
  
  # Test the SSH connection
  _____test_ssh_connection "$label"
  
  return 0
}

_____test_ssh_connection() {
  local label="$1"
  
  print_info "Testing SSH connection to Bitbucket..."
  ssh -T -o StrictHostKeyChecking=no git@bitbucket.org-${label} || true
  
  print_info "If you see a message like 'logged in as [username]', the SSH key is working correctly."
  
  return 0
}

____handle_failed_key_addition() {
  local response="$1"
  local key_content="$2"
  
  print_error "Failed to add SSH key to Bitbucket."
  print_error "API Response: $response"
  
  # Provide alternative manual instructions
  _____provide_manual_key_addition_instructions "$key_content"
  
  return 1
}

_____provide_manual_key_addition_instructions() {
  local key_content="$1"
  
  print_alert "You may need to add the SSH key manually to your Bitbucket account."
  print_info "1. Copy your public key:"
  echo "$key_content"
  print_info "2. Go to Bitbucket settings: ${BITBUCKET_WEB_URL}/account/settings/ssh-keys/"
  print_info "3. Click 'Add key' and paste your public key"
  
  # Open the SSH keys page in the browser
  local open_cmd=$(_____get_open_command)
  if [ $? -eq 0 ]; then
    read -p "Press Enter to open Bitbucket SSH keys page in your browser... "
    $open_cmd "${BITBUCKET_WEB_URL}/account/settings/ssh-keys/" &> /dev/null
  fi
}

setup_bitbucket_accounts() {
  print_header "Setting up multiple Bitbucket accounts..."

  # Ensure SSH directory exists
  _ensure_ssh_dir

  # Load environment variables
  load_env .env.personal
  load_env .env.work

  if ! confirm_action "Do you want to set up multiple Bitbucket accounts?"; then
    print_info "Skipping configuration"
    return 0
  fi

  while true; do
    # Get account details
    read -p "Enter email for Bitbucket account: " email
    read -p "Enter label for Bitbucket account (e.g., work, personal, ...): " label
    read -p "Enter username for Bitbucket account: " username

    _generate_ssh_key "$email" "$label"
    _update_ssh_config "$label"
    _configure_git_account "$label" "$email" "$username"

    print_success "Setup completed for $label. Please add the generated SSH keys to your Bitbucket account."

    # Ask if the user wants to configure another Bitbucket account
    if ! confirm_action "Do you want to configure another Bitbucket account?"; then
      break
    fi
  done

  print_success "Multiple Bitbucket accounts configuration completed!"
  
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_bitbucket_accounts "$@"
fi