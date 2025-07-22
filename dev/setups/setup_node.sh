#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/profile_writer.sh"

# Default Node.js version if not specified in environment
DEFAULT_NODE_VERSION="20.11.0"

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

# Private function to configure NPM_TOKEN in shell profile
_configure_npm_token_in_profile() {
  print_info "Configurando NPM_TOKEN no perfil do shell..."
  
  # Check if NPM_TOKEN configuration already exists in .zshrc
  if grep -q "export NPM_TOKEN=" "$HOME/.zshrc" 2>/dev/null; then
    print_info "NPM_TOKEN já está configurado no .zshrc."
    
    if get_user_confirmation "Deseja atualizar o NPM_TOKEN existente?"; then
      # Remove existing NPM_TOKEN entry
      sed -i '/export NPM_TOKEN=/d' "$HOME/.zshrc" 2>/dev/null || true
    else
      print_info "Mantendo o NPM_TOKEN existente."
      return 0
    fi
  fi
  
  # Ask user for NPM_TOKEN value
  print_info "Por favor, informe o valor do seu NPM_TOKEN:"
  read -r npm_token_value
  echo # Add a newline after input
  
  if [ -z "$npm_token_value" ]; then
    print_error "Valor do NPM_TOKEN não fornecido. Configuração cancelada."
    return 1
  fi
  
  # NPM_TOKEN configuration for .zshrc
  local npm_token_config_lines=(
    " "
    "export NPM_TOKEN=\"$npm_token_value\""
  )

  # Use profile_writer to add configuration to .zshrc
  write_lines_to_profile "${npm_token_config_lines[@]}" "$HOME/.zshrc"
  
  print_success "NPM_TOKEN configurado com sucesso no perfil do shell."
  
  # Export the NPM_TOKEN in the current shell session
  export NPM_TOKEN="$npm_token_value"
  
  return 0
}

# Private function to create .npmrc file in user's home directory
_create_npmrc_file() {
  print_info "Criando arquivo .npmrc na pasta home do usuário..."
  
  local npmrc_path="$HOME/.npmrc"
  local assets_npmrc_path="$(dirname "$0")/../../assets/.npmrc"
  
  # Check if .npmrc already exists
  if [ -f "$npmrc_path" ]; then
    print_info "Arquivo .npmrc já existe em $npmrc_path."
    
    if get_user_confirmation "Deseja substituir o arquivo .npmrc existente?"; then
      print_info "Substituindo arquivo .npmrc existente..."
    else
      print_info "Mantendo o arquivo .npmrc existente."
      return 0
    fi
  fi
  
  # Check if the assets/.npmrc file exists
  if [ ! -f "$assets_npmrc_path" ]; then
    print_error "Arquivo de template .npmrc não encontrado em $assets_npmrc_path."
    return 1
  fi
  
  # Check if NPM_TOKEN is set in the environment
  if [ -z "$NPM_TOKEN" ]; then
    print_error "NPM_TOKEN não está definido no ambiente. Execute 'source ~/.zshrc' primeiro."
    return 1
  fi
  
  # Copy the .npmrc file from assets and replace {NPM_TOKEN} with the actual token
  cat "$assets_npmrc_path" | sed "s/{NPM_TOKEN}/$NPM_TOKEN/g" > "$npmrc_path"
  
  if [ $? -eq 0 ]; then
    print_success "Arquivo .npmrc criado com sucesso em $npmrc_path."
    # Set appropriate permissions for security
    chmod 600 "$npmrc_path"
    return 0
  else
    print_error "Falha ao criar o arquivo .npmrc."
    return 1
  fi
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

# Function to get Node.js version to install
_get_node_version() {
  # Check if NODE_REQUIRED_VERSION is already set
  if [ -n "$NODE_REQUIRED_VERSION" ]; then
    print_info "Using Node.js version from environment: $NODE_REQUIRED_VERSION"
    return 0
  fi
  
  # Ask user for Node.js version or use default
  print_info "Node.js version não encontrada nas variáveis de ambiente."
  print_info "Qual versão do Node.js você deseja instalar? (Pressione Enter para usar a versão padrão: $DEFAULT_NODE_VERSION)"
  read -r user_node_version
  
  if [ -z "$user_node_version" ]; then
    NODE_REQUIRED_VERSION="$DEFAULT_NODE_VERSION"
    print_info "Usando a versão padrão do Node.js: $NODE_REQUIRED_VERSION"
  else
    NODE_REQUIRED_VERSION="$user_node_version"
    print_info "Usando a versão especificada do Node.js: $NODE_REQUIRED_VERSION"
  fi
  
  # Export the variable for use in the script
  export NODE_REQUIRED_VERSION
  
  return 0
}

# Private function to install Node.js using NVM
_install_node_with_nvm() {
  # Ensure we have a Node.js version to install
  _get_node_version
  
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
  # Ensure we have a Node.js version to check against
  _get_node_version
  
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

# Function to check if NPM_TOKEN is configured
check_npm_token() {
  print_info "Verificando configuração do NPM_TOKEN..."

  if grep -q "export NPM_TOKEN=" "$HOME/.zshrc" 2>/dev/null; then
    print_success "NPM_TOKEN está configurado no perfil do shell."
    return 0
  else
    print_alert "NPM_TOKEN não está configurado no perfil do shell."
    return 1
  fi
}

# Function to check if .npmrc file exists and is properly configured
check_npmrc_file() {
  print_info "Verificando arquivo .npmrc..."
  
  local npmrc_path="$HOME/.npmrc"
  
  if [ ! -f "$npmrc_path" ]; then
    print_alert "Arquivo .npmrc não encontrado em $npmrc_path."
    return 1
  fi
  
  # Check if .npmrc contains auth token entries
  if grep -q "_authToken" "$npmrc_path"; then
    print_success "Arquivo .npmrc encontrado e contém configurações de autenticação."
    return 0
  else
    print_alert "Arquivo .npmrc encontrado, mas não contém configurações de autenticação."
    return 1
  fi
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
  
  # Check NPM_TOKEN
  if check_npm_token; then
    print_success "✓ NPM_TOKEN verification passed"
  else
    print_error "✗ NPM_TOKEN verification failed"
    verification_failed=true
  fi
  
  # Check .npmrc file
  if check_npmrc_file; then
    print_success "✓ .npmrc file verification passed"
  else
    print_error "✗ .npmrc file verification failed"
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

# Function to apply NPM_TOKEN to current shell and create .npmrc
_apply_npm_token_configuration() {
  print_header_info "Aplicando configuração do NPM_TOKEN"
  
  # Source the profile to load NPM_TOKEN into current shell
  print_info "Carregando configurações do perfil do usuário..."
  if [ -f "$HOME/.zshrc" ]; then
    # Extract and export only the NPM_TOKEN line to avoid sourcing the entire file
    local npm_token_line=$(grep "export NPM_TOKEN=" "$HOME/.zshrc" 2>/dev/null)
    if [ -n "$npm_token_line" ]; then
      eval "$npm_token_line"
      print_success "NPM_TOKEN carregado no shell atual."
    else
      print_error "NPM_TOKEN não encontrado no arquivo de perfil."
      return 1
    fi
  else
    print_error "Arquivo de perfil .zshrc não encontrado."
    return 1
  fi
  
  # Create .npmrc file
  if ! _create_npmrc_file; then
    print_error "Falha ao criar o arquivo .npmrc."
    return 1
  fi
  
  return 0
}

# Main function
setup_node() {
  print_header_info "Check Installation Node (node, nvm, npm)"

  if ! get_user_confirmation "Do you want Check Setup Node ?"; then
      print_info "Skipping configuration"
      return 0
  fi
  
  # Ensure we have a Node.js version to work with
  _get_node_version
    
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
  else
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
  fi
  
  # Step 4: Configure NPM_TOKEN
  print_header_info "Configurando NPM_TOKEN..."
  local npm_token_updated=false
  if ! check_npm_token || get_user_confirmation "Deseja atualizar o NPM_TOKEN existente?"; then
    if _configure_npm_token_in_profile; then
      npm_token_updated=true
    else
      print_error "Falha ao configurar o NPM_TOKEN."
      # Continue with verification even if NPM_TOKEN setup fails
    fi
  else
    print_info "NPM_TOKEN já está configurado. Pulando esta etapa."
  fi
  
  # Step 5: Apply NPM_TOKEN configuration and create .npmrc file
  if $npm_token_updated || ! check_npmrc_file || get_user_confirmation "Deseja recriar o arquivo .npmrc?"; then
    if ! _apply_npm_token_configuration; then
      print_error "Falha ao aplicar a configuração do NPM_TOKEN."
      # Continue with verification even if .npmrc setup fails
    fi
  else
    print_info "Arquivo .npmrc já está configurado. Pulando esta etapa."
  fi

  # Step 6: Verify installation
  print_header_info "Verifying installation..."
  if _verify_node_setup; then
    print_success "Node.js setup completed successfully!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Restart your terminal or run: source ~/.zshrc"
    print_info "2. Verify installation with: node --version && npm --version"
    print_info "3. Check NVM with: nvm --version"
    print_info "4. Verify NPM_TOKEN with: echo \$NPM_TOKEN"
    print_info "5. Check .npmrc file with: cat ~/.npmrc"
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