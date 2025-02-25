#!/bin/bash

set -e

OS="$(uname -s)"

install_mac() {
    echo "Instalando Python no macOS..."
    if ! command -v brew &>/dev/null; then
        echo "Homebrew não encontrado. Instalando..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install python
}

install_linux() {
    echo "Instalando Python no Linux..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y python3 python3-pip
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y python3 python3-pip
    elif [ -f /etc/arch-release ]; then
        sudo pacman -Sy --noconfirm python python-pip
    else
        echo "Distribuição Linux não suportada. Instale o Python manualmente."
        exit 1
    fi
}

install_windows() {
    echo "Instalando Python no Windows..."
    if ! command -v choco &>/dev/null; then
        echo "Chocolatey não encontrado. Instalando..."
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        exec bash "$0"  # Reexecuta o script após instalar o Chocolatey
    fi
    choco install -y python
}

case "$OS" in
    Darwin)
        install_mac
        ;;
    Linux)
        install_linux
        ;;
    MINGW*|CYGWIN*|MSYS*)
        install_windows
        ;;
    *)
        echo "Sistema operacional não suportado."
        exit 1
        ;;
esac

echo "Python instalado com sucesso!"
python3 --version
