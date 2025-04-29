#!/bin/bash

# Load environment variables and utility functions
source "$(dirname "$0")/../utils/load_env.sh"
load_env

# Function to list SSH keys and allow user to choose one
# TODO - Arrumar método
choose_ssh_key() {
  local ssh_dir="$HOME/.ssh"
  local ssh_keys=("$ssh_dir"/*)
  
  #echo "Available SSH keys in $ssh_dir:"
  select ssh_key in "${ssh_keys[@]}"; do
    if [[ -n "$ssh_key" ]]; then
      #echo "You selected: $ssh_key"
      echo "$ssh_key"
      return
    else
      echo "Invalid selection. Please try again."
    fi
  done
}


# Define the path where the interceptor script will be placed
INTERCEPTOR_PATH="$HOME/git_push_interceptor.sh"

ENV_GIT_PATH="$HOME/.env.git.local"

# Copy the interceptor script to the defined path
cp "$(dirname "$0")/git_push_interceptor.sh" "$INTERCEPTOR_PATH"

cp "$ENV_LOCAL_FILE" "$ENV_GIT_PATH"

# Make the script executable
chmod +x "$INTERCEPTOR_PATH"

# Add the Git alias
git config --global alias.push "!$INTERCEPTOR_PATH"

# Prompt for GitHub usernames and SSH key paths
read -p "Enter your personal GitHub username: " personal_username
read -p "Enter your work GitHub username: " work_username
# Prompt user to select personal SSH key
echo "Select your personal SSH key:"
personal_github_ssh_key=$(choose_ssh_key)

# Prompt user to select work SSH key
echo "Select your work SSH key:"
work_github_ssh_key=$(choose_ssh_key)

# Update .env.local with the new variables
# Update .env.local with the new variables
update_env_variable() {
  local key=$1
  local value=$2
  if grep -q "^${key}=" "$ENV_LOCAL_FILE"; then
    sed -i "s/^${key}=.*/${key}=${value}/" "$ENV_LOCAL_FILE"
  else
    echo "" >> "$ENV_LOCAL_FILE"
    echo "${key}=${value}" >> "$ENV_LOCAL_FILE"
  fi
}

update_env_variable "PERSONAL_GITHUB_USERNAME" "$personal_username"
update_env_variable "WORK_GITHUB_USERNAME" "$work_username"
update_env_variable "PERSONAL_GITHUB_SSH_KEY" "$personal_github_ssh_key"
update_env_variable "WORK_GITHUB_SSH_KEY" "$work_github_ssh_key"
# echo "" >> "$ENV_LOCAL_FILE"
#       echo "PERSONAL_GITHUB_USERNAME=$personal_username" >> "$ENV_LOCAL_FILE"
# echo "WORK_GITHUB_USERNAME=$work_username" >> "$ENV_LOCAL_FILE"
# echo "PERSONAL_GITHUB_SSH_KEY=$personal_github_ssh_key" >> "$ENV_LOCAL_FILE"
# echo "WORK_GITHUB_SSH_KEY=$work_github_ssh_key" >> "$ENV_LOCAL_FILE"

echo "Git Push Interceptor has been set up successfully!"
echo "The interceptor script is located at: $INTERCEPTOR_PATH"
echo "A Git alias 'push' has been created to use the interceptor."
echo "Your GitHub usernames and SSH key paths have been added to $ENV_LOCAL_FILE"