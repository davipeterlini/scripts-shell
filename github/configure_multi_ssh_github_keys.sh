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

add_or_update_config() {
  local label="$1"
  local ssh_key_path="$HOME/.ssh/id_rsa_${label}"
  local ssh_config_path="$HOME/.ssh/config"

  print_info "Checking configuration for github.com-${label}..."
  if grep -q "Host github.com-${label}" "$ssh_config_path"; then
    print_alert "Configuration for github.com-${label} already exists."
    read -p "Do you want to overwrite it? (y/n): " overwrite
    if [[ $overwrite != "y" ]]; then
      print_info "Skipping configuration for github.com-${label}"
      return
    fi
    # Remove existing configuration
    sed -i.bak "/Host github.com-${label}/,/^$/d" "$ssh_config_path"
    print_info "Existing configuration removed."
  fi

  # Ensure there's exactly one blank line at the end of the file
  sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$ssh_config_path"
  echo "" >> "$ssh_config_path"

  print_info "Configuring SSH config file for label $label..."
  {
    echo "Host github.com-${label}"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $ssh_key_path"
  } >> "$ssh_config_path"

  print_success "Configuration for github.com-${label} added to SSH config file."
}

# Função para configurar o Git
configure_git() {
    local label=$1
    local email=$2
    local name=$3

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

    print_info "Please authenticate with GitHub CLI:"
    #echo "Generating GitHub token with repo and workflow permissions..."
    gh auth refresh -h github.com -s repo,workflow
    #gh auth login

    # TODO - testar para verificar se funciona o SSO
    # Check if SSO is available and configure it
    # if gh auth status | grep -q "SSO:"; then
    #     echo "SSO detected for this account. Configuring SSO..."
    #     gh auth refresh -h github.com -s admin:public_key
    #     echo "Please follow the prompts to authorize SSO for your organizations."
    #     gh auth status
    # else
    #     echo "No SSO detected for this account."
    # fi

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
            # TODO - precisa ter o gh auth logout
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