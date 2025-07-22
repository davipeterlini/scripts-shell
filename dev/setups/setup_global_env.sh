#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/choose_shell_profile.sh"
source "$(dirname "$0")/utils/profile_writer.sh"

# TODO - pode ser usado o  load_env .env.example
ENV_EXAMPLE="./assets/.env.credential"
ENV_DIR="$HOME"

_create_env_file() {
    local env_example_path="$ENV_EXAMPLE"
    local env_target_path="$ENV_DIR/.env"

    # Check if .env already exists
    if [ -f "$env_target_path" ]; then
        print_alert "The file $env_target_path already exists."
        print_info "Current content of $env_target_path:"
        cat "$env_target_path"
        
        # Ask if user wants to create a backup
        if get_user_confirmation "Do you want to create a backup of the existing .env file?"; then
            local backup_path="$env_target_path.backup.$(date +%Y%m%d%H%M%S)"
            cp "$env_target_path" "$backup_path"
            print_success "Backup created at $backup_path"
        fi
        
        # Ask if user wants to overwrite
        if ! get_user_confirmation "Do you want to overwrite the existing .env file?"; then
            print_info "Keeping existing .env file."
            return 0
        fi
    fi

    if [ -f "$env_example_path" ]; then
        cp "$env_example_path" "$env_target_path"
        print_success ".env file created at $env_target_path"
    else
        print_error "$env_example_path does not exist."
        exit 1
    fi
}

_add_export_to_profile() {
    local profile_path="$1"
    local export_line="export \$(grep -v '^#' ~/.env | xargs)"
    
    # Usar o profile_writer para adicionar a linha de exportação
    write_lines_to_profile " " "$export_line" "$profile_path"
    print_success "Added environment variables export to $profile_path"
}

_setup_variables() {
    local env_file="$HOME/.env"
    local variables_updated=0
    local keys=()
    
    # Check if .env file exists, create it if it doesn't
    if [ ! -f "$env_file" ]; then
        print_alert "$env_file does not exist. Creating it from template..."
        
        # Check if the example file exists
        if [ -f "$ENV_EXAMPLE" ]; then
            # Create directory if it doesn't exist
            mkdir -p "$(dirname "$env_file")"
            
            # Copy the example file to the home directory
            cp "$ENV_EXAMPLE" "$env_file"
            print_success "Created $env_file from template."
        else
            # If no template exists, create an empty file
            touch "$env_file"
            print_success "Created empty $env_file file."
        fi
    fi
    
    print_info "Setting up environment variables"
    
    # First, collect all the variable keys from the .env file
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^#.*$ || -z "$line" ]]; then
            continue
        fi
        
        # Extract the key name
        key=$(echo "$line" | cut -d'=' -f1)
        keys+=("$key")
    done < "$env_file"
    
    # Now process each key one by one, waiting for user input after each
    for key in "${keys[@]}"; do
        # Clear prompt for each variable
        printf "Put the value %s: " "$key"
        
        # Using read -r to preserve backslashes in input
        read -r value
        
        # If a value was provided, update the .env file
        if [ ! -z "$value" ]; then
            __update_env_key "$env_file" "$key" "$value"
            ((variables_updated++))
        fi
    done
    
    if ! get_user_confirmation "Do you want to save these changes?"; then
        print_info "Changes discarded."
        # Restore from backup if it exists
        local latest_backup=$(ls -t "$env_file.backup."* 2>/dev/null | head -n1)
        if [ ! -z "$latest_backup" ]; then
            cp "$latest_backup" "$env_file"
            print_success "Restored from backup: $latest_backup"
        fi
        return 0
    fi
    
    # Simple completion message
    print_success "Updated $variables_updated environment variables."
}

__update_env_key() {
    local env_file="$1"
    local key="$2"
    local value="$3"
    
    # Create a temporary file
    local temp_file=$(mktemp)
    
    # Replace the line containing the key with the new key=value pair
    while IFS= read -r line; do
        if [[ "$line" =~ ^"$key"= ]]; then
            echo "$key=$value" >> "$temp_file"
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$env_file"
    
    # Replace the original file with the temporary file
    mv "$temp_file" "$env_file"
}

_reload_profile() {
    local profile="$1"
    
    if [ -f "$profile" ]; then
        print_alert "Notificando sobre o arquivo de perfil $(basename $profile)..."
        print_info "As variáveis de ambiente estarão disponíveis na próxima vez que você abrir um terminal"
        print_info "ou após executar manualmente: source $profile"
        
        # Verificar se o arquivo de perfil pode ser carregado sem problemas (em uma subshell)
        if (bash -c "source $profile" &>/dev/null); then
            print_success "O arquivo de perfil $(basename $profile) foi verificado com sucesso."
        else
            print_alert "Aviso: O arquivo de perfil $(basename $profile) pode conter erros."
            print_info "Continuando a execução do script..."
        fi
        
        # Carregar as variáveis de ambiente no ambiente atual para uso imediato
        # sem sair do script atual
        if [ -f "$HOME/.env" ]; then
            export $(grep -v '^#' "$HOME/.env" | xargs) 2>/dev/null
            print_success "Variáveis de ambiente carregadas no script atual."
        fi
    else
        print_error "Não foi possível encontrar o arquivo de perfil $(basename $profile)."
        print_info "Continuando a execução do script..."
    fi
}

setup_global_env() {
    print_header_info "Setting up global environment"

    if ! get_user_confirmation "Do you want to set up global environment?"; then
        print_info "Skipping configuration"
        return 0
    fi
    
    _create_env_file
    
    choose_shell_profile
    
    # Remover entradas antigas antes de adicionar novas
    remove_script_entries_from_profile "setup_global_env" "$PROFILE_FILE"
    
    # Adicionar a linha de exportação usando o profile_writer
    _add_export_to_profile "$PROFILE_FILE"
    
    _setup_variables

    _reload_profile "$PROFILE_FILE"

    print_success "Global environment setup completed!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_global_env "$@"
fi