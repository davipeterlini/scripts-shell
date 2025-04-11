#!/bin/bash

# Colors for terminal output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Function to display colored messages
print_message() {
    echo -e "${BLUE}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Ask user which shell they're using
print_message "Which shell are you using?"
echo "1) bash"
echo "2) zsh"
read -p "Choose an option (1 or 2): " shell_choice

# Set profile file based on user choice
case $shell_choice in
    1)
        profile_file="$HOME/.bashrc"
        ;;
    2)
        profile_file="$HOME/.zshrc"
        ;;
    *)
        print_error "Invalid option. Exiting..."
        exit 1
        ;;
esac

# Check if BITBUCKET_TOKEN is already set
if [ -n "$BITBUCKET_TOKEN" ]; then
    print_warning "BITBUCKET_TOKEN is already set. Would you like to remove it?"
    read -p "Remove token? (y/n): " remove_token
    if [ "$remove_token" = "y" ]; then
        unset BITBUCKET_TOKEN
        sed -i.bak '/export BITBUCKET_TOKEN/d' "$profile_file"
        print_success "BITBUCKET_TOKEN removed from session and $profile_file"
    fi
fi

# Instructions for creating an App Password
print_message "Please follow these steps to create a new Bitbucket App Password:"
echo "1. Go to Bitbucket settings: https://bitbucket.org/account/settings/app-passwords/"
echo "2. Click 'Create app password'"
echo "3. Give it a name (e.g., 'Local Development')"
echo "4. Select the following permissions:"
echo "   - Repository: Read, Write"
echo "   - Pull requests: Read, Write"
echo "   - Pipeline: Read, Write"
echo "   - Project: Read"
echo "5. Click 'Create'"

# Get username and new app password
read -p "Enter your Bitbucket username: " BB_USERNAME
read -s -p "Enter your new App Password: " APP_PASSWORD
echo

# Validate the app password
print_message "Validating App Password..."
response=$(curl -s -u "${BB_USERNAME}:${APP_PASSWORD}" \
     https://api.bitbucket.org/2.0/user)

if echo "$response" | grep -q "\"username\":\"${BB_USERNAME}\""; then
    print_success "App Password validated successfully!"

    # Store the app password
    echo "export BITBUCKET_TOKEN=$APP_PASSWORD" >> "$profile_file"
    source "$profile_file"
    
    print_success "App Password has been stored in $profile_file"
    echo "You can now use BITBUCKET_TOKEN in your scripts and commands"
    echo "Current value: $BITBUCKET_TOKEN"
else
    print_error "Failed to validate App Password. Please check your credentials and try again."
    exit 1
fi

# Add label to the token (work/personal)
print_message "Would you like to add a label to this token? (work/personal)"
read -p "Enter label (work/personal): " TOKEN_LABEL

if [ -n "$TOKEN_LABEL" ]; then
    # Remove old token if exists
    sed -i.bak "/export BITBUCKET_TOKEN_${TOKEN_LABEL^^}/d" "$profile_file"
    # Add new labeled token
    echo "export BITBUCKET_TOKEN_${TOKEN_LABEL^^}=$APP_PASSWORD" >> "$profile_file"
    print_success "Token stored as BITBUCKET_TOKEN_${TOKEN_LABEL^^}"
fi

print_success "Bitbucket App Password configuration completed!"
echo "You can manage your app passwords at: https://bitbucket.org/account/settings/app-passwords/"