#!/bin/bash

# Utility functions for Git repository management and SSH key setup
# This script centralizes common functionality used by both GitHub and Bitbucket setup scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors_message.sh"
source "${SCRIPT_DIR}/bash_tools.sh"

# Function to generate an SSH key for a Git host
generate_ssh_key() {
  local email="$1"
  local label="$2"
  local service="$3"  # 'github' or 'bitbucket'
  local ssh_key_path="$HOME/.ssh/id_rsa_${service}_${label}"

  print_info "${service^} - Generating SSH key for $email with label $label..."
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

  print_info "Adding the SSH key to the agent..."
  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key_path"

  print_success "Generated public key:"
  cat "${ssh_key_path}.pub"
  
  return 0
}

# Function to update SSH config for Git service
update_ssh_config() {
  local label="$1"
  local service="$2"  # 'github' or 'bitbucket'
  local ssh_key_path="$HOME/.ssh/id_rsa_${service}_${label}"
  local ssh_config_path="$HOME/.ssh/config"
  local host_name="${service}.com"
  local ssh_dir="$HOME/.ssh"

  # Check if .ssh directory exists, if not create it
  if [ ! -d "$ssh_dir" ]; then
    print_info "Creating .ssh directory..."
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
  fi

  # Check if config file exists, if not create it
  if [ ! -f "$ssh_config_path" ]; then
    print_info "SSH config file does not exist. Creating it..."
    touch "$ssh_config_path"
    chmod 600 "$ssh_config_path"
  fi

  print_info "Checking configuration for ${host_name}-${label}..."
  if grep -q "Host ${host_name}-${label}" "$ssh_config_path" 2>/dev/null; then
    print_alert "Configuration for ${host_name}-${label} already exists."
    if ! get_user_confirmation "Do you want to overwrite it?"; then
      print_info "Skipping configuration for ${host_name}-${label}"
      return 0
    fi
    # Remove existing configuration
    sed -i.bak "/Host ${host_name}-${label}/,/^$/d" "$ssh_config_path" 2>/dev/null
    print_info "Existing configuration removed."
  fi

  # Ensure there's exactly one blank line at the end of the file if the file is not empty
  if [ -s "$ssh_config_path" ]; then
    sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$ssh_config_path" 2>/dev/null
    echo "" >> "$ssh_config_path"
  fi

  print_info "Configuring SSH config file for ${service} with label $label..."
  {
    echo "Host ${host_name}-${label}"
    echo "  HostName ${host_name}"
    echo "  User git"
    echo "  IdentityFile $ssh_key_path"
    echo ""
  } >> "$ssh_config_path"

  print_success "Configuration for ${host_name}-${label} added to SSH config file."
  
  return 0
}

# Function to test SSH connection
test_ssh_connection() {
  local label="$1"
  local service="$2"  # 'github' or 'bitbucket'
  local host="${service}.com"
  
  print_info "Testing SSH connection to ${service^}..."
  ssh -T -o StrictHostKeyChecking=no git@${host}-${label} || true
  
  print_info "If you see a message confirming your identity, the SSH key is working correctly."
  
  return 0
}

# Function to check if a command is installed, and install if not
ensure_command_installed() {
  local command_name="$1"
  local package_name="${2:-$command_name}"
  
  if ! command -v "$command_name" &> /dev/null; then
    print_info "$command_name is not installed. Installing..."
    if [[ "$(uname)" == "Darwin" ]]; then
      brew install "$package_name"
    elif [[ "$(uname)" == "Linux" ]]; then
      sudo apt update
      sudo apt install -y "$package_name"
    else
      print_error "Unsupported operating system for automatic installation."
      print_info "Please install $command_name manually and run this script again."
      return 1
    fi
  fi
  
  return 0
}

# Function to set up a Git service account
setup_git_account() {
  print_header_info "Setting up multiple Git service accounts..."

  if ! get_user_confirmation "Do you want to set up multiple Git accounts?"; then
    print_info "Skipping configuration"
    return 0
  fi

  # Load environment variables
  load_env .env.personal
  load_env .env.work

  local service="$1"  # 'github' or 'bitbucket'

  while true; do
    # Get account details
    read -p "Enter email for ${service^} account: " email
    read -p "Enter label for ${service^} account (e.g., work, personal, ...): " label
    read -p "Enter username for ${service^} account: " username

    generate_ssh_key "$email" "$label" "$service"
    update_ssh_config "$label" "$service"
    
    if [[ "$service" == "github" ]]; then
      configure_github_account "$label" "$email" "$username"
    elif [[ "$service" == "bitbucket" ]]; then
      configure_bitbucket_account "$label" "$email" "$username"
    fi

    print_success "Setup completed for $label. Please add the generated SSH keys to your ${service^} account."

    # Ask if the user wants to configure another account
    if ! get_user_confirmation "Do you want to configure another ${service^} account?"; then
      break
    fi
  done

  print_success "Multiple ${service^} accounts configuration completed!"
  
  return 0
}

# These function stubs must be implemented in the specific service scripts
# that source this utility file

configure_github_account() {
  print_error "configure_github_account function must be implemented in the GitHub script"
  return 1
}

configure_bitbucket_account() {
  print_error "configure_bitbucket_account function must be implemented in the Bitbucket script"
  return 1
}