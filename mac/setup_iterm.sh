#!/bin/zsh

# TODO - tratar erros do Iterm quando o mesmo estiver instalado

# Check if Homebrew is installed, install if not
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Homebrew is already installed."
fi

# TODO - Check if iTerm2 is installed, install if not
brew install --cask iterm2

# Create a New Profile and set default
# TODO - the line below is not work beacause this command not suported in iTerm2
#osascript iterm/create_profile.scpt
echo "Note: Create profile and set as default of this iTerm2 must be done manually."

# Download Themes
curl -o ~/Downloads/material-design-colors.itermcolors https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors
#curl -o ~/Downloads/solarized.itermcolors https://raw.githubusercontent.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Dark.itermcolors
echo "Note: The import of this iTerm2 theme must be done manually."

# Clone and install Powerline fonts
git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh
echo "Note: After installation, you need to manually set the font in iTerm2 to 'Meslo LG L for Powerline'."