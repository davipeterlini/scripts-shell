#!/bin/bash

# Script para configurar múltiplas chaves SSH para contas GitHub

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Cores para mensagens no terminal
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # Sem cor

# Função para exibir mensagens formatadas
# function print_message() {
#   echo -e "\n${YELLOW}========================================${NC}"
#   echo -e "${GREEN}$1${NC}"
#   echo -e "${YELLOW}========================================${NC}"
# }

# Função para exibir mensagens de sucesso
function print_success() {
  echo -e "\n${GREEN}$1${NC}"
}

# Função para exibir mensagens de erro
function print_alert() {
  echo -e "\n${YELLOW}$1${NC}"
}

# Função para exibir mensagens de erro
function print_error() {
  echo -e "${RED}Erro: $1${NC}"
}

# Função para gerar uma chave SSH
generate_ssh_key() {
  local email="$1"
  local label="$2"
  local ssh_key_path="$HOME/.ssh/id_rsa_${label}"

  print_alert "Gerando chave SSH para $email com o label $label..."
  # Gerar a chave SSH automaticamente sem prompts
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

  print_alert "Adicionando a chave SSH ao agente..."
  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key_path"

  print_alert "Chave pública gerada (adicione esta chave à sua conta GitHub):"
  cat "${ssh_key_path}.pub"
}

# Função para configurar o arquivo SSH config
configure_ssh_config() {
  local label="$1"
  local ssh_key_path="$HOME/.ssh/id_rsa_${label}"
  local ssh_config_path="$HOME/.ssh/config"

  print_alert "Configurando o arquivo SSH config para o label $label..."
  {
    echo ""
    echo "Host github.com-${label}"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $ssh_key_path"
  } >> "$ssh_config_path"

  print_alert "Configuração para github-${label} adicionada ao arquivo SSH config."
}

# Função para configurar o Git
configure_git() {
  local label=$1
  local email=$2
  local name=$3

  print_alert "Configurando o Git para o label $label..."
  git config --global user.name "$name"
  git config --global user.email "$email"

  print_alert "Configuração do Git concluída para username: $name email: $email."
    # Add the new method call here
    print_alert "Associar a chave SSH gerada a conta remota"
    associate_ssh_key_with_github "$label"
}

# Function to check if gh is installed and install it if not
ensure_gh_installed() {
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is not installed. Installing..."
        if [[ "$(uname)" == "Darwin" ]]; then
            brew install gh
        elif [[ "$(uname)" == "Linux" ]]; then
            # For Ubuntu/Debian-based systems
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh
        else
            echo "Unsupported operating system for automatic gh installation."
            echo "Please install GitHub CLI (gh) manually and run this script again."
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
    echo "IMPORTANT: Please ensure you are logged into the correct GitHub account in your browser."
    echo "The account should match the email and name you provided for $label."
    echo "Press Enter when you are ready to proceed."
    read -p ""

    # Check if the user is authenticated with gh
    if ! gh auth status &> /dev/null; then
        echo "Please authenticate with GitHub CLI:"
        gh auth login
    fi

    # Add the SSH key to GitHub
    gh ssh-key add "$ssh_key_path.pub" --title "SSH key for $label"

    if [ $? -eq 0 ]; then
        echo "SSH key successfully associated with GitHub for $label."
    else
        echo "Failed to associate SSH key with GitHub for $label."
    fi
}


# Função principal para configurar múltiplas contas GitHub
setup_github_accounts() {
  print_alert "Setting up multiple GitHub accounts..."

  while true; do
    # Account
    read -p "Enter email for GitHub account: " email
    read -p "Enter label for GitHub account (e.g., work, personal, ...): " label
    read -p "Enter username for GitHub account (e.g., username): " name

    generate_ssh_key "$email" "$label"
    configure_ssh_config "$label"
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