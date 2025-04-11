#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Load colors message
source "$(dirname "$0")/../utils/colors_message.sh"

# Function to generate Bitbucket App Password
generate_bitbucket_app_password() {
    print_info "Generating Bitbucket App Password..."

    print_alert "Please note that Bitbucket uses App Passwords instead of Personal Access Tokens."
    print_info "Follow these steps to create an App Password:"
    echo "1. Log in to your Bitbucket account"
    echo "2. Go to Bitbucket settings -> App passwords"
    echo "3. Click 'Create app password'"
    echo "4. Give your app password a name and select the required permissions"
    echo "5. Click 'Create' and copy the generated app password"

    read -p "Have you created and copied your Bitbucket App Password? (y/n): " confirm

    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        read -s -p "Enter your Bitbucket App Password: " app_password
        echo

        # Save the app password to a file (consider using a more secure method in production)
        echo "$app_password" > ~/.bitbucket_app_password

        print_success "Bitbucket App Password saved successfully."
        print_info "You can find your App Password in ~/.bitbucket_app_password"
    else
        print_error "Bitbucket App Password generation cancelled."
    fi
}

# Execute the function
generate_bitbucket_app_password