#!/bin/bash

# Script para instalação e configuração do Postman com Clean Architecture
# Autor: AI Assistant

###########################################
# ENTITIES / DOMAIN LAYER
###########################################

# Constantes do sistema
POSTMAN_VERSION="latest"
TEMP_DIR=$(mktemp -d)

###########################################
# USE CASES / APPLICATION LAYER
###########################################

# Verifica se o Postman já está instalado
check_postman_installed() {
    echo "Verificando se o Postman já está instalado..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v postman &> /dev/null || [ -d "/opt/Postman" ] || snap list | grep -q "postman"; then
            return 0  # Instalado
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if [ -d "/Applications/Postman.app" ]; then
            return 0  # Instalado
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        if [ -d "C:/Program Files/Postman" ] || [ -d "$APPDATA/Postman" ]; then
            return 0  # Instalado
        fi
    fi
    
    return 1  # Não instalado
}

# Instala o Postman no Linux
install_postman_linux() {
    echo "Sistema Linux detectado"
    
    # Verificar se o Snap está instalado
    if command -v snap &> /dev/null; then
        echo "Instalando Postman via Snap..."
        sudo snap install postman
    else
        echo "Snap não encontrado. Instalando via método alternativo..."
        
        cd "$TEMP_DIR"
        
        # Baixar o Postman
        echo "Baixando Postman..."
        wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
        
        # Extrair o arquivo
        echo "Extraindo arquivos..."
        tar -xzf postman.tar.gz
        
        # Mover para /opt
        echo "Instalando Postman em /opt..."
        sudo mv Postman /opt/
        
        # Criar link simbólico
        echo "Criando link simbólico..."
        sudo ln -sf /opt/Postman/app/Postman /usr/local/bin/postman
        
        # Criar entrada no menu de aplicativos
        echo "Criando atalho no menu de aplicativos..."
        mkdir -p ~/.local/share/applications/
        cat > ~/.local/share/applications/postman.desktop << EOL
[Desktop Entry]
Type=Application
Name=Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Exec="/opt/Postman/app/Postman" %f
Comment=Postman API Client
Categories=Development;Network;
Terminal=false
EOL
    fi
}

# Instala o Postman no macOS
install_postman_macos() {
    echo "Sistema macOS detectado"
    
    # Verificar se o Homebrew está instalado
    if command -v brew &> /dev/null; then
        echo "Instalando Postman via Homebrew..."
        brew install --cask postman
    else
        echo "Homebrew não encontrado. Instalando via download direto..."
        cd "$TEMP_DIR"
        
        # Baixar o Postman
        echo "Baixando Postman..."
        curl -L "https://dl.pstmn.io/download/latest/osx" -o postman.zip
        
        # Extrair o arquivo
        echo "Extraindo arquivos..."
        unzip -q postman.zip
        
        # Mover para Applications
        echo "Instalando Postman em /Applications..."
        mv "Postman.app" /Applications/
    fi
}

# Instala o Postman no Windows
install_postman_windows() {
    echo "Sistema Windows detectado"
    echo "Baixando instalador do Postman..."
    
    cd "$TEMP_DIR"
    
    # Baixar o instalador
    curl -L "https://dl.pstmn.io/download/latest/win64" -o postman_installer.exe
    
    # Executar o instalador silenciosamente
    echo "Executando o instalador do Postman..."
    ./postman_installer.exe -s
}

# Inicia o Postman
start_postman() {
    echo "Iniciando o Postman..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        postman &
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        open -a Postman
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        start "" "$APPDATA/Postman/Postman.exe" || start "" "C:/Program Files/Postman/Postman.exe"
    fi
    
    # Dar tempo para o Postman iniciar
    echo "Aguardando o Postman iniciar..."
    sleep 5
}

# Instala o Newman (CLI do Postman)
install_newman() {
    echo "Instalando Newman (CLI do Postman)..."
    
    if command -v npm &> /dev/null; then
        npm install -g newman
    else
        echo "ERRO: npm não encontrado. Por favor, instale o Node.js e npm primeiro."
        return 1
    fi
    
    return 0
}

# Configura o login do Postman via Newman
configure_postman_login() {
    echo "Configurando login do Postman..."
    
    # Verificar se o Newman está instalado
    if ! command -v newman &> /dev/null; then
        echo "Newman não está instalado. Tentando instalar..."
        install_newman
        if [ $? -ne 0 ]; then
            echo "Não foi possível instalar o Newman. O login automático não será possível."
            return 1
        fi
    fi
    
    # Solicitar credenciais
    read -p "Email do Postman: " POSTMAN_EMAIL
    read -sp "Senha do Postman: " POSTMAN_PASSWORD
    echo ""
    
    # Criar arquivo de configuração temporário
    cat > "$TEMP_DIR/postman_login.json" << EOL
{
    "info": {
        "name": "Postman Login",
        "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
    },
    "item": [
        {
            "name": "Login",
            "request": {
                "method": "POST",
                "header": [
                    {
                        "key": "Content-Type",
                        "value": "application/json"
                    }
                ],
                "body": {
                    "mode": "raw",
                    "raw": "{\"email\":\"${POSTMAN_EMAIL}\",\"password\":\"${POSTMAN_PASSWORD}\"}"
                },
                "url": {
                    "raw": "https://identity.getpostman.com/login",
                    "protocol": "https",
                    "host": ["identity", "getpostman", "com"],
                    "path": ["login"]
                }
            }
        }
    ]
}
EOL

    echo "Tentando login via Newman..."
    newman run "$TEMP_DIR/postman_login.json" --silent
    
    # Nota: Este método tem limitações, pois o Newman não pode realmente fazer login na aplicação desktop
    echo "NOTA: O login via linha de comando tem limitações. Se não funcionar, por favor faça login manualmente na interface gráfica."
    
    # Remover arquivo de configuração temporário
    rm -f "$TEMP_DIR/postman_login.json"
}

# Limpa recursos temporários
cleanup() {
    echo "Limpando recursos temporários..."
    rm -rf "$TEMP_DIR"
}

###########################################
# CONTROLLERS / INTERFACE ADAPTERS
###########################################

# Controlador principal
main() {
    echo "=== Instalação e Configuração do Postman ==="
    
    # Verificar se o Postman já está instalado
    if check_postman_installed; then
        echo "Postman já está instalado no sistema."
    else
        echo "Postman não encontrado. Iniciando instalação..."
        
        # Instalar de acordo com o sistema operacional
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            install_postman_linux
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            install_postman_macos
        elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
            install_postman_windows
        else
            echo "Sistema operacional não suportado"
            cleanup
            exit 1
        fi
        
        echo "Postman instalado com sucesso!"
    fi
    
    # Iniciar o Postman
    start_postman
    
    # Perguntar se deseja tentar login automático
    read -p "Deseja tentar o login automático? (s/n): " AUTO_LOGIN
    if [[ "$AUTO_LOGIN" == "s" || "$AUTO_LOGIN" == "S" ]]; then
        configure_postman_login
    else
        echo "Para fazer login no Postman, use a interface gráfica que foi aberta."
    fi
    
    # Limpar recursos
    cleanup
    
    echo "Processo concluído!"
}

###########################################
# FRAMEWORKS & DRIVERS / INFRASTRUCTURE
###########################################

# Tratamento de erros e sinais
trap cleanup EXIT
trap "echo 'Operação cancelada.'; cleanup; exit 1" INT TERM

# Iniciar o programa
main