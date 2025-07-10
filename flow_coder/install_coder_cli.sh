#!/bin/bash

# Flow Coder CLI Installation Script
# This script installs Python 3.12.9, pyenv, pipx, and Flow Coder CLI
# Compatible with Linux and macOS

set -e  # Exit immediately if a command exits with a non-zero status

# Color codes for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display messages
log_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Function to detect shell profile
detect_shell_profile() {
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
install_dependencies() {
    local os=$1
    log_message "Installing dependencies for $os..."
    
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
        if ! command_exists xcode-select; then
            log_message "Installing command line tools..."
            xcode-select --install || true
        fi
        
        # Check if we need to install additional dependencies
        if ! command_exists make || ! command_exists gcc; then
            log_warning "Some development tools might be missing. If installation fails, please install Xcode Command Line Tools."
        fi
    fi
    
    log_success "Dependencies installed successfully."
}

# Function to install Python 3.12.9 from source
install_python() {
    local install_dir="$HOME/.local/python3.12.9"
    
    if [[ -d "$install_dir" ]]; then
        log_warning "Python 3.12.9 already installed at $install_dir"
        return 0
    fi
    
    log_message "Installing Python 3.12.9 from source..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download Python source
    log_message "Downloading Python 3.12.9 source..."
    wget https://www.python.org/ftp/python/3.12.9/Python-3.12.9.tgz
    
    # Extract source
    tar -xzf Python-3.12.9.tgz
    cd Python-3.12.9
    
    # Configure and install Python
    log_message "Configuring Python 3.12.9..."
    ./configure --prefix="$install_dir" --enable-optimizations
    
    log_message "Building Python 3.12.9 (this may take a while)..."
    make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)
    
    log_message "Installing Python 3.12.9..."
    make install
    
    # Clean up
    cd "$HOME"
    rm -rf "$temp_dir"
    
    log_success "Python 3.12.9 installed successfully at $install_dir"
}

# Function to install pyenv
install_pyenv() {
    if [[ -d "$HOME/.pyenv" ]]; then
        log_warning "pyenv already installed at $HOME/.pyenv"
    else
        log_message "Installing pyenv..."
        curl https://pyenv.run | bash
        
        log_success "pyenv installed successfully."
    fi
    
    # Set up pyenv in shell profile
    local profile=$(detect_shell_profile)
    
    # Check if pyenv is already in the profile
    if ! grep -q "pyenv init" "$profile"; then
        log_message "Adding pyenv to $profile..."
        cat >> "$profile" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF
    fi
    
    # Source the profile to make pyenv available in the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    # Install Python 3.12.9 with pyenv
    log_message "Installing Python 3.12.9 with pyenv..."
    
    # Check if Python 3.12.9 is already installed with pyenv
    if pyenv versions | grep -q "3.12.9"; then
        log_warning "Python 3.12.9 already installed with pyenv"
    else
        # Use the previously installed Python as the build environment
        PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.12.9
        log_success "Python 3.12.9 installed with pyenv successfully."
    fi
    
    # Set Python 3.12.9 as the global version
    pyenv global 3.12.9
    log_message "Python 3.12.9 set as the global version."
}

# Function to install pipx
install_pipx() {
    log_message "Installing pipx..."
    
    # Check if pipx is already installed
    if command_exists pipx; then
        log_warning "pipx already installed"
    else
        # Install pipx using the pyenv Python
        python -m pip install --user pipx
        log_success "pipx installed successfully."
    fi
    
    # Ensure pipx is in PATH
    python -m pipx ensurepath
    
    # Add pipx to PATH for the current session
    export PATH="$HOME/.local/bin:$PATH"
}

# Function to install Flow Coder CLI
install_flow_coder_cli() {
    log_message "Installing Flow Coder CLI..."
    
    # Install Flow Coder CLI using pipx
    pipx install https://storage.googleapis.com/flow-coder/flow_coder-1.4.0-py3-none-any.whl
    
    log_success "Flow Coder CLI installed successfully."
}

# Main function
main() {
    log_message "Starting Flow Coder CLI installation..."
    
    # Detect OS
    local os=$(detect_os)
    log_message "Detected operating system: $os"
    
    # Detect shell profile
    local profile=$(detect_shell_profile)
    log_message "Using shell profile: $profile"
    
    # Install dependencies
    install_dependencies "$os"
    
    # Install Python 3.12.9 from source
    install_python
    
    # Install pyenv
    install_pyenv
    
    # Install pipx
    install_pipx
    
    # Install Flow Coder CLI
    install_flow_coder_cli
    
    # Final instructions
    log_message "Installation complete!"
    log_message "To start using Flow Coder CLI, please restart your terminal or run:"
    log_message "source $profile"
    
    log_success "Flow Coder CLI is now installed and ready to use!"
}

# Execute main function
main