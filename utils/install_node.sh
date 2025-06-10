#!/bin/bash

# Script to install Node.js in the correct version (18 or higher)
# This script supports macOS and Linux

# Load color utilities and constants
source "$(dirname "$0")/../utils/colors_message.sh"
source "$(dirname "$0")/../utils/constants.sh"

# Function to check if Node.js is installed and has the correct version
check_node_version() {
  print_info "Checking Node.js version..."

  if ! command -v node &> /dev/null; then
    print_alert "Node.js is not installed."
    return 1
  fi

  node_version=$(node -v | sed 's/v//')
  node_major_version=$(echo "$node_version" | cut -d'.' -f1)

  if [[ "$node_major_version" -lt $NODE_REQUIRED_VERSION ]]; then
    print_alert "Node.js $NODE_REQUIRED_VERSION or higher is required. Current version: $node_version"
    return 1
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
    print_success "Node.js v$NODE_REQUIRED_VERSION installed and set as default."
    return 0
  else
    print_error "Failed to install Node.js v$NODE_REQUIRED_VERSION using NVM."
    return 1
  fi
}

# Function to install Node.js using package manager (for systems without nvm)
install_node_with_package_manager() {
  print_info "Installing Node.js using system package manager..."

  # Detect OS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
      print_alert "Homebrew is not installed. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    print_info "Installing Node.js using Homebrew..."
    brew install node@$NODE_REQUIRED_VERSION

    # Add to PATH if needed
    if ! command -v node &> /dev/null; then
      print_info "Adding Node.js to PATH..."
      echo 'export PATH="/usr/local/opt/node@'$NODE_REQUIRED_VERSION'/bin:$PATH"' >> ~/.bash_profile
      echo 'export PATH="/usr/local/opt/node@'$NODE_REQUIRED_VERSION'/bin:$PATH"' >> ~/.zshrc
      export PATH="/usr/local/opt/node@$NODE_REQUIRED_VERSION/bin:$PATH"
    fi

  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    # Detect distribution
    if command -v apt-get &> /dev/null; then
      # Debian/Ubuntu
      print_info "Installing Node.js on Debian/Ubuntu..."
      curl -fsSL https://deb.nodesource.com/setup_${NODE_REQUIRED_VERSION}.x | sudo -E bash -
      sudo apt-get install -y nodejs

    elif command -v dnf &> /dev/null; then
      # Fedora
      print_info "Installing Node.js on Fedora..."
      sudo dnf install -y nodejs

    elif command -v yum &> /dev/null; then
      # CentOS/RHEL
      print_info "Installing Node.js on CentOS/RHEL..."
      curl -fsSL https://rpm.nodesource.com/setup_${NODE_REQUIRED_VERSION}.x | sudo bash -
      sudo yum install -y nodejs

    elif command -v pacman &> /dev/null; then
      # Arch Linux
      print_info "Installing Node.js on Arch Linux..."
      sudo pacman -S nodejs npm

    else
      print_error "Unsupported Linux distribution. Please install Node.js manually."
      return 1
    fi
  else
    print_error "Unsupported operating system: $OSTYPE"
    return 1
  fi

  # Verify installation
  if command -v node &> /dev/null; then
    node_version=$(node -v | sed 's/v//')
    print_success "Node.js v$node_version installed successfully."
    return 0
  else
    print_error "Failed to install Node.js."
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
install_node() {
  print_header "Node.js Installation Script"

  # Check if Node.js is already installed with correct version
  if check_node_version; then
    print_success "Node.js is already installed with the required version."
    check_npm
    return 0
  fi

  # Try to use NVM first (preferred method)
  if check_nvm || install_nvm; then
    if install_node_with_nvm; then
      check_npm
      return 0
    fi
  fi

  # Fallback to package manager if NVM fails
  print_alert "Falling back to system package manager for Node.js installation..."
  if install_node_with_package_manager; then
    check_npm
    return 0
  fi

  print_error "Failed to install Node.js. Please install Node.js v$NODE_REQUIRED_VERSION manually."
  return 1
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_node "$@"
fi
