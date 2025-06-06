#!/bin/bash

# Script to configure multiple SSH keys for Bitbucket accounts

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors message
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to generate an SSH key
generate_ssh_key() {
  local email="$1"
  local label="$2"
  local ssh_key_path="$HOME/.ssh/id_rsa_bb_${label}"

  print_info "Generating SSH key for $email with label $label..."
  # Generate the SSH key automatically without prompts
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

  print_info "Adding the SSH key to the agent..."
  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key_path"

  print_success "Generated public key:"
  cat "${ssh_key_path}.pub"
}

add_or_update_config() {
  local label="$1"
  local ssh_key_path="$HOME/.ssh/id_rsa_bb_${label}"
  local ssh_config_path="$HOME/.ssh/config"

  # Create SSH config file if it doesn't exist
  if [ ! -f "$ssh_config_path" ]; then
    print_info "Creating SSH config file..."
    touch "$ssh_config_path"
    chmod 600 "$ssh_config_path"
  fi

  print_info "Checking configuration for bitbucket.org-${label}..."
  if grep -q "Host bitbucket.org-${label}" "$ssh_config_path"; then
    print_alert "Configuration for bitbucket.org-${label} already exists."
    read -p "Do you want to overwrite it? (y/n): " overwrite
    if [[ $overwrite != "y" ]]; then
      print_info "Skipping configuration for bitbucket.org-${label}"
      return
    fi
    # Remove existing configuration
    sed -i.bak "/Host bitbucket.org-${label}/,/^$/d" "$ssh_config_path"
    print_info "Existing configuration removed."
  fi

  # Ensure there's exactly one blank line at the end of the file
  sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$ssh_config_path"
  echo "" >> "$ssh_config_path"

  print_info "Configuring SSH config file for label $label..."
  {
    echo "Host bitbucket.org-${label}"
    echo "  HostName bitbucket.org"
    echo "  User git"
    echo "  IdentityFile $ssh_key_path"
  } >> "$ssh_config_path"

  print_success "Configuration for bitbucket.org-${label} added to SSH config file."
}

# Function to configure Git
configure_git() {
    local label=$1
    local email=$2
    local username=$3

    # Add the new method call here
    print_info "Associating generated SSH key with remote account"
    handle_bitbucket_auth
    associate_ssh_key_with_bitbucket "$label" "$username"

    print_success "Bitbucket configuration completed for username: $username email: $email."
}

# Function to check if curl is installed
ensure_curl_installed() {
    if ! command -v curl &> /dev/null; then
        print_info "curl is not installed. Installing..."
        if [[ "$(uname)" == "Darwin" ]]; then
            brew install curl
        elif [[ "$(uname)" == "Linux" ]]; then
            sudo apt update
            sudo apt install -y curl
        else
            print_error "Unsupported operating system for automatic curl installation."
            print_info "Please install curl manually and run this script again."
            exit 1
        fi
    fi
}

# Function to check if jq is installed
ensure_jq_installed() {
    if ! command -v jq &> /dev/null; then
        print_info "jq is not installed. Installing..."
        if [[ "$(uname)" == "Darwin" ]]; then
            brew install jq
        elif [[ "$(uname)" == "Linux" ]]; then
            sudo apt update
            sudo apt install -y jq
        else
            print_error "Unsupported operating system for automatic jq installation."
            print_info "Please install jq manually and run this script again."
            exit 1
        fi
    fi
}

# Function to check if browser opener is available
check_open_command() {
    if [[ "$(uname)" == "Darwin" ]]; then
        if ! command -v open &> /dev/null; then
            print_error "The 'open' command is not available on your system."
            return 1
        fi
        echo "open"
    elif [[ "$(uname)" == "Linux" ]]; then
        if command -v xdg-open &> /dev/null; then
            echo "xdg-open"
        elif command -v gnome-open &> /dev/null; then
            echo "gnome-open"
        else
            print_error "No suitable command to open URLs found on your system."
            print_info "Please install xdg-open or manually open the URL in your browser."
            return 1
        fi
    else
        print_error "Unsupported operating system."
        return 1
    fi
}

# Function to generate a random port number between 8000 and 9000
generate_random_port() {
    echo $(( RANDOM % 1000 + 8000 ))
}

# Function to start a temporary web server to receive OAuth callback
start_oauth_server() {
    local port=$1
    local token_file=$2
    
    # Create a temporary Python script for the server
    local server_script=$(mktemp)
    cat > "$server_script" << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import urllib.parse
import json
import sys
import os

PORT = int(sys.argv[1])
TOKEN_FILE = sys.argv[2]

class OAuthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        query = urllib.parse.urlparse(self.path).query
        params = dict(urllib.parse.parse_qsl(query))
        
        if 'code' in params:
            with open(TOKEN_FILE, 'w') as f:
                f.write(params['code'])
            
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b"""
            <html>
            <head><title>Authentication Successful</title></head>
            <body>
            <h1>Authentication Successful!</h1>
            <p>You have successfully authenticated with Bitbucket. You can close this window and return to the terminal.</p>
            <script>window.close();</script>
            </body>
            </html>
            """)
            print("Authentication code received. You can close this window.")
            # Shutdown the server after handling the request
            socketserver.TCPServer.shutdown(self.server)
        else:
            self.send_response(400)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b"Error: No authentication code received")

with socketserver.TCPServer(("", PORT), OAuthHandler) as httpd:
    print(f"Server started at port {PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()
EOF

    # Make the script executable
    chmod +x "$server_script"
    
    # Start the server in the background
    python3 "$server_script" "$port" "$token_file" &
    
    # Store the server PID
    echo $!
}

# Function to associate SSH key with Bitbucket using OAuth
associate_ssh_key_with_bitbucket() {
    local label=$1
    local username=$2
    local ssh_key_path="$HOME/.ssh/id_rsa_bb_${label}"

    ensure_curl_installed
    ensure_jq_installed

    print_info "Associating SSH key with Bitbucket for $label..."
    
    local app_password="${BITBUCKET_APP_PASSWORD:-APP_PASSWORD}"  # Load from environment or use placeholder

    # Ask for OAuth credentials if not provided
    if [[ "$app_password" == "APP_PASSWORD" ]]; then
        print_alert "You need to create a Bitbucket OAuth consumer to proceed."
        print_info "1. Go to Bitbucket > Your workspace > Settings > OAuth consumers"
        print_info "2. Click 'Add consumer' and fill in the details:"
        print "   - Name: SSH Key Manager"
        print "   - Permissions: Account (Read, Write)\n"
        
        # Get the appropriate open command for the OS
        local open_cmd=$(check_open_command)
        if [ $? -eq 0 ]; then
            read -p "Press Enter to open Bitbucket OAuth settings in your browser... "
            $open_cmd "https://bitbucket.org/account/settings/app-passwords/" &> /dev/null
        else
            print_info "Please manually open: https://bitbucket.org/account/settings/app-passwords/"
        fi
        
        print_info "Create an App Password with 'Account: Write' permission."
        read -s -p "Enter your Bitbucket App Password: " app_password
        echo

        # Write the app password to .env.local, overwriting if it exists
        local env_file="$(dirname "$0")/../.env.local"
        if grep -q "^BITBUCKET_APP_PASSWORD=" "$env_file"; then
            sed -i.bak "/^BITBUCKET_APP_PASSWORD=/d" "$env_file"
        fi
        echo "BITBUCKET_APP_PASSWORD=$app_password" >> "$env_file"
        print_success "App password saved to .env.local."
    fi
    
    # Alternative approach using App Password
    print_info "We'll use a Bitbucket App Password to add your SSH key."
    
    # Read the public key content
    local key_content=$(cat "${ssh_key_path}.pub")
    
    # Create a JSON payload for the API request
    local temp_file=$(mktemp)
    cat > "$temp_file" << EOF
{
    "key": "$(echo "$key_content" | tr -d '\n')",
    "label": "SSH key for ${label}"
}
EOF
    
    # Add the SSH key to Bitbucket using the REST API
    print_info "Adding SSH key to Bitbucket..."
    local response=$(curl -s -u "${username}:${app_password}" \
         -X POST \
         -H "Content-Type: application/json" \
         -d @"$temp_file" \
         https://api.bitbucket.org/2.0/users/${username}/ssh-keys)
    
    # Clean up the temporary file
    rm "$temp_file"
    
    # Check if the key was added successfully
    if echo "$response" | grep -q "\"uuid\""; then
        print_success "SSH key successfully added to your Bitbucket account!"
        
        # Extract and display the key UUID
        local key_uuid=$(echo "$response" | grep -o '"uuid": *"[^"]*"' | cut -d'"' -f4)
        print_info "Key UUID: $key_uuid"
        
        # Test the SSH connection
        print_info "Testing SSH connection to Bitbucket..."
        ssh -T -o StrictHostKeyChecking=no git@bitbucket.org-${label} || true
        
        print_info "If you see a message like 'logged in as [username]', the SSH key is working correctly."
    else
        print_error "Failed to add SSH key to Bitbucket."
        print_error "API Response: $response"
        
        # Provide alternative manual instructions
        print_alert "You may need to add the SSH key manually to your Bitbucket account."
        print_info "1. Copy your public key:"
        echo "$key_content"
        print_info "2. Go to Bitbucket settings: https://bitbucket.org/account/settings/ssh-keys/"
        print_info "3. Click 'Add key' and paste your public key"
        
        # Open the SSH keys page in the browser
        if [ $? -eq 0 ]; then
            read -p "Press Enter to open Bitbucket SSH keys page in your browser... "
            $open_cmd "https://bitbucket.org/account/settings/ssh-keys/" &> /dev/null
        fi
    fi
}

# Function to handle Bitbucket authentication
handle_bitbucket_auth() {
    if [ -n "$BITBUCKET_APP_PASSWORD" ]; then
        print_info "BITBUCKET_APP_PASSWORD environment variable detected."
        print_info "BITBUCKET_APP_PASSWORD=$BITBUCKET_APP_PASSWORD"
        read -p "\nDo you want to clear BITBUCKET_APP_PASSWORD and enter credentials manually? (y/n): " clear_token
        if [ "$clear_token" = "y" ]; then
            unset BITBUCKET_APP_PASSWORD
            print_success "BITBUCKET_APP_PASSWORD has been cleared. You will be prompted for credentials."
        else
            print_info "BITBUCKET_APP_PASSWORD remains set. This will be used for authentication."
        fi
    else
        print_info "No BITBUCKET_APP_PASSWORD detected. You will be prompted for credentials."
    fi
}

# Main function to configure multiple Bitbucket accounts
setup_bitbucket_accounts() {
  print_info "Setting up multiple Bitbucket accounts..."

  while true; do
    # Account
    read -p "Enter email for Bitbucket account: " email
    read -p "Enter label for Bitbucket account (e.g., work, personal, ...): " label
    read -p "Enter username for Bitbucket account (e.g., username): " username

    generate_ssh_key "$email" "$label"
    add_or_update_config "$label"
    configure_git "$label" "$email" "$username"

    print_success "Setup completed for $label. Please verify the SSH key was added to your Bitbucket account."

    # Ask if the user wants to configure another Bitbucket account
    read -p "Do you want to configure another Bitbucket account? (Y/N): " choice
    case "$choice" in
      [Yy]* ) continue ;;
      [Nn]* ) break ;;
          * ) echo -e "${RED}Please answer Y (yes) or N (no).${NC}" ;;
    esac
  done

  print_success "Multiple Bitbucket accounts configuration completed!"
}

# Execute the main function
setup_bitbucket_accounts