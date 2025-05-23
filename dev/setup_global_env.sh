#!/bin/bash

# Import color scheme and profile selection script
source ./utils/colors_message.sh
ENV_EXAMPLE="./dev/.env.example"

create_env_file() {
    local user_profile_dir="$HOME"
    local env_example_path="$ENV_EXAMPLE"
    local env_target_path="$user_profile_dir/.env"

    if [ -f "$env_example_path" ]; then
        cp "$env_example_path" "$env_target_path"
        echo -e "${GREEN}.env file created at $env_target_path${NC}"
    else
        echo -e "${RED}Error: $env_example_path does not exist.${NC}"
        exit 1
    fi
}

# Function to ask the user which shell they are using and set the profile file
choose_shell_profile() {
  echo "Which shell are you using? (Enter the corresponding number)"
  echo "1) bash"
  echo "2) zsh"
  read -p "Choose an option (1 or 2): " shell_choice

  case $shell_choice in
    1)
      profile_file="$HOME/.bashrc"
      ;;
    2)
      profile_file="$HOME/.zshrc"
      ;;
    *)
      echo "Invalid option. Exiting..."
      exit 1
      ;;
  esac

  echo "Profile file set to $profile_file"
  export PROFILE_FILE="$profile_file"
}

# Function to add the export line to the profile
add_export_to_profile() {
  local profile_path="$1"
  local export_line="export \$(grep -v '^#' ~/.env | xargs)"
  
  if [ -f "$profile_path" ]; then
    if ! grep -q "$export_line" "$profile_path"; then
      echo -e "${YELLOW}Adding export line to $1...${NC}"
      echo "$export_line" >> "$profile_path"
    else
      echo -e "${GREEN}The export line already exists in $1.${NC}"
    fi
  else
    echo -e "${RED}The file $1 does not exist. Make sure the correct shell is configured.${NC}"
    exit 1
  fi
}

# Function to print the saved variables in the terminal
print_env_variables() {
  echo -e "${BLUE}Variables saved in the .env file:${NC}"
  cat "$HOME/.env"
}

# Function to update a specific key in the .env file (macOS compatible)
update_env_key() {
  local env_file="$1"
  local key="$2"
  local value="$3"
  
  # Create a temporary file
  local temp_file=$(mktemp)
  
  # Replace the line containing the key with the new key=value pair
  while IFS= read -r line; do
    if [[ "$line" =~ ^"$key"= ]]; then
      echo "$key=$value" >> "$temp_file"
    else
      echo "$line" >> "$temp_file"
    fi
  done < "$env_file"
  
  # Replace the original file with the temporary file
  mv "$temp_file" "$env_file"
}

# Function to setup secrets in the .env file - asking for each one by one
setup_secrets() {
  local env_file="$HOME/.env"
  local secrets_added=()
  
  # Check if .env file exists
  if [ ! -f "$env_file" ]; then
    echo -e "${RED}Error: $env_file does not exist.${NC}"
    return 1
  fi
  
  # Ask user if they want to set secrets
  read -p "Do you want to set up secrets in your .env file? (y/n): " setup_choice
  
  if [[ "$setup_choice" != "y" && "$setup_choice" != "Y" ]]; then
    echo -e "${YELLOW}Skipping secrets setup.${NC}"
    return 0
  fi
  
  echo -e "${GREEN}Let's set up your secrets one by one:${NC}"
  
  # Read the .env file and process each line
  while IFS= read -r line; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^#.*$ || -z "$line" ]]; then
      # Print the comment line to show what section we're in
      if [[ "$line" =~ ^#.*$ ]]; then
        echo -e "${BLUE}$line${NC}"
      fi
      continue
    fi
    
    # Extract the key name
    key=$(echo "$line" | cut -d'=' -f1)
    
    # Ask user for the value with a clear prompt
    read -p "Enter value for $key (press Enter to skip): " value
    
    # If a value was provided, immediately update the .env file
    if [ ! -z "$value" ]; then
      update_env_key "$env_file" "$key" "$value"
      secrets_added+=("$key")
      echo -e "${GREEN}Added $key to .env file${NC}"
    else
      echo -e "${YELLOW}Skipped $key${NC}"
    fi
    
    # Add a blank line for readability between variables
    echo ""
    
  done < "$env_file"
  
  # Print summary of all the secrets that were added
  if [ ${#secrets_added[@]} -gt 0 ]; then
    echo -e "${GREEN}Summary of secrets added to .env file:${NC}"
    for secret in "${secrets_added[@]}"; do
      echo "- $secret"
    done
  else
    echo -e "${YELLOW}No secrets were added to .env file.${NC}"
  fi
}

# Function to reload the profile
reload_profile() {
  local profile="$1"
  
  if [ -f "$profile" ]; then
    echo -e "${YELLOW}Reloading the profile file $(basename $profile)...${NC}"
    source "$profile"
  else
    echo -e "${RED}Could not reload the profile file $(basename $profile) because it does not exist.${NC}"
    exit 1
  fi
}

# Main script flow
main() {
    create_env_file
    choose_shell_profile
    add_export_to_profile "$PROFILE_FILE"
    
    # Setup secrets
    setup_secrets
    
    # Reload the profile to apply changes
    reload_profile "$PROFILE_FILE"
    
    # Print all environment variables
    print_env_variables
}

# Execute the script
main