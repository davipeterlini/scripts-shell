#!/bin/bash

# Utility functions for terminal setup across platforms
# This script centralizes common terminal setup functionality for Mac and Linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors_message.sh"
source "${SCRIPT_DIR}/bash_tools.sh"
source "${SCRIPT_DIR}/profile_writer.sh"

# Install Oh My Zsh with error checking
install_oh_my_zsh() {
    # More robust verification for Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ] && [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        print_success "Oh My Zsh is already installed. Skipping installation."
        return 0
    fi
    
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Verify successful installation
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh has been installed successfully."
        return 0
    else
        print_error "Failed to install Oh My Zsh. Please check your internet connection and try again."
        return 1
    fi
}

# Set zsh as default shell
set_zsh_as_default() {
    print_header_info "Setting zsh as default shell..."
    
    # Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        print_error "zsh is not installed. Please install zsh first."
        return 1
    }
    
    # Check if zsh is in the list of allowed shells
    if ! grep -q "$(which zsh)" /etc/shells; then
        print_info "Adding zsh to /etc/shells..."
        echo "$(which zsh)" | sudo tee -a /etc/shells
    fi
    
    # Change the default shell for the current user
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    else
        print_success "zsh is already the default shell"
    fi
    
    return 0
}

# Install zsh plugins
install_zsh_plugins() {
    print_header_info "Installing recommended plugins..."
    
    # Define plugin directories - explicitly use HOME
    local syntax_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    local autosuggestions_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    
    # Install zsh-syntax-highlighting if not already installed
    if [ ! -d "$syntax_dir" ]; then
        print_info "Installing zsh-syntax-highlighting to $syntax_dir"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_dir"
    else
        print_info "zsh-syntax-highlighting already installed"
        # Update if it's a git repository
        if [ -d "$syntax_dir/.git" ]; then
            print_info "Updating zsh-syntax-highlighting..."
            (cd "$syntax_dir" && git pull)
        fi
    fi
    
    # Install zsh-autosuggestions if not already installed
    if [ ! -d "$autosuggestions_dir" ]; then
        print_info "Installing zsh-autosuggestions to $autosuggestions_dir"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
    else
        print_info "zsh-autosuggestions already installed"
        # Update if it's a git repository
        if [ -d "$autosuggestions_dir/.git" ]; then
            print_info "Updating zsh-autosuggestions..."
            (cd "$autosuggestions_dir" && git pull)
        fi
    fi
    
    # Update plugins in .zshrc using profile_writer
    local plugins_content="plugins=(git zsh-syntax-highlighting zsh-autosuggestions)"
    if ! grep -q "plugins=(.*zsh-syntax-highlighting.*zsh-autosuggestions.*)" ~/.zshrc; then
        write_lines_to_profile " " "$plugins_content" ~/.zshrc
    fi
    
    print_success "Plugins installed successfully"
    
    return 0
}

# Set zsh theme
set_zsh_theme() {
    local theme="${1:-agnoster}"
    
    print_header_info "Setting zsh theme to '$theme'"
    
    # Update theme in .zshrc using profile_writer
    if grep -q 'ZSH_THEME=' ~/.zshrc; then
        # Remove existing theme line and add new one
        remove_script_entries_from_profile "terminal_utils" ~/.zshrc
        write_lines_to_profile " " "ZSH_THEME=\"$theme\"" ~/.zshrc
    else
        write_lines_to_profile " " "ZSH_THEME=\"$theme\"" ~/.zshrc
    fi
    
    print_success "Theme changed to '$theme'"
    
    return 0
}

# Cross-platform terminal setup
setup_terminal() {
    local platform="$1"  # "mac" or "linux"
    local theme="${2:-agnoster}"
    
    print_header_info "Terminal Setup for ${platform^}"

    if ! get_user_confirmation "Do you want to setup Terminal?"; then
        print_info "Skipping terminal configuration"
        return 0
    fi

    # Install Oh My Zsh
    install_oh_my_zsh || return 1
    
    # Set zsh as default shell
    set_zsh_as_default || return 1
    
    # Install plugins
    install_zsh_plugins || return 1
    
    # Set theme
    set_zsh_theme "$theme" || return 1
    
    # Platform-specific configurations
    if [[ "$platform" == "mac" ]]; then
        configure_iterm2
    elif [[ "$platform" == "linux" ]]; then
        configure_linux_terminal
    fi
    
    print_header_info "Terminal setup completed. Please restart your terminal."
    print_info "Notes:"
    print_alert " - After installation, you need to manually set the font in your terminal to 'Meslo LG L for Powerline'."
    print_alert " - You may need to restart your terminal for all changes to take effect."
    print_success "Terminal setup completed successfully!"
    
    return 0
}

# Platform-specific configurations - to be implemented in respective scripts
configure_iterm2() {
    print_info "No iTerm2 specific configurations needed"
    return 0
}

configure_linux_terminal() {
    print_info "No Linux terminal specific configurations needed"
    return 0
}