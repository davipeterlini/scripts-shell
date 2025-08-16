#!/bin/bash

# Script to configure multiple SSH keys for Bitbucket accounts
# Following Clean Code and Clean Architecture principles
# Using shared utility functions for common operations

# Get absolute directory of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source required utilities
source "${PROJECT_ROOT}/utils/colors_message.sh"
source "${PROJECT_ROOT}/utils/load_env.sh"
source "${PROJECT_ROOT}/utils/bash_tools.sh"
source "${PROJECT_ROOT}/utils/git_utils.sh"

BITBUCKET_API_URL="https://api.bitbucket.org/2.0"
BITBUCKET_WEB_URL="https://bitbucket.org"

# ===== BITBUCKET API INTEGRATION =====
__handle_bitbucket_auth() {
  if [ -n "$BITBUCKET_APP_PASSWORD" ]; then
    print_info "BITBUCKET_APP_PASSWORD environment variable detected."
    print_info "To use a different App Password, you need to clear this variable."
    
    if get_user_confirmation "Do you want to clear BITBUCKET_APP_PASSWORD and enter a new one?"; then
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
  local ssh_key_path="$HOME/.ssh/id_rsa_bitbucket_${label}"
  
  # Ensure required tools are installed
  ensure_command_installed "curl" "curl"
  ensure_command_installed "jq" "jq"
  
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
  
  read -p "Enter a name for the SSH key: " api_key_name
  
  # Add the key to Bitbucket
  local response=$(___add_key_to_bitbucket "$username" "$app_password" "$key_content_file" "$api_key_name")
  
  # Process the response
  ___process_bitbucket_api_response "$response" "$label" "$key_content_file"
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
    ENV_LOCAL_FILE="${PROJECT_ROOT}/assets/.env.local"
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
  # Read public key content and remove line breaks
  key_content=$(cat "$key_content_file" | tr -d '\n')
  
  # Create temporary JSON file with key content
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
  test_ssh_connection "$label" "bitbucket"
  
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

# Function to implement the Bitbucket-specific configuration
# This function is called by the generic setup_git_account function in git_utils.sh
configure_bitbucket_account() {
  local label="$1"
  local email="$2"
  local username="$3"

  # Associate generated SSH key with remote account
  print_info "Associating generated SSH key with Bitbucket account"
  __handle_bitbucket_auth
  __associate_ssh_key_with_bitbucket "$label" "$username"

  print_success "Bitbucket configuration completed for username: $username email: $email."
  
  return 0
}

# Main function to configure multiple Bitbucket accounts
setup_bitbucket_accounts() {
  # Use the shared function from git_utils.sh
  setup_git_account "bitbucket"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_bitbucket_accounts "$@"
fi