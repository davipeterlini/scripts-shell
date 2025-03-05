#!/bin/bash

# Script para configurar múltiplas chaves SSH para contas GitHub

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors message
source "$(dirname "$0")/../utils/colors_message.sh"

# Função para gerar uma chave SSH
generate_ssh_key() {
  local email="$1"
  local label="$2"
  local ssh_key_path="$HOME/.ssh/id_rsa_${label}"

  print_info "Gerando chave SSH para $email com o label $label..."
  # Gerar a chave SSH automaticamente sem prompts
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

  print_info "Adicionando a chave SSH ao agente..."
  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key_path"

  print_success "Chave pública gerada:"
  cat "${ssh_key_path}.pub"
}

# Função para configurar o arquivo SSH config
# TODO - Precisava verificar se a configuração já existe se sim não fazer novamente ou fazer por sima de uma existente
configure_ssh_config() {
  local label="$1"
  local ssh_key_path="$HOME/.ssh/id_rsa_${label}"
  local ssh_config_path="$HOME/.ssh/config"

  print_info "Configurando o arquivo SSH config para o label $label..."
  {
    echo ""
    echo "Host github.com-${label}"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $ssh_key_path"
  } >> "$ssh_config_path"

  print_info "Configuração para github-${label} adicionada ao arquivo SSH config."
}

# Function to add or update SSH configuration
add_or_update_config() {
    local host=$1
    local identity_file=$2
    local user=$3

    if check_config_exists "$host"; then
        echo "Configuration for $host already exists in ~/.ssh/config"
        read -p "Do you want to overwrite it? (y/n): " overwrite
        if [[ $overwrite != "y" ]]; then
            echo "Skipping configuration for $host"
            return
        fi
        # Remove existing configuration
        sed -i.bak "/Host $host/,/Host /d" ~/.ssh/config
    fi

    echo "Adding configuration for $host to ~/.ssh/config"
    cat << EOF >> ~/.ssh/config

Host $host
    HostName github.com
    User $user
    IdentityFile $identity_file
EOF
}

# Função para configurar o Git
configure_git() {
    local label=$1
    local email=$2
    local name=$3

    #print_info "Configurando o Git para o label $label..."
    git config --global user.name "$name"
    git config --global user.email "$email"

    # Add the new method call here
    print_info "Associando chave SSH gerada a conta remota"
    handle_github_cli_auth
    associate_ssh_key_with_github "$label"

    print_success "Configuração do Github concluída para username: $name email: $email."
}

# Function to check if gh is installed and install it if not
ensure_gh_installed() {
    if ! command -v gh &> /dev/null; then
        print_info "GitHub CLI (gh) is not installed. Installing..."
        if [[ "$(uname)" == "Darwin" ]]; then
            brew install gh
        elif [[ "$(uname)" == "Linux" ]]; then
            # For Ubuntu/Debian-based systems
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh
        else
            print_error "Unsupported operating system for automatic gh installation."
            print_info "Please install GitHub CLI (gh) manually and run this script again."
            exit 1
        fi
    fi
}

# New function to associate SSH key with GitHub

associate_ssh_key_with_github() {
    local label=$1
    local ssh_key_path="$HOME/.ssh/id_rsa_${label}"

    ensure_gh_installed

    echo "Associating SSH key with GitHub for $label..."
    
    # Alert the user to log in with the correct account
    print_alert "IMPORTANT: Please ensure you are logged into the correct GitHub account in your browser."
    print_info "The account should match the email and name you provided for $label."
    print_alert "Press Enter when you are ready to proceed."
    read -p ""

    # Check if the user is authenticated with gh
    if ! gh auth status &> /dev/null; then
        print_info "Please authenticate with GitHub CLI:"
        gh auth login
    fi

    # TODO - testar para verificar se funciona o SSO
    # Check if SSO is available and configure it
    if gh auth status | grep -q "SSO:"; then
        echo "SSO detected for this account. Configuring SSO..."
        gh auth refresh -h github.com -s admin:public_key
        echo "Please follow the prompts to authorize SSO for your organizations."
        gh auth status
    else
        echo "No SSO detected for this account."
    fi

    # Add the SSH key to GitHub
    gh ssh-key add "$ssh_key_path.pub" --title "SSH key for $label"

    if [ $? -eq 0 ]; then
        print_success "SSH key successfully associated with GitHub for $label."
    else
        print_error "Failed to associate SSH key with GitHub for $label."
    fi
}

# Function to handle GitHub CLI authentication
handle_github_cli_auth() {
    if [ -n "$GITHUB_TOKEN" ]; then
        print_info "GITHUB_TOKEN environment variable detected."
        print_info "To have GitHub CLI store credentials, you need to clear this variable."
        read -p "Do you want to clear GITHUB_TOKEN and let GitHub CLI handle authentication? (y/n): " clear_token
        if [ "$clear_token" = "y" ]; then
            unset GITHUB_TOKEN
            print_success "GITHUB_TOKEN has been cleared. GitHub CLI will now prompt for authentication."
        else
            print_info "GITHUB_TOKEN remains set. GitHub CLI will use this for authentication."
        fi
    else
        print_info "No GITHUB_TOKEN detected. GitHub CLI will handle authentication normally."
    fi
}


# Função principal para configurar múltiplas contas GitHub
setup_github_accounts() {
  print_info "Setting up multiple GitHub accounts..."

  while true; do
    # Account
    read -p "Enter email for GitHub account: " email
    read -p "Enter label for GitHub account (e.g., work, personal, ...): " label
    read -p "Enter username for GitHub account (e.g., username): " name

    generate_ssh_key "$email" "$label"
    #configure_ssh_config "$label"
    add_or_update_config "$label"
    configure_git "$label" "$email" "$name"

    print_success "Setup completed for $label. Please add the generated SSH keys to your GitHub account."

    # Perguntar se deseja configurar outra conta
    read -p "Deseja configurar mais uma conta GitHub? (Y/N): " choice
    case "$choice" in
      [Yy]* ) continue ;;
      [Nn]* ) break ;;
      * ) echo -e "${RED}Por favor, responda Y (sim) ou N (não).${NC}" ;;
    esac
  done

  print_success "Configuração de múltiplas contas GitHub concluída!"
}

# Executar a função principal
setup_github_accounts