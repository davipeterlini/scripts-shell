#!/bin/bash

# Shell Utils Library Installer
# Instalador automático para a biblioteca Shell Utils

set -e

# Configurações
REPO_URL="https://github.com/seu-usuario/shell-utils.git"
INSTALL_DIR="/usr/local/lib"
BIN_DIR="/usr/local/bin"
LIB_NAME="shell-utils"
VERSION="1.0.0"

# Cores para output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funções básicas de output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ Error: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Verificar se está executando como root (para instalação global)
check_root() {
    if [[ $EUID -ne 0 ]] && [[ "$1" == "global" ]]; then
        print_error "Instalação global requer privilégios de root. Use: sudo $0 global"
        exit 1
    fi
}

# Detectar sistema operacional
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux) OS="linux" ;;
        CYGWIN*|MINGW*|MSYS*) OS="windows" ;;
        *) OS="unknown" ;;
    esac
}

# Instalar dependências
install_dependencies() {
    print_info "Verificando dependências..."
    
    if ! command -v git &> /dev/null; then
        print_error "Git não está instalado. Instale o Git primeiro."
        exit 1
    fi
    
    # Verificar curl ou wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        print_error "curl ou wget são necessários para download."
        exit 1
    fi
    
    print_success "Dependências verificadas"
}

# Instalar localmente no projeto
install_local() {
    local target_dir="${1:-./libs}"
    
    print_info "Instalando Shell Utils localmente em: $target_dir"
    
    # Criar diretório se não existir
    mkdir -p "$target_dir"
    
    # Baixar arquivo diretamente
    if command -v curl &> /dev/null; then
        curl -sL "https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh" -o "$target_dir/shell-utils.sh"
    elif command -v wget &> /dev/null; then
        wget -q "https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh" -O "$target_dir/shell-utils.sh"
    fi
    
    chmod +x "$target_dir/shell-utils.sh"
    
    print_success "Instalado em: $target_dir/shell-utils.sh"
    print_info "Para usar: source \"$target_dir/shell-utils.sh\""
}

# Instalar globalmente no sistema
install_global() {
    print_info "Instalando Shell Utils globalmente..."
    
    # Criar diretórios
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    
    # Baixar e instalar biblioteca
    if command -v curl &> /dev/null; then
        curl -sL "https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh" -o "$INSTALL_DIR/$LIB_NAME.sh"
    elif command -v wget &> /dev/null; then
        wget -q "https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh" -O "$INSTALL_DIR/$LIB_NAME.sh"
    fi
    
    chmod +x "$INSTALL_DIR/$LIB_NAME.sh"
    
    # Criar wrapper executável
    cat > "$BIN_DIR/$LIB_NAME" << 'EOF'
#!/bin/bash
# Shell Utils Library Wrapper
source "/usr/local/lib/shell-utils.sh"
shell_utils_info
EOF
    
    chmod +x "$BIN_DIR/$LIB_NAME"
    
    print_success "Instalado globalmente em: $INSTALL_DIR/$LIB_NAME.sh"
    print_info "Para usar: source \"$INSTALL_DIR/$LIB_NAME.sh\""
    print_info "Comando disponível: $LIB_NAME"
}

# Instalar via gerenciador de pacotes (preparar estrutura)
install_package() {
    print_info "Preparando estrutura para empacotamento..."
    
    local pkg_dir="./package"
    mkdir -p "$pkg_dir"/{usr/local/lib,usr/local/bin,DEBIAN}
    
    # Copiar arquivos
    cp libs/shell-utils.sh "$pkg_dir/usr/local/lib/"
    
    # Criar control file para Debian
    cat > "$pkg_dir/DEBIAN/control" << EOF
Package: shell-utils
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Depends: bash (>= 4.0)
Maintainer: Your Name <your.email@domain.com>
Description: Shell utilities library for automation and development tools
 A comprehensive shell library providing utilities for:
 - Colored output and formatted messages
 - Directory management
 - OS detection
 - Interactive menus
 - Script execution
 - Git repository management
 - Cross-platform browser opening
EOF
    
    # Criar wrapper
    cat > "$pkg_dir/usr/local/bin/shell-utils" << 'EOF'
#!/bin/bash
source "/usr/local/lib/shell-utils.sh"
shell_utils_info
EOF
    
    chmod +x "$pkg_dir/usr/local/bin/shell-utils"
    chmod +x "$pkg_dir/usr/local/lib/shell-utils.sh"
    
    print_success "Estrutura de pacote criada em: $pkg_dir"
    print_info "Para criar pacote .deb: dpkg-deb --build $pkg_dir shell-utils_$VERSION.deb"
}

# Desinstalar
uninstall() {
    print_info "Removendo Shell Utils..."
    
    # Remover arquivos globais
    if [[ -f "$INSTALL_DIR/$LIB_NAME.sh" ]]; then
        rm -f "$INSTALL_DIR/$LIB_NAME.sh"
        print_success "Removido: $INSTALL_DIR/$LIB_NAME.sh"
    fi
    
    if [[ -f "$BIN_DIR/$LIB_NAME" ]]; then
        rm -f "$BIN_DIR/$LIB_NAME"
        print_success "Removido: $BIN_DIR/$LIB_NAME"
    fi
    
    print_success "Desinstalação concluída"
}

# Verificar instalação
check_installation() {
    print_info "Verificando instalação..."
    
    # Verificar instalação global
    if [[ -f "$INSTALL_DIR/$LIB_NAME.sh" ]]; then
        print_success "Instalação global encontrada: $INSTALL_DIR/$LIB_NAME.sh"
        
        # Testar carregamento
        if source "$INSTALL_DIR/$LIB_NAME.sh" 2>/dev/null; then
            print_success "Biblioteca carrega corretamente"
        else
            print_error "Erro ao carregar biblioteca"
        fi
    else
        print_warning "Instalação global não encontrada"
    fi
    
    # Verificar comando
    if command -v "$LIB_NAME" &> /dev/null; then
        print_success "Comando '$LIB_NAME' disponível"
    else
        print_warning "Comando '$LIB_NAME' não encontrado"
    fi
}

# Ajuda
show_help() {
    cat << EOF
Shell Utils Library Installer v$VERSION

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    local [DIR]     Instalar localmente (padrão: ./libs)
    global          Instalar globalmente (requer sudo)
    package         Criar estrutura de empacotamento
    uninstall       Remover instalação global
    check           Verificar instalação
    help            Mostrar esta ajuda

EXAMPLES:
    $0 local                    # Instalar em ./libs/
    $0 local ./vendor           # Instalar em ./vendor/
    sudo $0 global              # Instalar globalmente
    $0 package                  # Criar pacote .deb
    $0 check                    # Verificar instalação

USAGE AFTER INSTALL:
    Local:  source "./libs/shell-utils.sh"
    Global: source "/usr/local/lib/shell-utils.sh"
    Command: shell-utils

EOF
}

# Função principal
main() {
    detect_os
    
    case "${1:-help}" in
        "local")
            install_dependencies
            install_local "$2"
            ;;
        "global")
            check_root "global"
            install_dependencies
            install_global
            ;;
        "package")
            install_package
            ;;
        "uninstall")
            check_root "global"
            uninstall
            ;;
        "check")
            check_installation
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "Comando inválido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"