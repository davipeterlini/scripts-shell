#!/bin/zsh

source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

# Function to install iTerm2
install_iterm2() {
    if ! brew list --cask iterm2 >/dev/null 2>&1; then
        print_info "Installing iTerm2..."
        brew install --cask --force iterm2
        print_success "iTerm2 has been installed successfully."
    else
        print_info "Updating iTerm2..."
        brew upgrade --cask --force iterm2
        print_info "iTerm2 is already installed."
    fi
}

download_and_import_themes() {
    print_header_info "Downloading iTerm2 themes..."
    local theme_path=~/Downloads/material-design-colors.itermcolors
    curl -o "$theme_path" https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors
    
    print_info "Importing iTerm2 theme automatically..."
    # Check if iTerm2 is running
    if ! pgrep -q "iTerm"; then
        print_info "Starting iTerm2 to import theme..."
        open -a iTerm
        sleep 2
    fi
    
    # Import the color preset
    defaults write com.googlecode.iterm2 "Custom Color Presets" -dict-add "Material Design Colors" "$(cat "$theme_path")"
    
    # Set the theme as default for new windows
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "Material Design Colors"

    cleanup_temp_files "$theme_path"
    
    print_success "iTerm2 theme has been imported automatically."
}

install_powerline_fonts() {
    print_header_info "Installing Powerline fonts..."
    git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh
    cd .. && rm -rf fonts
    
    print_info "Setting Meslo LG L for Powerline as default font..."
    defaults write com.googlecode.iterm2 "Normal Font" -string "MesloLGLForPowerline-Regular 12"
    print_success "Font settings updated. You may need to restart iTerm2 for changes to take effect."
}

# TODO - ao fechar e abrir nao esta voltado no que estava aberto 
# TODO - ao abrir nova aba naao esta abrindo o ultimo path corrente
# Function to configure iTerm2 session persistence and working directory
configure_iterm_session_persistence() {
    print_header_info "Configuring iTerm2 to restore sessions and use current directory for new tabs..."
    
    # Configure iTerm2 to restore sessions on startup
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.iterm2"
    
    # Create directory for iTerm2 preferences if it doesn't exist
    mkdir -p ~/.iterm2
    
    # Configure iTerm2 to always restore previous sessions
    defaults write com.googlecode.iterm2 QuitWhenAllWindowsClosed -bool false
    defaults write com.googlecode.iterm2 OnlyWhenMoreTabs -bool false
    defaults write com.googlecode.iterm2 PromptOnQuit -bool false
    
    # Configure new tabs to open in the same directory
    defaults write com.googlecode.iterm2 OpenArrangementAtStartup -bool true
    defaults write com.googlecode.iterm2 OpenNoWindowsAtStartup -bool false
    defaults write com.googlecode.iterm2 AlwaysOpenWindowAtStartup -bool true
    
    # Configure reuse of previous directory
    defaults write com.googlecode.iterm2 "UseWorkingDirectory" -bool true
    defaults write com.googlecode.iterm2 "ReuseWindowsWhenPossible" -bool true
    
    # Configure working directory for new tabs
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Custom Directory\" Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Working Directory\" Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist
    
    print_success "iTerm2 session persistence and working directory settings configured."
}

# Main script execution
setup_iterm() {
    print_header_info "Setting up iTerm2"

    if ! get_user_confirmation "Do you want Setup Iterm2 ?"; then
        print_info "Skipping configuration"
        return 0
    fi

    install_homebrew
    install_iterm2
    download_and_import_themes
    install_powerline_fonts
    configure_iterm_session_persistence
    
    # Restart iTerm2 to apply all changes
    print_info "Restarting iTerm2 to apply all changes..."
    pkill iTerm || true
    sleep 1
    # TODO - verificar se esse realmente é o nome da aplicação
    open -a iTerm
    
    print_success "iTerm2 setup completed with automatic theme, font, and session persistence configuration."
}

# Executar o script apenas se não estiver sendo importado
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_iterm "$@"
fi