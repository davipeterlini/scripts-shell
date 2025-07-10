#!/bin/bash

# Flow Coder CLI Installation Script
# This script installs Python 3.12.9, pyenv, pipx, and Flow Coder CLI
# Compatible with Linux and macOS

set -e  # Exit immediately if a command exits with a non-zero status

###########################################
# PRIVATE FUNCTIONS (Internal use only)
###########################################

# Color codes for better readability
_GREEN='\033[0;32m'
_BLUE='\033[0;34m'
_YELLOW='\033[0;33m'
_RED='\033[0;31m'
_NC='\033[0m' # No Color

# Function to display informational messages
_log_message() {
    echo -e "${_BLUE}[INFO]${_NC} $1"
}

# Function to display success messages
_log_success() {
    echo -e "${_GREEN}[SUCCESS]${_NC} $1"
}

# Function to display warning messages
_log_warning() {
    echo -e "${_YELLOW}[WARNING]${_NC} $1"
}

# Function to display error messages
_log_error() {
    echo -e "${_RED}[ERROR]${_NC} $1"
}

# Function to check if a command exists
_command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect operating system
_detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        _log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Function to detect shell profile
_detect_shell_profile() {
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *zsh ]]; then
        if [[ -f "$HOME/.zshrc" ]]; then
            echo "$HOME/.zshrc"
        else
            echo "$HOME/.zshrc"  # Create it if it doesn't exist
        fi
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *bash ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
            echo "$HOME/.bashrc"
        else
            echo "$HOME/.bash_profile"
        fi
    else
        # Default to .profile if shell can't be determined
        echo "$HOME/.profile"
    fi
}

# Function to install dependencies based on OS
_install_dependencies() {
    local os=$1
    _log_message "Installing dependencies for $os..."
    
    if [[ "$os" == "linux" ]]; then
        # Linux dependencies
        sudo apt-get update -y || sudo yum update -y || sudo dnf update -y
        sudo apt-get install -y curl wget git build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
            xz-utils tk-dev libffi-dev liblzma-dev python-openssl || \
        sudo yum install -y curl wget git gcc zlib-devel bzip2 bzip2-devel readline-devel \
            sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel || \
        sudo dnf install -y curl wget git gcc zlib-devel bzip2 bzip2-devel readline-devel \
            sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
    elif [[ "$os" == "macos" ]]; then
        # macOS dependencies
        if ! _command_exists xcode-select; then
            _log_message "Installing command line tools..."
            xcode-select --install || true
        fi
        
        # Check if we need to install additional dependencies
        if ! _command_exists make || ! _command_exists gcc; then
            _log_warning "Some development tools might be missing. If installation fails, please install Xcode Command Line Tools."
        fi
    fi
    
    _log_success "Dependencies installed successfully."
}

# Function to install Python 3.12.9 from source
_install_python_from_source() {
    local install_dir="$HOME/.local/python3.12.9"
    
    if [[ -d "$install_dir" ]]; then
        _log_warning "Python 3.12.9 already installed at $install_dir"
        return 0
    fi
    
    _log_message "Installing Python 3.12.9 from source..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download Python source
    _log_message "Downloading Python 3.12.9 source..."
    wget https://www.python.org/ftp/python/3.12.9/Python-3.12.9.tgz
    
    # Extract source
    tar -xzf Python-3.12.9.tgz
    cd Python-3.12.9
    
    # Configure and install Python
    _log_message "Configuring Python 3.12.9..."
    ./configure --prefix="$install_dir" --enable-optimizations
    
    _log_message "Building Python 3.12.9 (this may take a while)..."
    make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)
    
    _log_message "Installing Python 3.12.9..."
    make install
    
    # Clean up
    cd "$HOME"
    rm -rf "$temp_dir"
    
    _log_success "Python 3.12.9 installed successfully at $install_dir"
}

# Function to configure pyenv in shell profile
_configure_pyenv_profile() {
    local profile=$1
    
    # Check if pyenv is already in the profile
    if ! grep -q "pyenv init" "$profile"; then
        _log_message "Adding pyenv to $profile..."
        cat >> "$profile" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF
    fi
}

# Function to install Python with pyenv
_install_python_with_pyenv() {
    # Check if Python 3.12.9 is already installed with pyenv
    if pyenv versions | grep -q "3.12.9"; then
        _log_warning "Python 3.12.9 already installed with pyenv"
    else
        # Use the previously installed Python as the build environment
        PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.12.9
        _log_success "Python 3.12.9 installed with pyenv successfully."
    fi
    
    # Set Python 3.12.9 as the global version
    pyenv global 3.12.9
    _log_message "Python 3.12.9 set as the global version."
}

###########################################
# PUBLIC FUNCTIONS (Main installation steps)
###########################################

# Function to install pyenv
install_pyenv() {
    _log_message "Starting pyenv installation..."
    
    if [[ -d "$HOME/.pyenv" ]]; then
        _log_warning "pyenv already installed at $HOME/.pyenv"
    else
        _log_message "Installing pyenv..."
        curl https://pyenv.run | bash
        
        _log_success "pyenv installed successfully."
    fi
    
    # Set up pyenv in shell profile
    local profile=$(_detect_shell_profile)
    _configure_pyenv_profile "$profile"
    
    # Source the profile to make pyenv available in the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    # Install Python 3.12.9 with pyenv
    _log_message "Installing Python 3.12.9 with pyenv..."
    _install_python_with_pyenv
    
    _log_success "pyenv setup completed."
}

# Function to install pipx
install_pipx() {
    _log_message "Starting pipx installation..."
    
    # Check if pipx is already installed
    if _command_exists pipx; then
        _log_warning "pipx already installed"
    else
        # Install pipx using the pyenv Python
        python -m pip install --user pipx
        _log_success "pipx installed successfully."
    fi
    
    # Ensure pipx is in PATH
    python -m pipx ensurepath
    
    # Add pipx to PATH for the current session
    export PATH="$HOME/.local/bin:$PATH"
    
    _log_success "pipx setup completed."
}

# Function to install Flow Coder CLI
install_flow_coder_cli() {
    _log_message "Starting Flow Coder CLI installation..."
    
    # Install Flow Coder CLI using pipx
    pipx install https://storage.googleapis.com/flow-coder/flow_coder-1.4.0-py3-none-any.whl
    
    _log_success "Flow Coder CLI installed successfully."
}

# Function to install Python 3.12.9
install_python() {
    _log_message "Starting Python 3.12.9 installation..."
    _install_python_from_source
    _log_success "Python installation completed."
}

# Main installation process
run_installation() {
    _log_message "Starting Flow Coder CLI installation process..."
    
    # Detect OS
    local os=$(_detect_os)
    _log_message "Detected operating system: $os"
    
    # Detect shell profile
    local profile=$(_detect_shell_profile)
    _log_message "Using shell profile: $profile"
    
    # Install dependencies
    _install_dependencies "$os"
    
    # Install Python 3.12.9 from source
    install_python
    
    # Install pyenv
    install_pyenv
    
    # Install pipx
    install_pipx
    
    # Install Flow Coder CLI
    install_flow_coder_cli
    
    # Final instructions
    _log_message "Installation complete!"
    _log_message "To start using Flow Coder CLI, please restart your terminal or run:"
    _log_message "source $profile"
    
    _log_success "Flow Coder CLI is now installed and ready to use!"
}

###########################################
# SCRIPT EXECUTION
###########################################

# Execute main installation process
run_installation