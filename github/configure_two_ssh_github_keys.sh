#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env
source "$(dirname "$0")/../utils/colors_message.sh"

configure_ssh_config() {
  local label="$1"
  local ssh_key_path="$2"
  local ssh_config_path="$HOME/.ssh/config"

  print_info "Checking configuration for github.com-${label}..."
  if grep -q "Host github.com-${label}" "$ssh_config_path"; then
    print_alert "Configuration for github.com-${label} already exists."
    read -p "Do you want to overwrite it? (y/n): " overwrite
    if [[ $overwrite != "y" ]]; then
      print_info "Skipping configuration for github.com-${label}"
      return
    fi
    # Remove existing configuration
    sed -i.bak "/Host github.com-${label}/,/^$/d" "$ssh_config_path"
    print_info "Existing configuration removed."
  fi

  print_info "Configuring SSH config file for label $label..."
  
  # Ensure there's exactly one blank line at the end of the file
  sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$ssh_config_path"
  echo "" >> "$ssh_config_path"

  {
    echo "Host github.com-${label}"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $ssh_key_path"
  } >> "$ssh_config_path"

  print_success "Configuration for github.com-${label} added to SSH config file."
}

# Main script
print_info "Configuring SSH for two GitHub accounts..."

# Personal account
configure_ssh_config "personal" "$SSH_KEY_PERSONAL"

# Work account
configure_ssh_config "work" "$SSH_KEY_WORK"

# Ensure there's exactly one blank line at the end of the file
sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$HOME/.ssh/config"
echo "" >> "$HOME/.ssh/config"

print_success "SSH configuration complete. Please ensure you have the correct SSH keys generated and added to your GitHub accounts."