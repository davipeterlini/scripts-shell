#!/bin/bash

source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/colors_message.sh"

# Script para configuração automática do teclado ABNT2 no Mac OS X

# Constantes
readonly GITHUB_REPO_URL="https://github.com/lailsonbm/ABNT2-Layout/archive/refs/heads/master.zip"
readonly BUNDLE_NAME="Brazilian ABNT2.bundle"
readonly USER_LAYOUT_DIR="$HOME/Library/Keyboard Layouts"
readonly SYSTEM_LAYOUT_DIR="/Library/Keyboard Layouts"

# -----------------------------------------------------------------------------
# Funções de utilidade
# -----------------------------------------------------------------------------

# Verifica se as funções de mensagem estão disponíveis, caso contrário define-as
initialize_message_functions() {
    # Se o script for executado diretamente (não importado como source)
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        # Verificar se o script colors_message.sh existe e importá-lo
        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local utils_dir="${script_dir}/../../utils"
        
        if [[ -f "${utils_dir}/colors_message.sh" ]]; then
            source "${utils_dir}/colors_message.sh"
        else
            # Definir funções de fallback para mensagens
            function print_info() { echo -e "INFO: $1"; }
            function print_success() { echo -e "SUCESSO: $1"; }
            function print_alert() { echo -e "ALERTA: $1"; }
            function print_error() { echo -e "ERRO: $1"; }
            function print() { echo -e "$1"; }
            function print_header() { echo -e "\n==========================================================================\n$1\n==========================================================================="; }
            function print_header_info() { echo -e "\n=======================================================\n$1\n======================================================="; }
            function print_yellow() { echo -e "$1"; }
            function print_red() { echo -e "$1"; }
        fi
    fi
}

# Exibe os arquivos instalados no diretório de layouts
show_installed_layouts() {
    local layout_dir=$1
    
    print_info "Verificando arquivos instalados em ${layout_dir}:"
    ls -al "${layout_dir}"
    echo ""
}

# Realiza logout do usuário após confirmação
perform_logout() {
    print_alert "Para que o layout de teclado seja carregado, é necessário fazer logout."
    print_yellow "Deseja fazer logout agora? (s/n)"
    read -p "Resposta: " logout_response
    
    case "${logout_response}" in
        [Ss]*)
            print_info "Realizando logout em 5 segundos..."
            print_yellow "Salve todos os seus trabalhos abertos!"
            for i in {5..1}; do
                echo -n "$i... "
                sleep 1
            done
            echo "Logout!"
            osascript -e 'tell application "System Events" to log out'
            ;;
        *)
            print_info "Logout não realizado. Lembre-se de fazer logout manualmente para ativar o layout de teclado."
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Funções principais
# -----------------------------------------------------------------------------

# Baixa o arquivo do layout ABNT2
download_layout_file() {
    local temp_dir=$1
    
    print_info "Baixando o arquivo do layout ABNT2..."
    if ! curl -L -o "${temp_dir}/abnt2.zip" "${GITHUB_REPO_URL}"; then
        print_error "Falha ao baixar o arquivo. Verifique sua conexão com a internet."
        return 1
    fi
    
    return 0
}

# Extrai os arquivos do layout
extract_layout_files() {
    local temp_dir=$1
    
    print_info "Extraindo arquivos..."
    if ! unzip -q "${temp_dir}/abnt2.zip" -d "${temp_dir}"; then
        print_error "Falha ao extrair o arquivo."
        return 1
    fi
    
    # Verificar se o arquivo bundle existe
    if [ ! -d "${temp_dir}/ABNT2-Layout-master/${BUNDLE_NAME}" ]; then
        print_error "Arquivo do layout não encontrado no pacote baixado."
        return 1
    fi
    
    return 0
}

# Instala o layout para o usuário atual
install_for_user() {
    local temp_dir=$1
    
    # Criar diretório se não existir
    mkdir -p "${USER_LAYOUT_DIR}"
    
    print_info "Copiando layout para o diretório do usuário..."
    if ! cp -R "${temp_dir}/ABNT2-Layout-master/${BUNDLE_NAME}" "${USER_LAYOUT_DIR}/"; then
        print_error "Falha ao copiar o arquivo para o diretório do usuário."
        return 1
    fi
    
    print_success "Layout instalado com sucesso para o usuário atual."
    
    # Mostrar os arquivos instalados
    show_installed_layouts "${USER_LAYOUT_DIR}"
    
    return 0
}

# Instala o layout para todos os usuários do sistema
install_for_system() {
    local temp_dir=$1
    
    # Criar diretório se não existir
    sudo mkdir -p "${SYSTEM_LAYOUT_DIR}"
    
    print_info "Copiando layout para o diretório do sistema (requer senha de administrador)..."
    if ! sudo cp -R "${temp_dir}/ABNT2-Layout-master/${BUNDLE_NAME}" "${SYSTEM_LAYOUT_DIR}/"; then
        print_error "Falha ao copiar o arquivo para o diretório do sistema."
        return 1
    fi
    
    print_success "Layout instalado com sucesso para todos os usuários."
    
    # Mostrar os arquivos instalados no diretório do sistema
    print_info "Verificando arquivos instalados em ${SYSTEM_LAYOUT_DIR}:"
    sudo ls -al "${SYSTEM_LAYOUT_DIR}"
    echo ""
    
    # Também mostrar os arquivos no diretório do usuário (para referência)
    if [ -d "${USER_LAYOUT_DIR}" ]; then
        show_installed_layouts "${USER_LAYOUT_DIR}"
    fi
    
    return 0
}

# Exibe instruções finais para o usuário
display_final_instructions() {
    print_header_info "Instalação concluída! Se você não fizer logout agora, siga estes passos depois:"
    print "1. Faça logout (Finalizar Sessão) e entre novamente no sistema."
    print "2. Abra as Preferências do Sistema (System Preferences)."
    print "3. Vá em Teclado > Fontes de Entrada (Keyboard > Input Sources)."
    print "4. Clique no botão '+' e selecione 'Brasileiro ABNT2' (Brazilian ABNT2)."
    print "5. Se desejar usar apenas o teclado ABNT2, desmarque os outros layouts."
    print_success "Pronto! Agora você pode usar seu teclado ABNT2 normalmente."
}

# Função principal para configuração do teclado ABNT2
setup_abnt2_keyboard() {
    # Criar diretório temporário para download
    local temp_dir=$(mktemp -d)
    cd "${temp_dir}" || { print_error "Não foi possível acessar o diretório temporário."; return 1; }
    
    # Baixar e extrair os arquivos
    download_layout_file "${temp_dir}" || return 1
    extract_layout_files "${temp_dir}" || return 1
    
    # Solicitar opção de instalação
    print_header_info "Escolha onde instalar o layout de teclado:"
    print_yellow "1 - Apenas para o usuário atual (~/Library/Keyboard Layouts)"
    print_yellow "2 - Para todos os usuários do sistema (/Library/Keyboard Layouts) - requer senha de administrador"
    read -p "Opção (1/2): " install_option
    
    # Instalar de acordo com a opção escolhida
    case "${install_option}" in
        1) install_for_user "${temp_dir}" || return 1 ;;
        2) install_for_system "${temp_dir}" || return 1 ;;
        *) print_error "Opção inválida."; return 1 ;;
    esac
    
    # Limpar arquivos temporários
    print_info "Limpando arquivos temporários..."
    rm -rf "${temp_dir}"
    
    # Exibir instruções finais
    display_final_instructions
    
    # Perguntar se o usuário deseja fazer logout
    perform_logout
    
    return 0
}

setup_abnt2_keyboard() {
    print_header_info "Configuração do Teclado ABNT2 para Mac OS X"

    if ! confirm_action "Do you want Config Keyboard for Brazilian ABNT2?"; then
        print_info "Skipping configuration"
        return 0
    fi
    # Inicializar funções de mensagem
    initialize_message_functions
    
    # Executar a configuração do teclado ABNT2
    setup_abnt2_keyboard
    
    return $?
}

# Executar o script se não estiver sendo importado como source
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_abnt2_keyboard
    exit $?
fi