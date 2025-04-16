#!/bin/bash

source "$(dirname "$0")/update_brew_apps.sh"

# TODO - se o homebrew já tiver sido instalado ignorar instalação
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

# Atualiza o Homebrew
print_message "green" "Atualizando o Homebrew..."
update_brew_apps

print_message "green" "Instalação e atualização do Homebrew concluídas com sucesso."