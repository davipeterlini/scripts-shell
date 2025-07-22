#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/profile_writer.sh"

# Function to check if Node.js is installed and has the correct version
check_node_version() {
  print_info "Checking Node.js version..."

  # A variável NODE_REQUIRED_VERSION já está definida em constants.sh como readonly

  if ! command -v node &> /dev/null; then
    print_alert "Node.js is not installed."
    return 1
  fi

  node_version=$(node -v | sed 's/v//')
  
  # Verificar a versão exata
  if [[ "$node_version" != "$NODE_REQUIRED_VERSION" ]]; then
    print_alert "Node.js versão $NODE_REQUIRED_VERSION é necessária. Versão atual: $node_version"
    
    # Verificar se o NVM está disponível
    if command -v nvm &> /dev/null || [ -f "$HOME/.nvm/nvm.sh" ]; then
      print_info "Usando NVM para instalar e configurar Node.js $NODE_REQUIRED_VERSION..."
      
      # Carregar NVM se necessário
      if [ -f "$HOME/.nvm/nvm.sh" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      fi
      
      # Instalar a versão específica
      if nvm install $NODE_REQUIRED_VERSION; then
        # Usar a versão instalada
        nvm use $NODE_REQUIRED_VERSION
        # Configurar como padrão
        nvm alias default $NODE_REQUIRED_VERSION
        print_success "Node.js v$NODE_REQUIRED_VERSION instalado e configurado como padrão."
        return 0
      else
        print_error "Falha ao instalar Node.js v$NODE_REQUIRED_VERSION usando NVM."
        return 1
      fi
    else
      print_alert "NVM não está instalado. Por favor, instale o NVM primeiro."
      return 1
    fi
  fi

  print_success "Node.js versão $node_version é compatível."
  return 0
}

# Function to check if nvm is installed
check_nvm() {
  print_info "Checking for NVM (Node Version Manager)..."

  # Check if nvm is available as a command
  if command -v nvm &> /dev/null; then
    print_success "NVM is installed."
    return 0
  fi

  # Check if nvm is available as a function (common case)
  if [ -f "$HOME/.nvm/nvm.sh" ]; then
    print_success "NVM is installed but needs to be loaded."
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    return 0
  fi

  print_alert "NVM is not installed."
  return 1
}

# Function to install nvm
install_nvm() {
  print_info "Installing NVM (Node Version Manager)..."

  # Install nvm using the official install script
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

  # Setup nvm in the current shell
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # Verify installation
  if command -v nvm &> /dev/null; then
    print_success "NVM installed successfully."
    
    # Configurar NVM no .zshrc usando profile_writer
    _configure_nvm_in_profile
    
    return 0
  else
    print_error "Failed to install NVM."
    return 1
  fi
}

# Function to configure NVM in .zshrc
_configure_nvm_in_profile() {
  print_info "Configuring NVM in shell profile..."
  
  # Configuração do NVM para .zshrc
  local nvm_config="export NVM_DIR=\"\$HOME/.nvm\"
[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"  # This loads nvm
[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"  # This loads nvm bash_completion"

  # Usar o profile_writer para adicionar a configuração ao .zshrc
  write_lines_to_profile "$nvm_config" "$HOME/.zshrc"
  
  print_success "NVM configuration added to shell profile."
}

# Function to install Node.js using nvm
install_node_with_nvm() {
  print_info "Installing Node.js v$NODE_REQUIRED_VERSION using NVM..."

  # Install the required Node.js version
  if nvm install $NODE_REQUIRED_VERSION; then
    # Use the installed version
    nvm use $NODE_REQUIRED_VERSION
    # Set as default
    nvm alias default $NODE_REQUIRED_VERSION
    print_success "Node.js v$NODE_REQUIRED_VERSION installed and set as default."
    return 0
  else
    print_error "Failed to install Node.js v$NODE_REQUIRED_VERSION using NVM."
    return 1
  fi
}

# Function to check npm installation
check_npm() {
  print_info "Checking npm installation..."

  if ! command -v npm &> /dev/null; then
    print_alert "npm is not installed."
    return 1
  fi

  npm_version=$(npm -v)
  print_success "npm version $npm_version is available."
  return 0
}

# Main function
setup_node() {
  print_header_info "Check Installation Node (node, nvm, npm)"

  if ! get_user_confirmation "Do you want Check Setup Node ?"; then
      print_info "Skipping configuration"
      return 0
  fi
    
  # Check if Node.js is already installed with correct version
  if check_node_version; then
    print_success "Node.js is already installed with the required version."
    check_npm
    
    # Verificar se a configuração do NVM está no .zshrc
    if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
      print_info "NVM configuration not found in .zshrc. Adding it now..."
      _configure_nvm_in_profile
    else
      print_success "NVM configuration already exists in .zshrc."
    fi
    
    return 0
  fi

  # Use NVM for Node.js installation
  if check_nvm || install_nvm; then
    if install_node_with_nvm; then
      check_npm
      return 0
    fi
  fi

  print_error "Failed to install Node.js. Please install NVM and Node.js v$NODE_REQUIRED_VERSION manually."
  return 1
}

# Check if the script is being executed directly or imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # If executed directly, load environment and execute main function
    load_env
    setup_node "$@"
fi