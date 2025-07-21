#!/bin/bash

# Script to configure multiple SSH keys for GitHub accounts

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

# Function to generate an SSH key
generate_ssh_key() {
  local email="$1"
  local label="$2"
  local ssh_key_path="$HOME/.ssh/id_rsa_${label}"

  print_info "GitHub - Generating SSH key for $email with label $label..."
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

  print_info "Adding the SSH key to the agent..."
  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key_path"

  print_success "Generated public key:"
  cat "${ssh_key_path}.pub"
}

add_or_update_config() {
  local label="$1"
  local ssh_key_path="$HOME/.ssh/id_rsa_${label}"
  local ssh_config_path="$HOME/.ssh/config"
  local ssh_dir="$HOME/.ssh"

  # Check if .ssh directory exists, if not create it
  if [ ! -d "$ssh_dir" ]; then
    print_info "Creating .ssh directory..."
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
  fi

  # Check if config file exists, if not create it
  if [ ! -f "$ssh_config_path" ]; then
    print_info "SSH config file does not exist. Creating it..."
    touch "$ssh_config_path"
    chmod 600 "$ssh_config_path"
  fi

  print_info "Checking configuration for github.com-${label}..."
  if grep -q "Host github.com-${label}" "$ssh_config_path" 2>/dev/null; then
    print_alert "Configuration for github.com-${label} already exists."
    read -p "Do you want to overwrite it? (y/n): " overwrite
    if [[ $overwrite != "y" ]]; then
      print_info "Skipping configuration for github.com-${label}"
      return
    fi
    # Remove existing configuration
    sed -i.bak "/Host github.com-${label}/,/^$/d" "$ssh_config_path" 2>/dev/null
    print_info "Existing configuration removed."
  fi

  # Ensure there's exactly one blank line at the end of the file if the file is not empty
  if [ -s "$ssh_config_path" ]; then
    sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$ssh_config_path" 2>/dev/null
    echo "" >> "$ssh_config_path"
  fi

  print_info "Configuring SSH config file for label $label..."
  {
    echo "Host github.com-${label}"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $ssh_key_path"
    echo ""
  } >> "$ssh_config_path"

  print_success "Configuration for github.com-${label} added to SSH config file."
}

# Function to configure Git
configure_git() {
    local label=$1
    local email=$2
    local username=$3

    # Add the new method call here
    print_info "Associating generated SSH key with remote account"
    _handle_github_cli_auth
    _associate_ssh_key_with_github "$label"

    print_success "GitHub configuration completed for username: $username email: $email."
}

# Function to handle GitHub CLI authentication
_handle_github_cli_auth() {
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

# Function to associate SSH key with GitHub
_associate_ssh_key_with_github() {
    local label=$1
    local ssh_key_path="$HOME/.ssh/id_rsa_${label}"

    __ensure_gh_installed

    print_info "Associating SSH key with GitHub for $label..."
    
    # Alert the user to log in with the correct account
    print_alert "IMPORTANT: Please ensure you are logged into the correct GitHub account in your browser."
    print_info "The account should match the email and username you provided for $label."

    # if ! echo "$github_token" | gh auth login --with-token; then
    #     echo "Failed to authenticate with GitHub. Please check your token and try again."
    #     return 1
    # fi

    # # Verify the authenticated user
    # authenticated_user=$(gh api user --jq .login)
    # if [ "$authenticated_user" != "$github_account" ]; then
    #     print_error "Authenticated as $authenticated_user, but expected $github_account."
    #     gh auth logout
    # fi

    print_info "Please authenticate with GitHub CLI:"
    print_info "Generating GitHub token with repo and workflow permissions..."
    gh auth login -s repo,workflow

    # TODO - test to verify if SSO works
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

# Function to check if gh is installed and install it if not
__ensure_gh_installed() {
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

# Main function to configure multiple GitHub accounts
setup_github_accounts() {
  print_header "Setting up multiple GitHub accounts..."

  # Load environment variables
  load_env .env.personal
  load_env .env.work

  if ! get_user_confirmation "Do you want Setting up multiple GitHub accounts ?"; then
    print_info "Skipping configuration"
    return 0
  fi

  while true; do
    # Account
    read -p "Enter email for GitHub account: " email
    read -p "Enter label for GitHub account (e.g., work, personal, ...): " label
    read -p "Enter username for GitHub account (e.g., username): " username

    generate_ssh_key "$email" "$label"
    add_or_update_config "$label"
    configure_git "$label" "$email" "$username"

    print_success "Setup completed for $label. Please add the generated SSH keys to your GitHub account."

    # Ask if the user wants to configure another GitHub account
    read -p "Do you want to configure another GitHub account? (Y/N): " choice
    case "$choice" in
      [Yy]* ) continue ;;
      [Nn]* ) break ;;
          * ) echo -e "${RED}Please answer Y (yes) or N (no).${NC}" ;;
    esac
  done

  print_success "Multiple GitHub accounts configuration completed!"

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_github_accounts "$@"
fi