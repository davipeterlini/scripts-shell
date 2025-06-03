#!/bin/bash

# Importa o script de mensagens coloridas
source "$(dirname "$0")/../../utils/colors_message.sh"

# Função para escolher o sistema operacional
choose_os() {
    print_header "Escolha o sistema operacional para iniciar as aplicações de desenvolvimento:"
    print "1) macOS"
    print "2) Linux"
    print "3) Windows"
    read -p "Digite o número correspondente à sua escolha (ou pressione Enter para auto-detectar): " os_choice

    case "$os_choice" in
        1)
            print_success "macOS escolhido."
            print "macOS"
            ;;
        2)
            print_success "Linux escolhido."
            print "Linux"
            ;;
        3)
            print_success "Windows escolhido."
            print "Windows"
            ;;
        *)
            print_alert "Nenhuma escolha válida foi feita. Auto-detectando o sistema operacional..."
            case "$(uname -s)" in
                Darwin)
                    print_success "macOS detectado."
                    print "macOS"
                    ;;
                Linux)
                    print_success "Linux detectado."
                    print "Linux"
                    ;;
                CYGWIN*|MINGW32*|MSYS*|MINGW*)
                    print_success "Windows detectado."
                    print "Windows"
                    ;;
                *)
                    print_error "Sistema operacional não suportado."
                    exit 1
                    ;;
            esac
            ;;
    esac
}