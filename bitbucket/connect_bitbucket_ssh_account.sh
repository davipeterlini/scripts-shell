#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Load environment variables from .env file
source "$SCRIPT_DIR/../utils/load_env.sh"
load_env

# Load the list_projects function from the new script
source "$SCRIPT_DIR/../utils/list_projects.sh"

# Function to prompt user to choose an identity
choose_identity() {
  list_projects
  echo
  read -p "Please choose an identity by number: " IDENTITY_NUMBER

  local index=1
  for identity in $(env | grep '^PROJECT_DIR_' | sed 's/^PROJECT_DIR_//' | sed 's/=.*//'); do
    if [ "$index" -eq "$IDENTITY_NUMBER" ]; then
      IDENTITY=$(echo $identity | tr '[:upper:]' '[:lower:]')
      break
    fi
    index=$((index + 1))
  done

  if [ -z "$IDENTITY" ]; then
    echo "Invalid choice. Exiting..."
    exit 1
  fi
}

# Function to interact with Bitbucket API
manage_ssh_key() {
  local ssh_key_title=$1
  local public_key=$2

  # Check if the key already exists
  existing_key_id=$(curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
    https://api.bitbucket.org/2.0/user/ssh-keys | jq -r \
    ".values[] | select(.label == \"$ssh_key_title\") | .uuid")

  if [ -n "$existing_key_id" ]; then
    echo "SSH key with title '$ssh_key_title' already exists."
    read -p "Do you want to delete the existing key? (y/n): " DELETE_KEY
    if [[ "$DELETE_KEY" =~ ^[Yy]$ ]]; then
      curl -X DELETE -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
        https://api.bitbucket.org/2.0/user/ssh-keys/$existing_key_id
      echo "Existing key deleted."
    else
      echo "Operation cancelled. Exiting..."
      exit 0
    fi
  fi

  # Add the new SSH key
  response=$(curl -s -X POST -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
    -H "Content-Type: application/json" \
    -d "{\"key\": \"$public_key\", \"label\": \"$ssh_key_title\"}" \
    https://api.bitbucket.org/2.0/user/ssh-keys)

  if echo "$response" | grep -q 'error'; then
    echo "Failed to add SSH key: $(echo "$response" | jq -r '.error.message')"
    exit 1
  else
    echo "SSH key added successfully."
  fi
}

# Function to add identity
add_identity() {
  local identity=$1
  local identity_upper=$(echo "$identity" | tr '[:lower:]' '[:upper:]')
  local project_dir_var="PROJECT_DIR_${identity_upper}"

  local ssh_key="$HOME/.ssh/id_rsa_bb_$identity"
  local ssh_key_pub="$ssh_key.pub"
  local project_dir=$(eval echo \$$project_dir_var)

  if [ -z "$project_dir" ]; then
    echo "Project directory for $identity is not set. Exiting..."
    exit 1
  fi

  if [ ! -f "$ssh_key" ] || [ ! -f "$ssh_key_pub" ]; then
    echo "SSH key files $ssh_key or $ssh_key_pub do not exist. Exiting..."
    exit 1
  fi

  cd "$project_dir" || exit

  # Add the SSH key to Bitbucket
  manage_ssh_key "$identity" "$(cat $ssh_key_pub)"

  echo "Adding $identity identity"
  ssh-add "$ssh_key"
  echo "Check the $identity key stay in ssh-agent"
  ssh-add -l
  echo "Test Connection"
  ssh -T git@bitbucket.org
}

# Load environment variables
load_env

# Check if an identity is provided as an argument
if [ "$#" -eq 1 ]; then
  IDENTITY=$1
else
  choose_identity
fi

# Convert identity to uppercase for variable lookup
IDENTITY_UPPER=$(echo "$IDENTITY" | tr '[:lower:]' '[:upper:]')

# Check if the specified identity is valid
if ! env | grep -q "^PROJECT_DIR_${IDENTITY_UPPER}="; then
  echo "Invalid identity specified. Use one of the following:"
  list_projects
  exit 1
fi

# Add the specified identity
add_identity "$IDENTITY"