#!/bin/bash

# Importar utilitários de cores para mensagens
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

# Função para habilitar Touch ID para sudo
enable_touchid_sudo() {
    print_header_info "Enable Touch ID for sudo"

    if ! confirm_action "Do you want to enable Touch ID for sudo?"; then
        print_info "Skipping Touch ID configuration"
        return 0
    fi

    # Verifica se está sendo executado como root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root: sudo $0"
        exit 1
    fi

    PAM_FILE="/etc/pam.d/sudo"
    TOUCHID_LINE="auth       sufficient     pam_tid.so"

    # Verifica se a linha já existe
    if grep -Fxq "$TOUCHID_LINE" "$PAM_FILE"; then
        print_success "Touch ID is already enabled for sudo."
        # Não faz nada mais, apenas retorna
        return 1
    fi

    # Se chegou aqui, a linha não existe e precisamos adicioná-la
    print_header_info "Enabling Touch ID for sudo..."
    
    # Cria um backup do arquivo original
    local backup_file="$PAM_FILE.backup.$(date +%Y%m%d%H%M%S)"
    cp "$PAM_FILE" "$backup_file"
    print_info "Backup created: $backup_file"

    # Insere a linha no topo do arquivo
    (echo "$TOUCHID_LINE"; cat "$PAM_FILE") > "$PAM_FILE.tmp" && mv "$PAM_FILE.tmp" "$PAM_FILE"

    print_success "Touch ID successfully enabled for sudo!"
    
    return 1
}

# Executar o script apenas se não estiver sendo importado
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    enable_touchid_sudo "$@"
fi