#!/bin/zsh

# Load Homebrew installation script
source "$(dirname "$0")/../install_homebrew.sh"

# Function to install iTerm2
install_iterm2() {
    if ! brew list --cask iterm2 >/dev/null 2>&1; then
        echo "Installing iTerm2..."
        brew install --cask iterm2
    else
        echo "iTerm2 is already installed."
    fi
}

# Function to download iTerm2 themes
download_themes() {
    echo "Downloading iTerm2 themes..."
    curl -o ~/Downloads/material-design-colors.itermcolors https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors
    echo "Note: The import of this iTerm2 theme must be done manually."
}

# Function to install Powerline fonts
install_powerline_fonts() {
    echo "Installing Powerline fonts..."
    git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh
    cd .. && rm -rf fonts
    echo "Note: After installation, you need to manually set the font in iTerm2 to 'Meslo LG L for Powerline'."
}

# Main script execution
main() {
    install_homebrew
    install_iterm2
    download_themes
    install_powerline_fonts
    echo "iTerm2 setup completed. Please complete the manual steps as noted."
}

main