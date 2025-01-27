#!/bin/bash

# Function to install iTerm2
install_iterm2() {
    echo "Installing iTerm2..."
    brew install --cask iterm2
}

# Function to configure iTerm2 preferences
configure_iterm2() {
    echo "Configuring iTerm2 preferences..."
    # Example: Set preferences directory
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.iterm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
}

# Main script execution
main() {
    install_iterm2
    configure_iterm2
    echo "iTerm2 setup completed."
}

main