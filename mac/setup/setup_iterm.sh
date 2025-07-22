#!/bin/zsh

source "$(dirname "$0")/mac/install_homebrew.sh"
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/profile_writer.sh"

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
    print_info "Downloading iTerm2 themes..."
    local theme_path=~/Downloads/material-design-colors.itermcolors
    
    # Backup iTerm2 preferences before making changes
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    _backup_profile_file ~/Library/Preferences/com.googlecode.iterm2.plist "$timestamp"
    
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
    print_info "Installing Powerline fonts..."
    git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh
    cd .. && rm -rf fonts
    
    # Backup iTerm2 preferences before making changes
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    _backup_profile_file ~/Library/Preferences/com.googlecode.iterm2.plist "$timestamp"
    
    print_info "Setting Meslo LG L for Powerline as default font..."
    defaults write com.googlecode.iterm2 "Normal Font" -string "MesloLGLForPowerline-Regular 12"
    print_success "Font settings updated. You may need to restart iTerm2 for changes to take effect."
}

configure_iterm_session_persistence() {
    print_info "Configuring iTerm2 to restore sessions and tabs from previous sessions..."
    
    # Backup iTerm2 preferences before making changes
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    _backup_profile_file ~/Library/Preferences/com.googlecode.iterm2.plist "$timestamp"
    
    # Create directory for iTerm2 preferences if it doesn't exist
    mkdir -p ~/.iterm2
    
    # Configure iTerm2 to save and restore window arrangements
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.iterm2"
    defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true
    defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 0
    
    # Configure iTerm2 to always restore previous sessions
    defaults write com.googlecode.iterm2 QuitWhenAllWindowsClosed -bool false
    defaults write com.googlecode.iterm2 OnlyWhenMoreTabs -bool false
    defaults write com.googlecode.iterm2 PromptOnQuit -bool false
    
    # Enable session restoration
    defaults write com.googlecode.iterm2 OpenArrangementAtStartup -bool true
    defaults write com.googlecode.iterm2 OpenNoWindowsAtStartup -bool false
    defaults write com.googlecode.iterm2 AlwaysOpenWindowAtStartup -bool true
    defaults write com.googlecode.iterm2 RestoreWindowContents -bool true
    
    # Enable automatic saving of window arrangement when iTerm2 quits
    defaults write com.googlecode.iterm2 NoSyncPermissionToShowTip -bool false
    defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool true
    defaults write com.googlecode.iterm2 SavePasteHistory -bool true
    defaults write com.googlecode.iterm2 AutoSaveJobName -string "Default"
    defaults write com.googlecode.iterm2 NSNavLastRootDirectory -string "~/.iterm2"
    defaults write com.googlecode.iterm2 "NoSyncDoNotWarnBeforeMultilinePaste" -bool true
    defaults write com.googlecode.iterm2 "NoSyncDoNotWarnBeforeMultilinePaste_selection" -int 0
    
    # Configure reuse of previous directory
    defaults write com.googlecode.iterm2 "UseWorkingDirectory" -bool true
    defaults write com.googlecode.iterm2 "ReuseWindowsWhenPossible" -bool true
    
    # Configure working directory for new tabs
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Custom Directory\" Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Working Directory\" Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || true
    
    # Enable session restoration
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Automatically Log\" true" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || true
    
    # Save window arrangement on quit
    defaults write com.googlecode.iterm2 PerformDNSLookups -bool true
    defaults write com.googlecode.iterm2 SaveWindowArrangementToFile -bool true
    defaults write com.googlecode.iterm2 WindowArrangementFile -string "~/.iterm2/arrangement.itermkeymap"
    defaults write com.googlecode.iterm2 WindowArrangements -dict-add "Default" "<dict><key>Tabs</key><array></array></dict>"
    
    print_success "iTerm2 session persistence and tab restoration configured."
}

# Add iTerm2 specific settings to shell profile if needed
configure_iterm_shell_integration() {
    print_info "Configuring iTerm2 shell integration..."
    
    # Check if shell integration is already installed
    if ! grep -q "iterm2_shell_integration" ~/.zshrc; then
        # Add iTerm2 shell integration to profile using write_lines_to_profile instead
        write_lines_to_profile " " \
                              "if [ -e \"${HOME}/.iterm2_shell_integration.zsh\" ]; then" \
                              "  source \"${HOME}/.iterm2_shell_integration.zsh\"" \
                              "fi" \
                              ~/.zshrc
        
        # Download iTerm2 shell integration script if not present
        if [ ! -f "${HOME}/.iterm2_shell_integration.zsh" ]; then
            print_info "Downloading iTerm2 shell integration script..."
            curl -L https://iterm2.com/shell_integration/zsh -o "${HOME}/.iterm2_shell_integration.zsh"
        fi
        
        print_success "iTerm2 shell integration configured"
    else
        print_info "iTerm2 shell integration already configured"
    fi
}

# Configure iTerm2 to automatically save and restore window arrangements
configure_iterm_window_restoration() {
    print_info "Configuring iTerm2 to automatically save and restore window arrangements..."
    
    # Backup iTerm2 preferences before making changes
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    _backup_profile_file ~/Library/Preferences/com.googlecode.iterm2.plist "$timestamp"
    
    # Create default arrangement directory
    mkdir -p ~/.iterm2/Arrangements
    
    # Enable automatic saving of window arrangement
    defaults write com.googlecode.iterm2 "NoSyncHaveWarnedAboutPasteConfirmationChange" -bool true
    defaults write com.googlecode.iterm2 "NoSyncHaveWarnedAboutIncompatibleSoftware" -bool true
    defaults write com.googlecode.iterm2 "NoSyncTipsDisabled" -bool true
    
    # Enable automatic window restoration
    defaults write com.googlecode.iterm2 "kOpenArrangementAtStartupKey" -bool true
    defaults write com.googlecode.iterm2 "kOpenNoWindowsAtStartup" -bool false
    
    # Set arrangement to save automatically when iTerm2 quits
    defaults write com.googlecode.iterm2 "NoSyncSaveWindowArrangementAutomatically" -bool true
    defaults write com.googlecode.iterm2 "NoSyncRestoreWindowArrangementAutomatically" -bool true
    defaults write com.googlecode.iterm2 "NoSyncWindowRestoration" -string "yes"
    
    print_success "iTerm2 window arrangement restoration configured."
}

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
    configure_iterm_shell_integration
    configure_iterm_window_restoration
    
    # Restart iTerm2 to apply all changes
    print_info "Restarting iTerm2 to apply all changes..."
    pkill iTerm || true
    sleep 1
    open -a iTerm
    
    print_success "iTerm2 setup completed with automatic theme, font, and session restoration configuration."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_iterm "$@"
fi