#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"

install_homebrew() {
    # Verifica se o Homebrew já está instalado
    if command -v brew &> /dev/null; then
        print_alert "Homebrew já está instalado."
    else
        # Instala o Homebrew
        print_success "Instalando o Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Adiciona o Homebrew ao PATH
        print_success "Adicionando o Homebrew ao PATH..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_homebrew "$@"
fi