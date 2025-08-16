#!/bin/bash

# Script to set up the terminal environment for Linux
# Using shared terminal utilities

# Get absolute directory of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source required utilities
source "${PROJECT_ROOT}/utils/colors_message.sh"
source "${PROJECT_ROOT}/utils/bash_tools.sh"
source "${PROJECT_ROOT}/utils/terminal_utils.sh"

# Linux-specific terminal setup function
configure_linux_terminal() {
    print_info "Setting up Linux terminal specifics..."
    
    # Ensure required packages are installed
    if command -v apt-get &> /dev/null; then
        print_info "Updating package list and installing necessary packages..."
        sudo apt-get update
        sudo apt-get install -y zsh curl git
    elif command -v yum &> /dev/null; then
        print_info "Updating package list and installing necessary packages..."
        sudo yum update -y
        sudo yum install -y zsh curl git
    elif command -v dnf &> /dev/null; then
        print_info "Updating package list and installing necessary packages..."
        sudo dnf update -y
        sudo dnf install -y zsh curl git
    else
        print_error "Unsupported package manager. Please install zsh, curl, and git manually."
    fi
    
    # Install Powerlevel10k theme for Zsh if requested
    if get_user_confirmation "Do you want to install Powerlevel10k theme for Zsh?"; then
        print_info "Installing Powerlevel10k theme for Zsh..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
        print_success "Powerlevel10k theme installed"
    fi
    
    print_success "Linux terminal setup completed"
    return 0
}

# Linux-specific setup_terminal wrapper
setup_terminal_linux() {
    # Call the shared setup_terminal function with 'linux' platform
    setup_terminal "linux" "robbyrussell" # Default Linux theme
    
    return 0
}

# Run the script only if not being imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_terminal_linux "$@"
fi