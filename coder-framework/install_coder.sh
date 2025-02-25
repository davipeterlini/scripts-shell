#!/bin/bash

set -e

# Constantes
PYTHON_URL="https://www.python.org/"
CODER_JSON_URL="https://storage.googleapis.com/flow-coder/update_info.json"
CODER_FILE="coder-latest.whl"

# Função para obter a última versão do Coder
get_latest_coder_url() {
    echo "Obtendo a última versão do Coder..."
    local latest_info=$(curl -s "$CODER_JSON_URL")

    # Extração da URL com Python
    local latest_url=$(echo "$latest_info" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['url'])")
    
    # Verificar se a URL é válida
    if [[ ! "$latest_url" =~ ^https?:// ]]; then
        echo "Erro: URL extraída não é válida."
        exit 1
    fi
    
    echo "Última versão do Coder: $latest_url"
    echo "$latest_url"
}

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

# Função para verificar a instalação do Coder
check_coder() {
    echo "Verificando instalação do Coder..."
    if python3 -m pip show coder &>/dev/null; then
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
    local coder_url=$(get_latest_coder_url)

    # Baixando o pacote do Coder com verificação do download
    echo "Baixando o pacote do Coder..."
    if ! curl -o "$CODER_FILE" "$coder_url"; then
        echo "Erro ao baixar o pacote do Coder."
        exit 1
    fi

    echo "Instalando o Coder..."
    python3 -m pip install --upgrade pip
    python3 -m pip install "$CODER_FILE"

    echo "Removendo arquivo temporário..."
    rm -f "$CODER_FILE"

    echo "Coder instalado com sucesso!"
}

# Execução principal
install_python
install_coder