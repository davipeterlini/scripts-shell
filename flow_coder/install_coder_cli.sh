#!/bin/bash

# Flow Coder CLI Installation Script
# This script installs Python 3.12.9, pyenv, pipx, and Flow Coder CLI
# Compatible with Linux and macOS

set -e  # Exit immediately if a command exits with a non-zero status

###########################################
# IMPORT UTILITY SCRIPTS
###########################################

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility scripts
source "$PROJECT_ROOT/utils/colors_message.sh"
source "$PROJECT_ROOT/utils/detect_os.sh"

###########################################
# PRIVATE FUNCTIONS (Internal use only)
###########################################

# Function to ask user for confirmation
_ask_confirmation() {
    local message=$1
    local default=${2:-Y}
    
    if [[ "$default" == "Y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    print_yellow "[QUESTION] $message $prompt"
    read -r response
    
    # Default response if user just presses Enter
    if [[ -z "$response" ]]; then
        response=$default
    fi
    
    # Convert to lowercase
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$response" == "y" || "$response" == "yes" ]]; then
        return 0  # True in bash
    else
        return 1  # False in bash
    fi
}

# Function to check if a command exists
_command_exists() {
    command -v "$1" >/dev/null 2>&1
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
    print_info "Installing dependencies for $os..."
    
    if [[ "$os" == "Linux" ]]; then
        # Linux dependencies
        sudo apt-get update -y || sudo yum update -y || sudo dnf update -y
        sudo apt-get install -y curl wget git build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
            xz-utils tk-dev libffi-dev liblzma-dev python-openssl || \
        sudo yum install -y curl wget git gcc zlib-devel bzip2 bzip2-devel readline-devel \
            sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel || \
        sudo dnf install -y curl wget git gcc zlib-devel bzip2 bzip2-devel readline-devel \
            sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
    elif [[ "$os" == "macOS" ]]; then
        # macOS dependencies
        if ! _command_exists xcode-select; then
            print_info "Installing command line tools..."
            xcode-select --install || true
        fi
        
        # Check if we need to install additional dependencies
        if ! _command_exists make || ! _command_exists gcc; then
            print_alert "Some development tools might be missing. If installation fails, please install Xcode Command Line Tools."
        fi
    fi
    
    print_success "Dependencies installed successfully."
}

# Function to install Python 3.12.9 from source
_install_python_from_source() {
    local install_dir="$HOME/.local/python3.12.9"
    
    if [[ -d "$install_dir" ]]; then
        print_alert "Python 3.12.9 already installed at $install_dir"
        return 0
    fi
    
    print_info "Installing Python 3.12.9 from source..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download Python source
    print_info "Downloading Python 3.12.9 source..."
    wget https://www.python.org/ftp/python/3.12.9/Python-3.12.9.tgz
    
    # Extract source
    tar -xzf Python-3.12.9.tgz
    cd Python-3.12.9
    
    # Configure and install Python
    print_info "Configuring Python 3.12.9..."
    ./configure --prefix="$install_dir" --enable-optimizations
    
    print_info "Building Python 3.12.9 (this may take a while)..."
    make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)
    
    print_info "Installing Python 3.12.9..."
    make install
    
    # Clean up
    cd "$HOME"
    rm -rf "$temp_dir"
    
    print_success "Python 3.12.9 installed successfully at $install_dir"
}

# Function to configure pyenv in shell profile
_configure_pyenv_profile() {
    local profile=$1
    
    # Check if pyenv is already in the profile
    if ! grep -q "pyenv init" "$profile"; then
        print_info "Adding pyenv to $profile..."
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
        print_alert "Python 3.12.9 already installed with pyenv"
    else
        # Use the previously installed Python as the build environment
        PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.12.9
        print_success "Python 3.12.9 installed with pyenv successfully."
    fi
    
    # Set Python 3.12.9 as the global version
    pyenv global 3.12.9
    print_info "Python 3.12.9 set as the global version."
}

###########################################
# PUBLIC FUNCTIONS (Main installation steps)
###########################################

# Function to install dependencies
install_dependencies() {
    if _ask_confirmation "Do you want to install required dependencies?"; then
        # Use the OS_NAME from detect_os.sh
        _install_dependencies "$OS_NAME"
        print_success "Dependencies installation completed."
    else
        print_alert "Skipping dependencies installation. This might cause issues later."
    fi
}

# Function to install Python 3.12.9
install_python() {
    if _ask_confirmation "Do you want to install Python 3.12.9 from source?"; then
        print_header_info "Starting Python 3.12.9 installation..."
        _install_python_from_source
        print_success "Python installation completed."
    else
        print_alert "Skipping Python installation. This might cause issues with pyenv setup."
    fi
}

# Function to install pyenv
install_pyenv() {
    if _ask_confirmation "Do you want to install pyenv?"; then
        print_header_info "Starting pyenv installation..."
        
        if [[ -d "$HOME/.pyenv" ]]; then
            print_alert "pyenv already installed at $HOME/.pyenv"
        else
            print_info "Installing pyenv..."
            curl https://pyenv.run | bash
            
            print_success "pyenv installed successfully."
        fi
        
        # Set up pyenv in shell profile
        local profile=$(_detect_shell_profile)
        
        if _ask_confirmation "Do you want to configure pyenv in your shell profile ($profile)?"; then
            _configure_pyenv_profile "$profile"
        else
            print_alert "Skipping pyenv configuration in shell profile. You'll need to configure it manually."
        fi
        
        # Source the profile to make pyenv available in the current session
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        
        # Install Python 3.12.9 with pyenv
        if _ask_confirmation "Do you want to install Python 3.12.9 with pyenv?"; then
            print_info "Installing Python 3.12.9 with pyenv..."
            _install_python_with_pyenv
        else
            print_alert "Skipping Python 3.12.9 installation with pyenv. This might cause issues later."
        fi
        
        print_success "pyenv setup completed."
    else
        print_alert "Skipping pyenv installation. This might cause issues with pipx setup."
    fi
}

# Function to install pipx
install_pipx() {
    if _ask_confirmation "Do you want to install pipx?"; then
        print_header_info "Starting pipx installation..."
        
        # Check if pipx is already installed
        if _command_exists pipx; then
            print_alert "pipx already installed"
        else
            # Install pipx using the pyenv Python
            python -m pip install --user pipx
            print_success "pipx installed successfully."
        fi
        
        # Ensure pipx is in PATH
        if _ask_confirmation "Do you want to add pipx to your PATH?"; then
            python -m pipx ensurepath
            
            # Add pipx to PATH for the current session
            export PATH="$HOME/.local/bin:$PATH"
            print_success "pipx added to PATH."
        else
            print_alert "Skipping pipx PATH configuration. You'll need to add it manually."
        fi
        
        print_success "pipx setup completed."
    else
        print_alert "Skipping pipx installation. This will prevent Flow Coder CLI installation."
    fi
}

# Function to install Flow Coder CLI
install_flow_coder_cli() {
    if _ask_confirmation "Do you want to install Flow Coder CLI?"; then
        print_header_info "Starting Flow Coder CLI installation..."
        
        # Install Flow Coder CLI using pipx
        pipx install https://storage.googleapis.com/flow-coder/flow_coder-1.4.0-py3-none-any.whl
        
        print_success "Flow Coder CLI installed successfully."
    else
        print_alert "Skipping Flow Coder CLI installation."
    fi
}

# Function to reload shell profile
reload_shell_profile() {
    local profile=$(_detect_shell_profile)
    
    if _ask_confirmation "Do you want to reload your shell profile ($profile)?"; then
        print_info "Reloading shell profile: $profile"
        # shellcheck disable=SC1090
        source "$profile"
        print_success "Shell profile reloaded."
    else
        print_alert "Skipping shell profile reload. You'll need to reload it manually with: source $profile"
    fi
}

# Main installation process
run_installation() {
    print_header "Starting Flow Coder CLI installation process..."
    
    # Detect OS using the imported detect_os function
    detect_os
    
    # Detect shell profile
    local profile=$(_detect_shell_profile)
    print_info "Using shell profile: $profile"
    
    # Install dependencies
    install_dependencies
    
    # Install Python 3.12.9 from source
    install_python
    
    # Install pyenv
    install_pyenv
    
    # Install pipx
    install_pipx
    
    # Install Flow Coder CLI
    install_flow_coder_cli
    
    # Reload shell profile
    reload_shell_profile
    
    # Final instructions
    print_header "Installation process completed!"
    print_info "To start using Flow Coder CLI, please restart your terminal or run:"
    print "source $profile"
    
    print_success "Flow Coder CLI is now installed and ready to use!"
}

###########################################
# SCRIPT EXECUTION
###########################################

# Execute main installation process
if _ask_confirmation "Do you want to start the Flow Coder CLI installation process?"; then
    run_installation
else
    print_info "Installation aborted by user."
    exit 0
fi