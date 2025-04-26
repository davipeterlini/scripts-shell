#!/bin/bash

# Load environment variables
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Define the path where the interceptor script is located
INTERCEPTOR_PATH="$(dirname "$0")/git_push_interceptor.sh"

# Make the script executable
chmod +x "$INTERCEPTOR_PATH"

# Add the Git alias
git config --global alias.push "!$INTERCEPTOR_PATH"

# Prompt for GitHub usernames and SSH key paths
read -p "Enter your personal GitHub username: " personal_username
read -p "Enter your work GitHub username: " work_username
read -p "Enter the path to your personal SSH key: " personal_ssh_key
read -p "Enter the path to your work SSH key: " work_ssh_key

# Update .env.local with the new variables
echo "PERSONAL_GITHUB_USERNAME=$personal_username" >> "$ENV_LOCAL_FILE"
echo "WORK_GITHUB_USERNAME=$work_username" >> "$ENV_LOCAL_FILE"
echo "SSH_KEY_PERSONAL=$personal_ssh_key" >> "$ENV_LOCAL_FILE"
echo "SSH_KEY_WORK=$work_ssh_key" >> "$ENV_LOCAL_FILE"

echo "Git Push Interceptor has been set up successfully!"
echo "The interceptor script is located at: $INTERCEPTOR_PATH"
echo "A Git alias 'push' has been created to use the interceptor."
echo "Your GitHub usernames and SSH key paths have been added to $ENV_LOCAL_FILE"