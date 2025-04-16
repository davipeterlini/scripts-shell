#!/bin/bash

#source "$(dirname "$0")/mac/update_brew_apps.sh"

# Função para exibir mensagens coloridas
function print_message() {
    local color=$1
    local message=$2
    case $color in
        "green") echo -e "\033[0;32m${message}\033[0m" ;;
        "red") echo -e "\033[0;31m${message}\033[0m" ;;
        "yellow") echo -e "\033[0;33m${message}\033[0m" ;;
        *) echo "${message}" ;;
    esac
}

# TODO - se o homebrew já tiver sido instalado ignorar instalação
install_homebrew() {
    # Verifica se o Homebrew já está instalado
    if command -v brew &> /dev/null; then
        print_message "yellow" "Homebrew já está instalado."
    else
        # Instala o Homebrew
        print_message "green" "Instalando o Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Adiciona o Homebrew ao PATH
        print_message "green" "Adicionando o Homebrew ao PATH..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

# Function to adjust permissions
adjust_permissions() {
    echo "Adjusting permissions for Homebrew directories..."
    sudo chown -R $(whoami) /usr/local/Homebrew
    sudo chown -R $(whoami) /usr/local/Cellar
    sudo chown -R $(whoami) /usr/local/Caskroom
    sudo chown -R $(whoami) /usr/local/bin
    sudo chown -R $(whoami) /usr/local/etc
    sudo chown -R $(whoami) /usr/local/include
    sudo chown -R $(whoami) /usr/local/lib
    sudo chown -R $(whoami) /usr/local/opt
    sudo chown -R $(whoami) /usr/local/sbin
    sudo chown -R $(whoami) /usr/local/share
    sudo chown -R $(whoami) /usr/local/var
    sudo chown -R $(whoami) ~/Library/Caches/Homebrew
    sudo chown -R $(whoami) ~/Library/Logs/Homebrew
    sudo chown -R $(whoami) ~/Library/Preferences/Homebrew
    sudo chown -R $(whoami) ~/Library/Application\ Support/Homebrew
}

# Atualiza o Homebrew

main() {
    print_message "green" "Atualizando o Homebrew..."
    install_homebrew
    #adjust_permissions
    #update_brew_apps
    print_message "green" "Instalação e atualização do Homebrew concluídas com sucesso."
}

main "$@"