#!/bin/bash

<<<<<<< HEAD
# Ensure Python is installed and PATH is configured
source "$(dirname "$0")/install_python.sh"
install_python

# Load environment variables
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Function to get the latest version of coder
get_latest_coder_url() {
    echo "Fetching the latest version of coder..."
    latest_info=$(curl -s https://storage.googleapis.com/flow-coder/update_info.json)
    coder_url=$(echo $latest_info | python3 -c "import sys, json; print(json.load(sys.stdin)['url'])")
    echo "Latest coder URL: $coder_url"
}

# Function to install coder
install_coder() {
    echo "Installing coder..."
    coder_env_dir="$HOME/coder_env"
    python3 -m venv $coder_env_dir
    source $coder_env_dir/bin/activate
    pip install --upgrade pip
    get_latest_coder_url
    pip install $coder_url
    deactivate
    echo "Coder installed successfully."
}

# Function to configure PATH
configure_path() {
    echo "Configuring PATH..."
    SHELL_CONFIG_FILE="$HOME/.zshrc"
    PATH_ENTRY='export PATH=$PATH:$HOME/coder_env/bin'

    if ! grep -Fxq "$PATH_ENTRY" $SHELL_CONFIG_FILE; then
        echo '' >> $SHELL_CONFIG_FILE
        echo $PATH_ENTRY >> $SHELL_CONFIG_FILE
        source $SHELL_CONFIG_FILE
        echo "PATH configured successfully in $SHELL_CONFIG_FILE."
    else
        echo "PATH entry already exists in $SHELL_CONFIG_FILE."
    fi
}

# Main script execution
install_coder
configure_path

echo "Coder installation completed. Please restart your terminal or run 'source ~/.zshrc' to apply PATH changes."
=======
set -e

# Constantes
PYTHON_URL="https://www.python.org/"
CODER_URL="https://storage.googleapis.com/flow-coder/coder-0.86-py3-none-any.whl"
CODER_FILE="coder-latest.whl"

# Função para verificar a instalação do Python
check_python() {
    echo "Verificando instalação do Python..."
    if command -v python3 &>/dev/null; then
        echo "Python encontrado: $(python3 --version)"
        return 0
    fi
    echo "Python não encontrado."
    return 1
}

# Função para instalar o Python
install_python() {
    if check_python; then
        return
    fi
    echo "Instalando Python..."
    local os_name="$(uname -s)"
    case "$os_name" in
        Darwin)
            echo "Instalando Python no macOS..."
            command -v brew &>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install python
            ;;
        Linux)
            echo "Instalando Python no Linux..."
            if [ -f /etc/debian_version ]; then
                sudo apt update && sudo apt install -y python3 python3-pip
            elif [ -f /etc/redhat-release ]; then
                sudo yum install -y python3 python3-pip
            elif [ -f /etc/arch-release ]; then
                sudo pacman -Sy --noconfirm python python-pip
            else
                echo "Distribuição Linux não suportada. Instale manualmente: $PYTHON_URL"
                exit 1
            fi
            ;;
        MINGW*|CYGWIN*|MSYS*)
            echo "Instalando Python no Windows..."
            command -v choco &>/dev/null || powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
            choco install -y python
            ;;
        *)
            echo "Sistema operacional não suportado. Instale manualmente: $PYTHON_URL"
            exit 1
            ;;
    esac
}

# Função para instalar o pipx
install_pipx() {
    echo "Instalando pipx..."
    local os_name="$(uname -s)"
    case "$os_name" in
        Darwin)
            brew install pipx
            ;;
        Linux)
            python3 -m pip install --user pipx
            ;;
        MINGW*|CYGWIN*|MSYS*)
            python3 -m pip install --user pipx
            ;;
        *)
            echo "Sistema operacional não suportado para pipx"
            exit 1
            ;;
    esac
}

# Função para verificar a instalação do Coder
check_coder() {
    echo "Verificando instalação do Coder..."
    if pipx list | grep -q "coder"; then
        echo "Coder já está instalado."
        return 0
    fi
    echo "Coder não encontrado."
    return 1
}

# Função para instalar o Coder
install_coder() {
    if check_coder; then
        return
    fi
    echo "Instalando Coder com pipx..."
    pipx install "$CODER_URL"
    echo "Coder instalado com sucesso!"
}

# Execução principal
install_python
install_pipx
install_coder
>>>>>>> 6b313a28a0fff7529556c17a0a16b36cc775b166
