#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

# Function to check if Node.js is installed and has the correct version
check_node_version() {
  print_info "Checking Node.js version..."

  # The NODE_REQUIRED_VERSION variable is already defined in constants.sh as readonly

  if ! command -v node &> /dev/null; then
    print_alert "Node.js is not installed."
    return 1
  fi

  node_version=$(node -v | sed 's/v//')
  
  # Check the exact version
  if [[ "$node_version" != "$NODE_REQUIRED_VERSION" ]]; then
    print_alert "Node.js version $NODE_REQUIRED_VERSION is required. Current version: $node_version"
    
    # Check if NVM is available
    if command -v nvm &> /dev/null || [ -f "$HOME/.nvm/nvm.sh" ]; then
      print_info "Using NVM to install and configure Node.js $NODE_REQUIRED_VERSION..."
      
      # Load NVM if necessary
      if [ -f "$HOME/.nvm/nvm.sh" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      fi
      
      # Install the specific version
      if nvm install $NODE_REQUIRED_VERSION; then
        # Use the installed version
        nvm use $NODE_REQUIRED_VERSION
        # Set as default
        nvm alias default $NODE_REQUIRED_VERSION
        print_success "Node.js v$NODE_REQUIRED_VERSION installed and configured as default."
        return 0
      else
        print_error "Failed to install Node.js v$NODE_REQUIRED_VERSION using NVM."
        return 1
      fi
    else
      print_alert "NVM is not installed. Please install NVM first."
      return 1
    fi
  fi

  print_success "Node.js version $node_version is compatible."
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
    return 0
  else
    print_error "Failed to install NVM."
    return 1
  fi
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
  print_header "Check Installation Node (node, nvm, npm)"

  # Check if Node.js is already installed with correct version
  if check_node_version; then
    print_success "Node.js is already installed with the required version."
    check_npm
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