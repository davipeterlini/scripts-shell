#!/bin/zsh

source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/profile_writer.sh"

_install_oh_my_zsh() {
    # Verificação mais robusta para Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ] && [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        print_success "Oh My Zsh is already installed. Skipping installation."
        return 0
    fi
    
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Verificar se a instalação foi bem-sucedida
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh has been installed successfully."
    else
        print_error "Failed to install Oh My Zsh. Please check your internet connection and try again."
        return 1
    fi
}

_set_zsh_as_default() {
    print_header_info "Setting zsh as default shell..."
    
    # Check if zsh is in the list of allowed shells
    if ! grep -q "$(which zsh)" /etc/shells; then
        print_info "Adding zsh to /etc/shells..."
        echo "$(which zsh)" | sudo tee -a /etc/shells
    fi
    
    # Change the default shell for the current user
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_info "Changing default shell to zsh..."
        #chsh -s "$(which zsh)"
        chsh -s /bin/zsh
    else
        print_success "zsh is already the default shell"
    fi
    
    # Configure iTerm2 to use zsh if it's installed
    if [ -d "/Applications/iTerm.app" ]; then
        print_info "Configuring iTerm2 to use zsh..."
        # Create or update iTerm2 preferences
        defaults write com.googlecode.iterm2 DefaultBookmark -string "zsh"
        defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "zsh"
        
        # Set the default command for new sessions
        /usr/libexec/PlistBuddy -c "Set :New\ Bookmarks:0:Command /bin/zsh" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || true
        
        print_success "iTerm2 configured to use zsh"
    else
        print_alert "iTerm2 not found. Skipping iTerm2 configuration."
    fi
}

_install_plugins() {
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
    local plugins_content="plugins=(zsh-syntax-highlighting zsh-autosuggestions zsh-syntax-highlighting zsh-autosuggestions zsh-syntax-highlighting zsh-autosuggestions zsh-syntax-highlighting zsh-autosuggestions git)"
    if ! grep -q "plugins=(.*zsh-syntax-highlighting.*zsh-autosuggestions.*)" ~/.zshrc; then
        # Backup will be created by profile_writer
        # Usar write_lines_to_profile em vez de write_to_profile para garantir quebras de linha adequadas
        write_lines_to_profile " " "$plugins_content" ~/.zshrc
        # TODO - adicione source $ZSH/oh-my-zsh.sh após o plugin
    fi
    
    print_success "Plugins installed successfully"
}

_add_custom_prompt() {
    print_header_info "Adding custom prompt to .zshrc..."
    
    # Caminho para o arquivo .zshrc.example
    local zshrc_example_path=""
    
    # Verificar se o arquivo .zshrc.example existe em diferentes locais
    if [ -f "$(dirname "$0")/assets/.zshrc.example" ]; then
        zshrc_example_path="$(dirname "$0")/assets/.zshrc.example"
    elif [ -f "assets/.zshrc.example" ]; then
        zshrc_example_path="assets/.zshrc.example"
    elif [ -f "$(dirname "$0")/../assets/.zshrc.example" ]; then
        zshrc_example_path="$(dirname "$0")/../assets/.zshrc.example"
    fi
    
    if [ -n "$zshrc_example_path" ]; then
        print_info "Found .zshrc.example at $zshrc_example_path"
        
        # Verificar se o profile_writer.sh existe
        local profile_writer_path=""
        
        if [ -f "$(dirname "$0")/../../utils/profile_writer.sh" ]; then
            profile_writer_path="$(dirname "$0")/../../utils/profile_writer.sh"
        elif [ -f "utils/profile_writer.sh" ]; then
            profile_writer_path="utils/profile_writer.sh"
        elif [ -f "$(dirname "$0")/../utils/profile_writer.sh" ]; then
            profile_writer_path="$(dirname "$0")/../utils/profile_writer.sh"
        fi
        
        if [ -n "$profile_writer_path" ]; then
            print_info "Found profile_writer.sh at $profile_writer_path"
            
            # Carregar o profile_writer.sh
            source "$profile_writer_path"
            
            # Ler o conteúdo do arquivo .zshrc.example
            local zshrc_content=$(cat "$zshrc_example_path")
            
            # Usar o profile_writer para adicionar o conteúdo ao .zshrc
            write_to_profile "$zshrc_content" "$HOME/.zshrc"
            
            print_success "Custom prompt configuration applied to .zshrc using profile_writer"
        else
            print_error "Could not find profile_writer.sh in any of the expected locations"
            print_info "Falling back to direct file writing method"
        fi
    else
        print_error "Could not find .zshrc.example file in any of the expected locations"
        return 1
    fi
}

_change_theme() {
    print_header_info "Modifying the .zshrc file to use the 'agnoster' theme"
    local theme_content='\nZSH_THEME="agnoster"'
    
    # Backup will be created by profile_writer
    if grep -q 'ZSH_THEME=' ~/.zshrc; then
        # Remove existing theme line and add new one
        remove_script_entries_from_profile "setup_terminal" ~/.zshrc
        write_lines_to_profile "ZSH_THEME=\"agnoster\"" ~/.zshrc
        print_success "Theme changed to 'agnoster'"
    else
        write_lines_to_profile "ZSH_THEME=\"agnoster\"" ~/.zshrc
        print_success "Theme 'agnoster' added to .zshrc"
    fi
}

setup_terminal() {
    print_header_info "Terminal Setup"

    if ! get_user_confirmation "Do you want Setup Terminal ?"; then
        print_info "Skipping configuration"
        return 0
    fi

    # Then proceed with other configurations
    _install_oh_my_zsh
    _set_zsh_as_default
    #_change_theme
    _add_custom_prompt
    _install_plugins
    
    print_header_info "Terminal setup completed. Please restart your terminal."
    print_info "Notes:"
    print_alert " - After installation, you need to manually set the font in your terminal to 'Meslo LG L for Powerline'."
    print_alert " - You may need to restart your terminal for all changes to take effect."
    print_success "Terminal setup completed successfully!"
}

# Run the script only if not being imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_terminal "$@"
fi