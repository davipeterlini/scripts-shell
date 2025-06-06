#!/bin/bash

# Import color utility
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/utils/colors_message.sh"

# Constants
ASSETS_DIR="$SCRIPT_DIR/assets/ssh-git"
SSH_CONFIG_DIR="$HOME/.ssh"
SSH_CONFIG_FILE="$SSH_CONFIG_DIR/config"
GIT_CONFIG_FILE="$HOME/.gitconfig"

# Functions
create_ssh_directory() {
    if [ ! -d "$SSH_CONFIG_DIR" ]; then
        print_info "Creating SSH directory at $SSH_CONFIG_DIR..."
        mkdir -p "$SSH_CONFIG_DIR"
        chmod 700 "$SSH_CONFIG_DIR"
        print_success "SSH directory created successfully!"
    fi
}

backup_existing_config() {
    if [ -f "$SSH_CONFIG_FILE" ]; then
        local backup_file="$SSH_CONFIG_FILE.backup.$(date +%Y%m%d%H%M%S)"
        print_info "Backing up existing SSH config to $backup_file..."
        cp "$SSH_CONFIG_FILE" "$backup_file"
        print_success "Backup created: $backup_file"
    fi
    
    if [ -f "$GIT_CONFIG_FILE" ]; then
        local git_backup_file="$GIT_CONFIG_FILE.backup.$(date +%Y%m%d%H%M%S)"
        print_info "Backing up existing Git config to $git_backup_file..."
        cp "$GIT_CONFIG_FILE" "$git_backup_file"
        print_success "Backup created: $git_backup_file"
    fi
}

check_ssh_keys() {
    print_info "Checking for SSH keys in $SSH_CONFIG_DIR..."
    
    # Obter todas as chaves SSH existentes (apenas chaves privadas)
    local required_keys=()
    
    # Procura por arquivos de chave privada (sem extensão .pub)
    for key_file in "$SSH_CONFIG_DIR"/id_*; do
        # Ignora arquivos .pub e outros que não são chaves privadas
        if [[ -f "$key_file" && ! "$key_file" =~ \.pub$ ]]; then
            local key_name=$(basename "$key_file")
            local key_type=$(ssh-keygen -l -f "$key_file" 2>/dev/null | awk '{print $2}')
            
            if [ -n "$key_type" ]; then
                required_keys+=("$key_name")
            fi
        fi
    done
    
    # Exibir as chaves encontradas
    if [ ${#required_keys[@]} -eq 0 ]; then
        print_alert "No SSH keys found."
        print_info "Would you like to generate a default SSH key? (y/n)"
        read -r generate_key
        
        if [[ "$generate_key" =~ ^[Yy]$ ]]; then
            print_info "Generating default SSH key (id_rsa)..."
            ssh-keygen -t rsa -b 4096 -f "$SSH_CONFIG_DIR/id_rsa" -N ""
            chmod 600 "$SSH_CONFIG_DIR/id_rsa"
            print_success "Default SSH key generated successfully!"
            print_info "Public key (add this to your Git service):"
            cat "$SSH_CONFIG_DIR/id_rsa.pub"
            print
            required_keys+=("id_rsa")
        else
            print_alert "No SSH keys available. You may need to create keys manually."
        fi
    else
        print_success "Found ${#required_keys[@]} SSH key(s)!"
        print_info "Available SSH keys:"
        for key in "${required_keys[@]}"; do
            local key_type=$(ssh-keygen -l -f "$SSH_CONFIG_DIR/$key" 2>/dev/null | awk '{print $2}')
            print "  - $key ($key_type)"
        done
    fi
    
    # Perguntar se o usuário deseja gerar chaves adicionais
    print_info "Would you like to generate additional SSH keys? (y/n)"
    read -r generate_additional
    
    if [[ "$generate_additional" =~ ^[Yy]$ ]]; then
        print_info "Enter the name for the new SSH key (e.g., id_rsa_work):"
        read -r new_key_name
        
        if [[ -z "$new_key_name" ]]; then
            print_alert "Invalid key name. Operation canceled."
        elif [[ -f "$SSH_CONFIG_DIR/$new_key_name" ]]; then
            print_alert "A key with this name already exists. Operation canceled."
        else
            print_info "Generating new SSH key $new_key_name..."
            ssh-keygen -t rsa -b 4096 -f "$SSH_CONFIG_DIR/$new_key_name" -N ""
            chmod 600 "$SSH_CONFIG_DIR/$new_key_name"
            print_success "SSH key $new_key_name generated successfully!"
            print_info "Public key (add this to your Git service):"
            cat "$SSH_CONFIG_DIR/$new_key_name.pub"
            print
            required_keys+=("$new_key_name")
        fi
    fi
    
    return 0
}

list_assets_files() {
    if [ ! -d "$ASSETS_DIR" ]; then
        print_error "Assets directory not found at $ASSETS_DIR."
        exit 1
    fi

    local files=($(find "$ASSETS_DIR" -type f -name "config-ssh-*" 2>/dev/null | sort))

    if [ ${#files[@]} -eq 0 ]; then
        print_error "No configuration files found in the assets directory."
        exit 1
    fi

    echo "${files[@]}"
}

display_files_with_index() {
    local files=("$@")
    print_info "Available configuration files:"
    for i in "${!files[@]}"; do
        local filename=$(basename "${files[$i]}")
        print "$((i + 1))) $filename"
    done
}

get_user_choice() {
    local files=("$@")
    read -p "$(print_info "Choose a configuration file by number: ")" choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#files[@]} ]; then
        print_alert "Invalid option. Operation canceled."
        exit 1
    fi

    echo "${files[$((choice - 1))]}"
}

configure_ssh() {
    local config_file=$1

    if [ ! -f "$config_file" ]; then
        print_error "Configuration file $config_file not found."
        exit 1
    fi

    print_info "Configuring SSH with $config_file..."
    
    # Replace $HOME with actual home directory path
    sed "s|\$HOME|$HOME|g" "$config_file" > "$SSH_CONFIG_FILE"
    
    # Ensure proper permissions
    chmod 600 "$SSH_CONFIG_FILE"
    print_success "SSH configuration updated successfully!"
}

configure_git() {
    print_info "Configuring Git for SSH hosts..."
    
    # Detectar hosts configurados
    local hosts=$(grep -E "^Host " "$SSH_CONFIG_FILE" | awk '{print $2}')
    local git_config_updated=false
    
    # Verificar se o usuário deseja configurar o Git
    print_info "Would you like to configure Git to use these SSH settings? (y/n)"
    read -r configure_git_choice
    
    if [[ ! "$configure_git_choice" =~ ^[Yy]$ ]]; then
        print_info "Skipping Git configuration."
        return 0
    fi
    
    # Verificar se o arquivo .gitconfig já existe
    if [ ! -f "$GIT_CONFIG_FILE" ]; then
        # Configuração básica do Git se o arquivo não existir
        print_info "Git config file not found. Let's create a basic configuration."
        print_info "Enter your name for Git commits:"
        read -r git_name
        print_info "Enter your email for Git commits:"
        read -r git_email
        
        # Criar arquivo .gitconfig com configurações básicas
        cat > "$GIT_CONFIG_FILE" << EOF
[user]
    name = $git_name
    email = $git_email
[core]
    editor = vim
[color]
    ui = auto
EOF
        print_success "Basic Git configuration created."
    fi
    
    # Adicionar configurações de URL para cada host SSH
    for host in $hosts; do
        # Ignorar hosts com caracteres especiais como * ou ?
        if [[ "$host" != *"*"* && "$host" != *"?"* ]]; then
            # Extrair o hostname real
            local hostname=$(grep -A5 "^Host $host" "$SSH_CONFIG_FILE" | grep "HostName" | head -1 | awk '{print $2}')
            
            if [ -n "$hostname" ]; then
                # Determinar o tipo de serviço (github, bitbucket, etc.)
                if [[ "$hostname" == "github.com" ]]; then
                    # Determinar o contexto (work, personal, etc.) do nome do host
                    local context=$(echo "$host" | sed -E 's/github\.com-?//')
                    if [ -n "$context" ]; then
                        print_info "Configuring Git for GitHub ($context)..."
                        
                        # Verificar se já existe uma configuração para este host
                        if ! grep -q "\[url \"git@$host:\"\]" "$GIT_CONFIG_FILE"; then
                            # Adicionar configuração para este host
                            cat >> "$GIT_CONFIG_FILE" << EOF

[url "git@$host:"]
    insteadOf = https://github.com/$context/
EOF
                            git_config_updated=true
                        else
                            print_info "Git configuration for $host already exists."
                        fi
                    fi
                elif [[ "$hostname" == "bitbucket.org" ]]; then
                    # Determinar o contexto (work, personal, etc.) do nome do host
                    local context=$(echo "$host" | sed -E 's/bitbucket\.org-?//')
                    if [ -n "$context" ]; then
                        print_info "Configuring Git for Bitbucket ($context)..."
                        
                        # Verificar se já existe uma configuração para este host
                        if ! grep -q "\[url \"git@$host:\"\]" "$GIT_CONFIG_FILE"; then
                            # Adicionar configuração para este host
                            cat >> "$GIT_CONFIG_FILE" << EOF

[url "git@$host:"]
    insteadOf = https://bitbucket.org/$context/
EOF
                            git_config_updated=true
                        else
                            print_info "Git configuration for $host already exists."
                        fi
                    fi
                fi
            fi
        fi
    done
    
    if [ "$git_config_updated" = true ]; then
        print_success "Git configuration updated successfully!"
    else
        print_info "No changes were made to Git configuration."
    fi
}

test_ssh_connections() {
    print_info "Testing SSH connections..."
    
    # Detectar hosts configurados
    local hosts=$(grep -E "^Host " "$SSH_CONFIG_FILE" | awk '{print $2}')
    
    for host in $hosts; do
        # Ignorar hosts com caracteres especiais como * ou ?
        if [[ "$host" != *"*"* && "$host" != *"?"* ]]; then
            # Extrair o hostname real
            local hostname=$(grep -A5 "^Host $host" "$SSH_CONFIG_FILE" | grep "HostName" | head -1 | awk '{print $2}')
            
            if [ -n "$hostname" ]; then
                print_info "Testing connection to $host ($hostname)..."
                
                # Tentar conexão SSH
                if [[ "$hostname" == "github.com" ]]; then
                    echo $host
                    ssh -T git@"$host" -o BatchMode=yes -o ConnectTimeout=5 2>&1 | grep -q "successfully authenticated"
                    if [ $? -eq 0 ]; then
                        print_success "Connection to $host successful!"
                    else
                        print_alert "Connection to $host failed. Please check your SSH keys and configuration."
                    fi
                elif [[ "$hostname" == "bitbucket.org" ]]; then
                    echo $hostname
                    ssh -T git@"$host" -o BatchMode=yes -o ConnectTimeout=5 2>&1 | grep -q "logged in as"
                    if [ $? -eq 0 ]; then
                        print_success "Connection to $host successful!"
                    else
                        print_alert "Connection to $host failed. Please check your SSH keys and configuration."
                    fi
                else
                    print_info "Skipping test for $host (unknown service)"
                fi
            fi
        fi
    done
}

display_config_content() {
    print_info "Configured SSH File Content:"
    cat "$SSH_CONFIG_FILE"
    
    if [ -f "$GIT_CONFIG_FILE" ]; then
        print_info "Configured Git File Content:"
        cat "$GIT_CONFIG_FILE"
    fi
}

main() {
    print_header "Starting SSH Configuration for Git Services"

    create_ssh_directory
    backup_existing_config
    check_ssh_keys
    
    files=($(list_assets_files))
    display_files_with_index "${files[@]}"
    selected_file=$(get_user_choice "${files[@]}")
    
    configure_ssh "$selected_file"
    configure_git
    display_config_content
    
    print
    test_ssh_connections
    print
    print_success "SSH and Git Configuration Completed Successfully!"
}

# Execute main function
main