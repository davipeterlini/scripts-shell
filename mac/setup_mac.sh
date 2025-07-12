#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/detect_os.sh"

# Scripts Mac Setup
source "$(dirname "$0")/mac/setup/setup_basic_config.sh"
source "$(dirname "$0")/mac/setup/setup_iterm.sh"
source "$(dirname "$0")/mac/setup/setup_terminal.sh"
source "$(dirname "$0")/mac/setup/setup_abnt2_keyboard.sh"
source "$(dirname "$0")/mac/setup/enable_touchid_sudo.sh"
source "$(dirname "$0")/mac/setup/setup_karabiner.sh"

# Função principal
setup_mac() {
    print_header "Starting Setup for Mac Environment"
    load_env

    detect_os
    
    # Verificar se estamos em um sistema Mac
    if [[ "$os" != "macOS" ]]; then
        print_error "This script should only be run on macOS systems"
        exit 1
    fi

    # Configurações básicas do Mac
    setup_basic_config
    
    # Configuração do iTerm2
    setup_iterm
    
    # Configuração do Terminal
    setup_terminal
    
    # Configuração do teclado ABNT2
    setup_abnt2_keyboard
    
    # Habilitar Touch ID para sudo
    enable_touchid_sudo

    # Configuração do Teclado 
    setup_karabiner

    print_success "Mac setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_mac "$@"
fi