#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/profile_writer.sh"

# Private function to load NVM in current shell
_load_nvm() {
  # Use the same configuration that will be written to .zshrc
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  
  # Check if NVM was loaded successfully
  if command -v nvm &> /dev/null || type nvm &> /dev/null; then
    return 0
  fi
  return 1
}

# Private function to check if NVM is properly loaded
_is_nvm_loaded() {
  if command -v nvm &> /dev/null || type nvm &> /dev/null; then
    return 0
  fi
  return 1
}

# Private function to configure NVM in shell profile
_configure_nvm_in_profile() {
  print_info "Configuring NVM in shell profile..."
  
  # Check if NVM configuration already exists in .zshrc
  if grep -q "NVM_DIR.*nvm" "$HOME/.zshrc" 2>/dev/null; then
    print_success "NVM configuration already exists in .zshrc."
    return 0
  fi
  
  # Remove any existing NVM entries added by this script
  remove_script_entries_from_profile "setup_node.sh" "$HOME/.zshrc"
  
  # NVM configuration for .zshrc - using the exact format specified
  local nvm_config_lines=(
    "# NVM Configuration"
    "export NVM_DIR=\"\$([ -z \"\${XDG_CONFIG_HOME-}\" ] && printf %s \"\${HOME}/.nvm\" || printf %s \"\${XDG_CONFIG_HOME}/nvm\")\""
    "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\" # This loads nvm"
    "[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\" # This loads nvm bash_completion"
  )

  # Use profile_writer to add configuration to .zshrc
  write_lines_to_profile "${nvm_config_lines[@]}" "$HOME/.zshrc"
  
  print_success "NVM configuration added to shell profile."
  return 0
}

# Private function to install NVM
_install_nvm() {
  print_info "Installing NVM (Node Version Manager)..."

  # Determine NVM directory using the same logic as the configuration
  local nvm_dir="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

  # Check if NVM directory already exists
  if [ -d "$nvm_dir" ]; then
    print_info "NVM directory already exists at $nvm_dir. Checking installation..."
    if _load_nvm && _is_nvm_loaded; then
      print_success "NVM is already installed and working."
      _configure_nvm_in_profile
      return 0
    else
      print_alert "NVM directory exists but NVM is not working properly. Reinstalling..."
      rm -rf "$nvm_dir"
    fi
  fi

  # Install NVM using the official install script
  print_info "Downloading and installing NVM..."
  if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash; then
    print_success "NVM installation script completed."
  else
    print_error "Failed to download or execute NVM installation script."
    return 1
  fi

  # Load NVM in current shell
  print_info "Loading NVM in current shell..."
  if _load_nvm; then
    print_success "NVM loaded successfully in current shell."
  else
    print_error "Failed to load NVM in current shell."
    return 1
  fi

  # Verify NVM is working
  if _is_nvm_loaded; then
    print_success "NVM installed and verified successfully."
    
    # Configure NVM in profile using our custom configuration
    _configure_nvm_in_profile
    
    return 0
  else
    print_error "NVM installation failed - command not available."
    return 1
  fi
}

# Private function to install Node.js using NVM
_install_node_with_nvm() {
  print_info "Installing Node.js v$NODE_REQUIRED_VERSION using NVM..."

  # Ensure NVM is loaded
  if ! _is_nvm_loaded; then
    print_info "Loading NVM..."
    if ! _load_nvm || ! _is_nvm_loaded; then
      print_error "NVM is not available. Cannot install Node.js."
      return 1
    fi
  fi

  # Install the required Node.js version
  print_info "Running: nvm install $NODE_REQUIRED_VERSION"
  if nvm install "$NODE_REQUIRED_VERSION"; then
    print_success "Node.js v$NODE_REQUIRED_VERSION installed successfully."
  else
    print_error "Failed to install Node.js v$NODE_REQUIRED_VERSION using NVM."
    return 1
  fi

  # Use the installed version
  print_info "Setting Node.js v$NODE_REQUIRED_VERSION as current version..."
  if nvm use "$NODE_REQUIRED_VERSION"; then
    print_success "Now using Node.js v$NODE_REQUIRED_VERSION."
  else
    print_error "Failed to switch to Node.js v$NODE_REQUIRED_VERSION."
    return 1
  fi

  # Set as default version
  print_info "Setting Node.js v$NODE_REQUIRED_VERSION as default version..."
  if nvm alias default "$NODE_REQUIRED_VERSION"; then
    print_success "Node.js v$NODE_REQUIRED_VERSION set as default."
  else
    print_error "Failed to set Node.js v$NODE_REQUIRED_VERSION as default."
    return 1
  fi

  return 0
}

# Function to check if Node.js is installed and has the correct version
check_node_version() {
  print_info "Checking Node.js version..."

  if ! command -v node &> /dev/null; then
    print_alert "Node.js is not installed."
    return 1
  fi

  local node_version=$(node -v | sed 's/v//')
  print_info "Current Node.js version: $node_version"
  print_info "Required Node.js version: $NODE_REQUIRED_VERSION"
  
  # Check if version matches exactly
  if [[ "$node_version" == "$NODE_REQUIRED_VERSION" ]]; then
    print_success "Node.js version $node_version matches required version."
    return 0
  else
    print_alert "Node.js version mismatch. Current: $node_version, Required: $NODE_REQUIRED_VERSION"
    return 1
  fi
}

# Function to check if NVM is installed
check_nvm() {
  print_info "Checking for NVM (Node Version Manager)..."

  # Try to load NVM first
  _load_nvm

  # Check if NVM is available
  if _is_nvm_loaded; then
    local nvm_version=$(nvm --version 2>/dev/null || echo "unknown")
    print_success "NVM is installed and loaded. Version: $nvm_version"
    return 0
  fi

  # Check if NVM directory exists but not loaded
  local nvm_dir="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  if [ -d "$nvm_dir" ]; then
    print_alert "NVM directory exists at $nvm_dir but NVM is not loaded properly."
    return 1
  fi

  print_alert "NVM is not installed."
  return 1
}

# Function to check npm installation
check_npm() {
  print_info "Checking npm installation..."

  if ! command -v npm &> /dev/null; then
    print_alert "npm is not installed."
    return 1
  fi

  local npm_version=$(npm -v)
  print_success "npm version $npm_version is available."
  return 0
}

# Function to verify complete Node.js setup
_verify_node_setup() {
  print_header_info "Verifying Node.js Setup"
  
  local verification_failed=false
  
  # Check Node.js
  if check_node_version; then
    print_success "✓ Node.js verification passed"
  else
    print_error "✗ Node.js verification failed"
    verification_failed=true
  fi
  
  # Check npm
  if check_npm; then
    print_success "✓ npm verification passed"
  else
    print_error "✗ npm verification failed"
    verification_failed=true
  fi
  
  # Check NVM
  if check_nvm; then
    print_success "✓ NVM verification passed"
  else
    print_error "✗ NVM verification failed"
    verification_failed=true
  fi
  
  if [ "$verification_failed" = true ]; then
    print_error "Node.js setup verification failed!"
    return 1
  else
    print_success "All Node.js components verified successfully!"
    return 0
  fi
}

# Main function
setup_node() {
  print_header_info "Check Installation Node (node, nvm, npm)"

  if ! get_user_confirmation "Do you want Check Setup Node ?"; then
      print_info "Skipping configuration"
      return 0
  fi
    
  # Step 1: Check if Node.js is already installed with correct version
  if check_node_version && check_npm; then
    print_success "Node.js is already installed with the required version."
    
    # Still check and configure NVM if needed
    if ! check_nvm; then
      print_info "NVM is not properly configured. Setting it up..."
      if _install_nvm; then
        print_success "NVM setup completed."
      else
        print_error "Failed to setup NVM, but Node.js is working."
      fi
    else
      # Ensure NVM configuration is in .zshrc even if NVM is working
      _configure_nvm_in_profile
    fi
    
    _verify_node_setup
    return 0
  fi

  # Step 2: Install/Setup NVM
  print_header_info "Setting up NVM..."
  if ! check_nvm; then
    if ! _install_nvm; then
      print_error "Failed to install NVM. Cannot proceed with Node.js installation."
      return 1
    fi
  else
    print_success "NVM is already available."
    # Ensure configuration is properly written to .zshrc
    _configure_nvm_in_profile
  fi

  # Step 3: Install Node.js using NVM
  print_header_info "Installing Node.js..."
  if ! _install_node_with_nvm; then
    print_error "Failed to install Node.js using NVM."
    return 1
  fi

  # Step 4: Verify installation
  print_header_info "Verifying installation..."
  if _verify_node_setup; then
    print_success "Node.js setup completed successfully!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Restart your terminal or run: source ~/.zshrc"
    print_info "2. Verify installation with: node --version && npm --version"
    print_info "3. Check NVM with: nvm --version"
    print_info ""
    return 0
  else
    print_error "Node.js setup completed but verification failed."
    return 1
  fi
}

# Check if the script is being executed directly or imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # If executed directly, load environment and execute main function
    load_env
    setup_node "$@"
fi