#!/bin/bash

check_flameshot_installed() {
    if ! command -v flameshot &> /dev/null; then
        echo "Flameshot não está instalado. Instalando Flameshot..."
        brew install flameshot
    else
        echo "Flameshot já está instalado."
    fi
}

configure_path() {
    HOMEBREW_PATH="/usr/local/bin"
    
    if [[ ":$PATH:" != *":$HOMEBREW_PATH:"* ]]; then
        echo "Adicionando Homebrew ao PATH..."
        export PATH="$HOMEBREW_PATH:$PATH"
        
        SHELL_PROFILE="$HOME/.zshrc"
        if [[ $SHELL == *"bash"* ]]; then
            SHELL_PROFILE="$HOME/.bash_profile"
        fi

        echo "export PATH=\"$HOMEBREW_PATH:\$PATH\"" >> "$SHELL_PROFILE"
        echo "Homebrew adicionado ao PATH no perfil de shell ($SHELL_PROFILE)."
    else
        echo "Homebrew já está no PATH."
    fi
}

configure_flameshot_shortcuts() {
    CONFIG_DIR="$HOME/.config/flameshot"
    CONFIG_FILE="$CONFIG_DIR/flameshot.ini"

    mkdir -p "$CONFIG_DIR"

    if grep -q "\[Shortcuts\]" "$CONFIG_FILE"; then
        echo "Seção [Shortcuts] já existe. Atualizando configuração..."
    else
        echo -e "\n[Shortcuts]" >> "$CONFIG_FILE"
    fi

    if grep -q "TAKE_SCREENSHOT=" "$CONFIG_FILE"; then
        sed -i '' 's/TAKE_SCREENSHOT=.*/TAKE_SCREENSHOT=Shift+P/' "$CONFIG_FILE"
    else
        echo "TAKE_SCREENSHOT=Shift+P" >> "$CONFIG_FILE"
    fi

    echo "Configurações de atalhos de teclado aplicadas em $CONFIG_FILE."
}

restart_flameshot() {
    pkill flameshot
    # TODO - not working
    flameshot &
    echo "Flameshot restart with new configs"
}
configure_path
check_flameshot_installed
configure_flameshot_shortcuts
restart_flameshot
