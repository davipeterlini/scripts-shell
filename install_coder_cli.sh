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
    
    # Determine shell profile file
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    # Add pyenv to shell configuration if not already there
    if ! grep -q "pyenv init" "$shell_profile"; then
        print_info "Adding pyenv to $shell_profile"
        echo '' >> "$shell_profile"
        echo '# pyenv configuration' >> "$shell_profile"
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$shell_profile"
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$shell_profile"
        echo 'eval "$(pyenv init -)"' >> "$shell_profile"
    fi
    
    # Also add to current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    print_success "pyenv installed successfully"
    print_alert "You may need to restart your terminal or run 'source $shell_profile' to use pyenv"
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
    
    # Determine shell profile file
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    # Add pipx to PATH in shell profile if not already there
    if ! grep -q "pipx" "$shell_profile"; then
        print_info "Adding pipx to $shell_profile"
        echo '' >> "$shell_profile"
        echo '# pipx configuration' >> "$shell_profile"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_profile"
    fi
    
    # Add pipx to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    print_success "pipx installed successfully"
    print_alert "You may need to restart your terminal or run 'source $shell_profile' to use pipx"
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
    
    # Determine shell profile file
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    # Add pipx bin directory to PATH in shell profile if not already there
    if ! grep -q "pipx" "$shell_profile"; then
        print_info "Adding pipx bin directory to $shell_profile"
        echo '' >> "$shell_profile"
        echo '# pipx configuration' >> "$shell_profile"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_profile"
    fi
    
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Create symlink to ensure coder is in PATH
    if [[ -f "$HOME/.local/bin/coder" ]]; then
        print_info "Coder CLI executable found at $HOME/.local/bin/coder"
    else
        # Try to find the coder executable
        local coder_path=$(find "$HOME/.local" -name "coder" -type f -executable 2>/dev/null | head -n 1)
        if [[ -n "$coder_path" ]]; then
            print_info "Creating symlink for Coder CLI at $HOME/.local/bin/coder"
            mkdir -p "$HOME/.local/bin"
            ln -sf "$coder_path" "$HOME/.local/bin/coder"
        else
            print_error "Could not find Coder CLI executable"
        fi
    fi
    
    print_success "Coder CLI installed successfully"
    print_alert "You may need to restart your terminal or run 'source $shell_profile' to use coder"
}

_configure_coder_cli() {
    print_header "Configuring Coder CLI"
    
    # Ensure coder is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check if coder is available
    if ! command -v coder &>/dev/null; then
        print_error "Coder CLI not found in PATH. Please restart your terminal or source your shell profile"
        print_info "You can manually run: export PATH=\"\$HOME/.local/bin:\$PATH\""
        return 1
    fi
    
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

_verify_installation() {
    print_header "Verifying Installation"
    
    # Ensure PATH includes necessary directories
    export PATH="$HOME/.pyenv/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check pyenv
    if command -v pyenv &>/dev/null; then
        print_success "pyenv is available in PATH"
    else
        print_error "pyenv is not available in PATH"
    fi
    
    # Check Python version
    if command -v python &>/dev/null; then
        local python_version=$(python --version)
        print_success "Python is available: $python_version"
    else
        print_error "Python is not available in PATH"
    fi
    
    # Check pipx
    if command -v pipx &>/dev/null; then
        print_success "pipx is available in PATH"
    else
        print_error "pipx is not available in PATH"
    fi
    
    # Check coder
    if command -v coder &>/dev/null; then
        local coder_version=$(coder --version)
        print_success "Coder CLI is available: $coder_version"
        print_info "Coder CLI executable path: $(which coder)"
    else
        print_error "Coder CLI is not available in PATH"
        
        # Try to find the coder executable
        local coder_path=$(find "$HOME/.local" -name "coder" -type f -executable 2>/dev/null)
        if [[ -n "$coder_path" ]]; then
            print_info "Found Coder CLI at: $coder_path"
            print_info "But it's not in your PATH. Add the directory to your PATH."
        else
            print_error "Could not find Coder CLI executable anywhere"
        fi
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
    
    # Verify installation
    _verify_installation
    
    print_header "Installation Complete"
    print_info "You can now use Coder CLI with Python $PYTHON_VERSION"
    print_info "Run 'coder --help' for available commands"
    
    # Determine shell profile file
    local shell_profile="$HOME/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    fi
    
    print_alert "IMPORTANT: You may need to restart your terminal or run the following command to use coder:"
    print_yellow "source $shell_profile"
    print_yellow "# OR"
    print_yellow "export PATH=\"\$HOME/.local/bin:\$PATH\""
}

# Execute main function
install_coder_cli