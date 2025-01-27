#!/bin/bash

# Function to load environment variables from .env file
load_env() {
    if [ -f .env ]; then
        export $(grep -v '^#' .env | xargs)
    else
        echo ".env file not found. Exiting..."
        exit 1
    fi
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Oh My Zsh is already installed."
    fi
}

# Function to install Powerlevel10k theme
install_powerlevel10k() {
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        echo "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
        sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' $HOME/.zshrc
    else
        echo "Powerlevel10k theme is already installed."
    fi
}

# Function to install plugins
install_plugins() {
    local plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")
    for plugin in "${plugins[@]}"; do
        if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$plugin" ]; then
            echo "Installing $plugin..."
            git clone https://github.com/zsh-users/$plugin $HOME/.oh-my-zsh/custom/plugins/$plugin
        else
            echo "$plugin is already installed."
        fi
    done

    sed -i 's|plugins=(.*)|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|' $HOME/.zshrc
}

main() {
    # Load environment variables
    load_env

    # Install Oh My Zsh
    install_oh_my_zsh

    # Install Powerlevel10k theme
    install_powerlevel10k

    # Install plugins
    install_plugins

    echo "Terminal setup complete. Please restart your terminal."
}

main