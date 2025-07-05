#!/bin/bash

# Script to create ZIP packages of Windows and Linux scripts for Flow Coder

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if colors_message.sh is available and source it
if [ -f "$SCRIPT_DIR/linux/utils/colors_message.sh" ]; then
    source "$SCRIPT_DIR/linux/utils/colors_message.sh"
else
    # Fallback colors if utils script is not available
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
    
    # Define fallback print functions
    print_header() { echo -e "\n${YELLOW}===========================================================================${NC}"; echo -e "${GREEN}$1${NC}"; echo -e "${YELLOW}===========================================================================${NC}"; }
    print_success() { echo -e "${GREEN}✅ $1${NC}"; }
    print_error() { echo -e "${RED}❌ Error: $1${NC}"; }
    print_info() { echo -e "\n${BLUE}ℹ️  $1${NC}"; }
fi

# Check if zip is installed
check_zip_installed() {
    if ! command -v zip &> /dev/null; then
        print_error "O comando 'zip' não foi encontrado. Por favor, instale-o primeiro."
        echo "No Ubuntu/Debian: sudo apt-get install zip"
        echo "No CentOS/RHEL: sudo yum install zip"
        echo "No macOS: brew install zip"
        return 1
    fi
    return 0
}

# Function to create Windows scripts ZIP preserving directory structure
create_windows_zip() {
    print_info "Criando ZIP dos scripts de Windows..."
    
    # Check if windows directory exists
    if [ ! -d "$SCRIPT_DIR/windows" ]; then
        print_error "A pasta $SCRIPT_DIR/windows não foi encontrada"
        return 1
    fi
    
    # Create the ZIP file directly from the windows directory
    cd "$SCRIPT_DIR"
    if [ -d "windows" ] && [ "$(ls -A windows)" ]; then
        # Create zip with the content of windows directory, preserving the structure
        zip -r windows_scripts.zip windows
        print_success "ZIP dos scripts de Windows criado com sucesso: $SCRIPT_DIR/windows_scripts.zip"
    else
        print_error "Nenhum script Windows encontrado na pasta $SCRIPT_DIR/windows"
    fi
    cd "$OLDPWD"
}

# Function to create Linux/Mac scripts ZIP preserving directory structure
create_linux_zip() {
    print_info "Criando ZIP dos scripts de Linux/Mac..."
    
    # Check if linux directory exists
    if [ ! -d "$SCRIPT_DIR/linux" ]; then
        print_error "A pasta $SCRIPT_DIR/linux não foi encontrada"
        return 1
    fi
    
    # Create the ZIP file directly from the linux directory
    cd "$SCRIPT_DIR"
    if [ -d "linux" ] && [ "$(ls -A linux)" ]; then
        # Create zip with the content of linux directory, preserving the structure
        zip -r linux_scripts.zip linux
        print_success "ZIP dos scripts de Linux/Mac criado com sucesso: $SCRIPT_DIR/linux_scripts.zip"
    else
        print_error "Nenhum script Linux/Mac encontrado na pasta $SCRIPT_DIR/linux"
    fi
    cd "$OLDPWD"
}

# Main function to create both ZIPs
create_script_zips() {
    if ! check_zip_installed; then
        return 1
    fi
    
    create_windows_zip
    create_linux_zip
    
    return 0
}

# Main menu - executed only when the script is called directly
run_menu() {
    print_header "Criador de Pacotes ZIP de Scripts"
    
    if ! check_zip_installed; then
        exit 1
    fi
    
    while true; do
        echo "Selecione uma opção:"
        echo ""
        echo "1. Criar ZIP dos scripts de Windows"
        echo "2. Criar ZIP dos scripts de Linux/Mac"
        echo "3. Criar ambos os ZIPs"
        echo "4. Sair"
        echo ""
        read -p "Digite o número da opção desejada: " option
        
        case $option in
            1)
                create_windows_zip
                read -p "Pressione Enter para continuar..."
                ;;
            2)
                create_linux_zip
                read -p "Pressione Enter para continuar..."
                ;;
            3)
                create_windows_zip
                create_linux_zip
                read -p "Pressione Enter para continuar..."
                ;;
            4)
                echo ""
                echo "Obrigado por usar o Criador de Pacotes ZIP de Scripts!"
                echo ""
                exit 0
                ;;
            *)
                print_error "Opção inválida. Por favor, tente novamente."
                sleep 2
                ;;
        esac
        
        clear
        print_header "Criador de Pacotes ZIP de Scripts"
    done
}

# Execute the main menu only if the script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_menu
fi