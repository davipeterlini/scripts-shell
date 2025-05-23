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

# Function to add identity
add_identity() {
  local identity=$1
  local identity_upper=$(echo "$identity" | tr '[:lower:]' '[:upper:]')
  local project_dir_var="PROJECT_DIR_${identity_upper}"

  local ssh_key="$HOME/.ssh/id_rsa_bb_$identity"
  local project_dir=$(eval echo \$$project_dir_var)

  if [ -z "$project_dir" ]; then
    echo "Project directory for $identity is not set. Exiting..."
    exit 1
  fi

  if [ ! -f "$ssh_key" ]; then
    echo "SSH key file $ssh_key does not exist. Exiting..."
    exit 1
  fi

  cd "$project_dir" || exit

  # Ask the user if they want to remove the current identity
  while true; do
    read -p "Do you want to remove the current identity? (y/n): " REMOVE_IDENTITY
    case $REMOVE_IDENTITY in
      [Yy]* )
        ssh-add -D
        echo "Current identity removed."
        break
        ;;
      [Nn]* )
        echo "Adding new identity without removing the current one."
        break
        ;;
      * )
        echo "Please answer y or n."
        ;;
    esac
  done

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