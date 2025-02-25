#!/bin/bash

set -e

OS="$(uname -s)"

uninstall_mac() {
    echo "Removendo Python no macOS..."
    if command -v brew &>/dev/null; then
        brew uninstall python
    else
        echo "Homebrew não encontrado. Python deve ser removido manualmente."
    fi
}

uninstall_linux() {
    echo "Removendo Python no Linux..."
    if [ -f /etc/debian_version ]; then
        sudo apt remove --purge -y python3 python3-pip && sudo apt autoremove -y
    elif [ -f /etc/redhat-release ]; then
        sudo yum remove -y python3 python3-pip
    elif [ -f /etc/arch-release ]; then
        sudo pacman -Rns --noconfirm python python-pip
    else
        echo "Distribuição Linux não suportada. Remova o Python manualmente."
        exit 1
    fi
}

uninstall_windows() {
    echo "Removendo Python no Windows..."
    if command -v choco &>/dev/null; then
        choco uninstall -y python
    else
        echo "Chocolatey não encontrado. Remova o Python manualmente pelo Painel de Controle."
    fi
}

case "$OS" in
    Darwin)
        uninstall_mac
        ;;
    Linux)
        uninstall_linux
        ;;
    MINGW*|CYGWIN*|MSYS*)
        uninstall_windows
        ;;
    *)
        echo "Sistema operacional não suportado."
        exit 1
        ;;
esac

echo "Python removido com sucesso!"
