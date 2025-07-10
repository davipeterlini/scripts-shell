#!/bin/bash

# Script para remover a instalação do Python 3.12.9 compilada com make
# Isso permite testar a barra de progresso no script de instalação

# Importar utilitários de cores e mensagens
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
source "$PROJECT_ROOT/utils/colors_message.sh"

# Diretório de instalação do Python
PYTHON_INSTALL_DIR="$HOME/.local/python3.12.9"

print_header "Limpeza da instalação do Python 3.12.9"

# Verificar se o diretório existe
if [[ -d "$PYTHON_INSTALL_DIR" ]]; then
    print_info "Removendo Python 3.12.9 instalado em: $PYTHON_INSTALL_DIR"
    
    # Perguntar ao usuário para confirmar
    read -p "Tem certeza que deseja remover esta instalação do Python? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remover o diretório
        rm -rf "$PYTHON_INSTALL_DIR"
        print_success "Python 3.12.9 removido com sucesso!"
    else
        print_alert "Operação cancelada pelo usuário."
        exit 0
    fi
else
    print_alert "Python 3.12.9 não encontrado em: $PYTHON_INSTALL_DIR"
    print_info "Nada para remover."
fi

# Limpar arquivos temporários de log
print_info "Removendo arquivos de log temporários..."
rm -f /tmp/python_configure.log /tmp/python_build.log /tmp/command_output.log

print_success "Limpeza concluída. Agora você pode testar o script de instalação novamente."