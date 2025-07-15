#!/bin/bash
# upload_zips_to_gcs.sh - Uploads ZIP packages to Google Cloud Storage

# Import color utilities
# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file
source "$SCRIPT_DIR/../utils/colors_message.sh"

# Constants
readonly BUCKET_NAME="flow-coder/scripts"
readonly WINDOWS_ZIP="windows_scripts.zip"
readonly LINUX_ZIP="linux_scripts.zip"
readonly ZIP_DIR="$SCRIPT_DIR"

# Define menu functions if they don't exist
if ! type print_menu > /dev/null 2>&1; then
    print_menu() {
        echo -e "\n===== MENU ====="
    }
fi

if ! type print_menu_option > /dev/null 2>&1; then
    print_menu_option() {
        echo -e "[$1] $2"
    }
fi

if ! type print_alert > /dev/null 2>&1; then
    print_alert() {
        echo -e "\n⚠️  $1"
    }
fi

# Check if gcloud is installed and configured
check_gcloud_setup() {
    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        print_error "O comando 'gcloud' não foi encontrado. Por favor, instale o Google Cloud SDK primeiro."
        echo "Visite: https://cloud.google.com/sdk/docs/install"
        return 1
    fi
    
    # Check if gcloud is configured
    print_alert "Verificando configuração do gcloud..."
    if ! gcloud config list --format="value(core.project)" &> /dev/null; then
        print_error "O gcloud não está configurado corretamente."
        echo "Execute 'gcloud init' para configurar o gcloud."
        return 1
    fi
    
    # Check if user is authenticated
    print_alert "Verificando autenticação do gcloud..."
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        print_error "Você não está autenticado no gcloud."
        echo "Execute 'gcloud auth login' para autenticar."
        return 1
    fi
    
    return 0
}

# Check if file exists
check_file_exists() {
    local file_path="$ZIP_DIR/$1"
    if [ ! -f "$file_path" ]; then
        print_error "O arquivo $file_path não foi encontrado."
        echo "Execute o script create_script_zips.sh para criar os arquivos ZIP primeiro."
        return 1
    fi
    return 0
}

# Remove file from Google Cloud Storage
remove_from_gcs() {
    local file_name=$1
    
    print_alert "Removendo $file_name do bucket gs://$BUCKET_NAME/"
    
    if gcloud storage rm "gs://$BUCKET_NAME/$file_name" --quiet 2>/dev/null; then
        print_success "Arquivo $file_name removido com sucesso do bucket!"
        return 0
    else
        print_info "Arquivo $file_name não encontrado no bucket ou erro ao remover."
        return 0  # Continue even if removal fails
    fi
}

# Upload file to Google Cloud Storage
upload_to_gcs() {
    local file_name=$1
    local file_path="$ZIP_DIR/$file_name"
    
    # First remove the existing file from the bucket
    remove_from_gcs "$file_name"
    
    print_alert "Fazendo upload de $file_path para gs://$BUCKET_NAME/"
    
    if gcloud storage cp "$file_path" "gs://$BUCKET_NAME/"; then
        print_success "Upload de $file_name concluído com sucesso!"
        print_info "URL público: https://storage.googleapis.com/$BUCKET_NAME/$file_name"
        return 0
    else
        print_error "Falha ao fazer upload de $file_name."
        return 1
    fi
}

# Upload Windows ZIP file
upload_windows_zip() {
    if check_file_exists "$WINDOWS_ZIP"; then
        upload_to_gcs "$WINDOWS_ZIP"
        return $?
    fi
    return 1
}

# Upload Linux/Mac ZIP file
upload_linux_zip() {
    if check_file_exists "$LINUX_ZIP"; then
        upload_to_gcs "$LINUX_ZIP"
        return $?
    fi
    return 1
}

# Process menu selection
process_menu_option() {
    local option=$1
    
    case $option in
        1)
            upload_windows_zip
            read -p "Pressione Enter para continuar..."
            ;;
        2)
            upload_linux_zip
            read -p "Pressione Enter para continuar..."
            ;;
        3)
            upload_windows_zip
            upload_linux_zip
            read -p "Pressione Enter para continuar..."
            ;;
        4)
            echo ""
            echo "Obrigado por usar o Upload de ZIPs para o Google Cloud Storage!"
            echo ""
            exit 0
            ;;
        *)
            print_error "Opção inválida. Por favor, tente novamente."
            sleep 2
            ;;
    esac
    
    clear
}

# Display menu and get user input
show_menu() {
    print_menu
    print_menu_option "1" "Fazer upload do ZIP de scripts Windows"
    print_menu_option "2" "Fazer upload do ZIP de scripts Linux/Mac"
    print_menu_option "3" "Fazer upload de ambos os ZIPs"
    print_menu_option "4" "Sair"
    echo ""
    read -p "Digite o número da opção desejada: " option
    process_menu_option "$option"
}

# Main function that orchestrates the script execution
upload_zips_to_gcs() {
    # Display header
    print_header "Upload de ZIPs para o Google Cloud Storage"
    
    # Check gcloud setup
    if ! check_gcloud_setup; then
        exit 1
    fi
    
    print_info "Procurando arquivos ZIP na pasta: $ZIP_DIR"
    
    # Main program loop
    while true; do
        show_menu
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  upload_zips_to_gcs "$@"
fi