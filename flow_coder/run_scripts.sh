#!/bin/bash

# Script for running Flow Coder setup scripts

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import utility scripts with correct paths
source "$SCRIPT_DIR/../utils/colors_message.sh"

# Define a simplified version of the create_script_zips function
create_script_zips_simple() {
    print_header "Criando pacotes ZIP de scripts"
    
    # Check if the original script exists and source it
    if [ -f "$SCRIPT_DIR/create_script_zips.sh" ]; then
        # Source the script to get its functions
        source "$SCRIPT_DIR/create_script_zips.sh"
        
        # Create both ZIP files directly
        create_windows_zip
        create_linux_zip
        
        print_success "Pacotes ZIP criados com sucesso"
    else
        print_error "Script create_script_zips.sh não encontrado"
        return 1
    fi
    
    return 0
}

# Define a simplified version of the upload_zips_to_gcs function
upload_zips_to_gcs_simple() {
    print_header "Fazendo upload dos pacotes ZIP para o Google Cloud Storage"
    
    # Check if the original script exists and source it
    if [ -f "$SCRIPT_DIR/upload_zips_to_gcs.sh" ]; then
        # Source the script to get its functions
        source "$SCRIPT_DIR/upload_zips_to_gcs.sh"
        
        # Check gcloud setup first
        if ! check_gcloud_setup; then
            print_error "Configuração do gcloud falhou"
            return 1
        fi
        
        # Upload both ZIP files directly
        upload_windows_zip
        upload_linux_zip
        
        print_success "Upload dos pacotes ZIP concluído com sucesso"
    else
        print_error "Script upload_zips_to_gcs.sh não encontrado"
        return 1
    fi
    
    return 0
}

run_script() {
    print_header "Starting Create Script to config VMs to Test Flow Coder Extension"
    
    create_script_zips_simple
    upload_zips_to_gcs_simple
    
    print_success "Create Script to config VMs to Flow Coder Extension completed successfully!"
    
    return 0
}

# Execute main only if the script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_script "$@"
fi