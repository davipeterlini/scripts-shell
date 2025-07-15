#!/usr/bin/env bash

# install_coder_cli.sh
# Script to install and configure Coder CLI with pyenv and pipx

set -e

# Import utility scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/colors_message.sh"
source "$SCRIPT_DIR/utils/detect_os.sh"

# Python version to use
PYTHON_VERSION="3.12.9"

# Private functions
_install_pyenv() {
    print_header "Installing pyenv"
    
    # Detect OS using the imported function
    detect_os
    
    if [[ "$OS_NAME" == "Linux" ]]; then
        print_info "Installing pyenv dependencies for Linux..."
        sudo apt-get update
        sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
        
        curl https://pyenv.run | bash
    elif [[ "$OS_NAME" == "macOS" ]]; then
        print_info "Installing pyenv for macOS..."
        brew update
        brew install pyenv
    else
        print_error "Unsupported operating system: $OS_NAME"
        exit 1
    fi
    
    # Add pyenv to shell configuration
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    
    # Also add to current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    print_success "pyenv installed successfully"
}

_install_python_version() {
    print_header "Installing Python $PYTHON_VERSION with pyenv"
    pyenv install $PYTHON_VERSION
    pyenv global $PYTHON_VERSION
    print_success "Python $PYTHON_VERSION installed successfully"
}

_install_pipx() {
    print_header "Installing pipx"
    
    # Make sure we're using the pyenv Python
    pyenv shell $PYTHON_VERSION
    
    # Install pipx using the pyenv Python
    python -m pip install --user pipx
    python -m pipx ensurepath
    
    # Add pipx to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    print_success "pipx installed successfully"
}

_verify_pipx_python() {
    print_header "Verifying pipx Python version"
    
    # Get the Python path used by pipx
    local pipx_python_path=$(pipx environment --value PIPX_LOCAL_VENVS)
    
    if [[ -z "$pipx_python_path" ]]; then
        print_error "Could not determine pipx Python path"
        return 1
    fi
    
    print_info "pipx is using Python from: $pipx_python_path"
    
    # Check if pipx is using the pyenv Python
    local pyenv_python_path=$(pyenv which python)
    print_info "pyenv Python path: $pyenv_python_path"
    
    if pipx environment | grep -q "$PYTHON_VERSION"; then
        print_success "pipx is correctly using Python $PYTHON_VERSION"
        return 0
    else
        print_alert "pipx is not using Python $PYTHON_VERSION"
        
        # Reinstall pipx with the correct Python version
        print_info "Reinstalling pipx with Python $PYTHON_VERSION..."
        python -m pip uninstall -y pipx
        python -m pip install --user pipx
        python -m pipx ensurepath
        
        return 0
    fi
}

_install_coder_cli() {
    print_header "Installing Coder CLI"
    
    # Make sure we're using the pyenv Python
    pyenv shell $PYTHON_VERSION
    
    # Install Coder CLI using pipx
    pipx install https://storage.googleapis.com/flow-coder/flow_coder-1.4.0-py3-none-any.whl
    
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    print_success "Coder CLI installed successfully"
}

_configure_coder_cli() {
    print_header "Configuring Coder CLI"
    
    # Check if already authenticated
    if coder --version &>/dev/null; then
        print_info "Coder CLI version:"
        coder --version
        
        # Try to initialize
        if coder init; then
            print_success "Coder CLI initialized successfully"
            return 0
        fi
    fi
    
    # If we get here, we need to authenticate
    print_alert "Coder CLI authentication required"
    
    read -p "Enter Coder tenant URL: " TENANT
    read -p "Enter client ID: " CLIENT_ID
    read -p "Enter client secret: " CLIENT_SECRET
    
    coder auth add --tenant "$TENANT" --client "$CLIENT_ID" --secret "$CLIENT_SECRET"
    
    if [ $? -eq 0 ]; then
        print_success "Coder CLI authenticated successfully"
    else
        print_error "Failed to authenticate Coder CLI"
        exit 1
    fi
}

# Main function
install_coder_cli() {
    print_header "Coder CLI Installation Script"
    
    # Check if pyenv is installed
    if command -v pyenv &>/dev/null; then
        print_success "pyenv is already installed"
    else
        print_alert "pyenv is not installed"
        _install_pyenv
    fi
    
    # Make sure pyenv is in PATH
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    # Check if Python version is installed
    if pyenv versions | grep -q $PYTHON_VERSION; then
        print_success "Python $PYTHON_VERSION is already installed"
    else
        print_alert "Python $PYTHON_VERSION is not installed"
        _install_python_version
    fi
    
    # Set the Python version as global
    pyenv global $PYTHON_VERSION
    
    # Check if pipx is installed
    if command -v pipx &>/dev/null; then
        print_success "pipx is already installed"
        _verify_pipx_python
    else
        print_alert "pipx is not installed"
        _install_pipx
    fi
    
    # Check if Coder CLI is installed
    if command -v coder &>/dev/null; then
        print_success "Coder CLI is already installed"
    else
        print_alert "Coder CLI is not installed"
        _install_coder_cli
    fi
    
    # Configure Coder CLI
    _configure_coder_cli
    
    print_header "Installation Complete"
    print_info "You can now use Coder CLI with Python $PYTHON_VERSION"
    print_info "Run 'coder --help' for available commands"
}

# Execute main function
install_coder_cli