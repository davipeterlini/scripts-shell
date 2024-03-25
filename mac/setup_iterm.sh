#!/bin/zsh

# Check if Homebrew is installed, install if not
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Homebrew is already installed."
fi

# TODO - Check if iTerm2 is installed, install if not
#brew install --cask iterm2

# Config Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    echo "Oh My Zsh aready install"
fi

# Create a New Profile and set default
# TODO - the line below is not work beacause this command not suported in iTerm2
#osascript iterm/create_profile.scpt
echo "Note: Create profile and set as default of this iTerm2 must be done manually."

# Download Themas
curl -o ~/Downloads/material-design-colors.itermcolors https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors
#curl -o ~/Downloads/solarized.itermcolors https://raw.githubusercontent.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Dark.itermcolors
echo "Note: The import of this iTerm2 theme must be done manually."

# Clona e instala as fontes Powerline
git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh
echo "Note: After installation, you need to manually set the font in iTerm2 to 'Meslo LG L for Powerline'."

# Modifica o arquivo .zshrc para usar o tema 'agnoster'
sed -i '' 's/ZSH_THEME="robbyrussell"/# ZSH_THEME="robbyrussell"\nZSH_THEME="agnoster"/' ~/.zshrc