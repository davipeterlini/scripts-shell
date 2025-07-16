#!/bin/bash

set -e

PYTHON_VERSION="3.12.9"
FLOW_CODER_URL="https://storage.googleapis.com/flow-coder/flow_coder-1.4.0-py3-none-any.whl"


# Import color scheme and profile selection script
source ./utils/colors_message.sh
source ./utils/detect_os.sh

install_python_linux() {
    print_info "Installing Python $PYTHON_VERSION on Linux..."
    
    # Check if pyenv is installed
    if ! command -v pyenv &> /dev/null; then
        print_info "Installing pyenv..."
        curl https://pyenv.run | bash
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    fi
    
    # Install Python version
    pyenv install -s $PYTHON_VERSION
    pyenv global $PYTHON_VERSION
}

install_python_macos() {
    print_info "Installing Python $PYTHON_VERSION on macOS..."
    
    # Check if pyenv is installed
    if ! command -v pyenv &> /dev/null; then
        print_info "Installing pyenv..."
        if command -v brew &> /dev/null; then
            brew install pyenv
        else
            curl https://pyenv.run | bash
        fi
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    fi
    
    # Install Python version
    pyenv install -s $PYTHON_VERSION
    pyenv global $PYTHON_VERSION
}

install_python_windows() {
    print_info "Installing Python $PYTHON_VERSION on Windows..."
    
    # Check if pyenv-win is installed
    if ! command -v pyenv &> /dev/null; then
        print_info "Installing pyenv-win..."
        git clone https://github.com/pyenv-win/pyenv-win.git $HOME/.pyenv
        export PATH="$HOME/.pyenv/pyenv-win/bin:$HOME/.pyenv/pyenv-win/shims:$PATH"
    fi
    
    # Install Python version
    pyenv install $PYTHON_VERSION
    pyenv global $PYTHON_VERSION
}

install_flow_coder() {
    print_info "Installing Flow Coder..."
    
    # Ensure we're using the correct Python version
    python_path=$(which python)
    python_version=$(python --version 2>&1 | cut -d' ' -f2)
    
    print_info "Using Python: $python_path"
    print_info "Python version: $python_version"
    
    # Install Flow Coder
    pip install --upgrade pip
    pip install "$FLOW_CODER_URL"
    
    print_success "Flow Coder installed successfully!"
}

install_flow_coder_cli() {
    print_header_info "Starting Flow Coder installation..."

    if ! get_user_confirmation "Do you want Setting up global environment ?"; then
        print_info "Skipping configuration"
        return 0
    fi
    
    detect_os
    print_info "Detected OS: $os"
    
    case $os in
        "linux")
            install_python_linux
            ;;
        "macOS")
            install_python_macos
            ;;
        "windows")
            install_python_windows
            ;;
        *)
            print_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
    
    # Reload shell environment
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        source "$HOME/.zshrc"
    fi
    
    install_flow_coder
    
    print_success "Installation completed successfully!"
    print_info "You can now use Flow Coder by running: flow_coder"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_flow_coder_cli "$@"
fi