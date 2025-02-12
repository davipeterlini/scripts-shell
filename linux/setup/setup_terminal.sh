#!/bin/bash

# Function to install and configure terminal on Debian-based Linux
setup_terminal_linux() {
    echo "Setting up terminal on Debian-based Linux..."

    # Update package list and install necessary packages
    sudo apt update
    sudo apt install -y zsh curl git

    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Set Zsh as the default shell
    chsh -s $(which zsh)

    # Install Powerlevel10k theme for Zsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

    # Install Zsh plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

    # Apply changes
    source ~/.zshrc

    echo "Terminal setup complete. Please restart your terminal."
}

# Execute the setup function
setup_terminal_linux