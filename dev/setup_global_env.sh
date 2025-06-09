#!/bin/bash

# Import color scheme and profile selection script
source ./utils/colors_message.sh
source ./utils/choose_shell_profile.sh
ENV_EXAMPLE="./dev/.env.example"
ENV_DIR="$HOME/.coder-ide"

create_env_file() {
    local env_example_path="$ENV_EXAMPLE"
    local env_target_path="$ENV_DIR/.env"

    if [ -f "$env_example_path" ]; then
        cp "$env_example_path" "$env_target_path"
        print_success ".env file created at $env_target_path"
    else
        print_error "$env_example_path does not exist."
        exit 1
    fi
}

# Function to add the export line to the profile
add_export_to_profile() {
  local profile_path="$1"
  local export_line="export \$(grep -v '^#' ~/.env | xargs)"
  
  if [ -f "$profile_path" ]; then
    if ! grep -q "$export_line" "$profile_path"; then
      print_alert "Adding export line to $1..."
      echo "$export_line" >> "$profile_path"
    else
      print_success "The export line already exists in $1."
    fi
  else
    print_error "The file $1 does not exist. Make sure the correct shell is configured."
    exit 1
  fi
}

# Function to print the saved variables in the terminal
print_env_variables() {
  print_info "Variables saved in the .env file:"
  print "$(cat "$HOME/.env")"
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

# Function to setup variables in the .env file - properly waiting for each input
setup_variables() {
  local env_file="$HOME/.env"
  local variables_updated=0
  local keys=()
  
  # Check if .env file exists
  if [ ! -f "$env_file" ]; then
    print_error "$env_file does not exist."
    return 1
  fi
  
  print_header "Setting up environment variables"
  
  # First, collect all the variable keys from the .env file
  while IFS= read -r line; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^#.*$ || -z "$line" ]]; then
      continue
    fi
    
    # Extract the key name
    key=$(echo "$line" | cut -d'=' -f1)
    keys+=("$key")
  done < "$env_file"
  
  # Now process each key one by one, waiting for user input after each
  for key in "${keys[@]}"; do
    # Clear prompt for each variable
    printf "Put the value %s: " "$key"
    
    # Using read -r to preserve backslashes in input
    read -r value
    
    # If a value was provided, update the .env file
    if [ ! -z "$value" ]; then
      update_env_key "$env_file" "$key" "$value"
      ((variables_updated++))
    fi
  done
  
  # Simple completion message
  print_success "Updated $variables_updated environment variables."
}

# Function to reload the profile
reload_profile() {
  local profile="$1"
  
  if [ -f "$profile" ]; then
    print_alert "Reloading the profile file $(basename $profile)..."
    source "$profile"
  else
    print_error "Could not reload the profile file $(basename $profile) because it does not exist."
    exit 1
  fi
}

# Main script flow
setup_global_env() {
    print_header "Setting up global environment"
    
    create_env_file
    
    # Use the external choose_shell_profile script instead of the internal function
    choose_shell_profile
    
    add_export_to_profile "$PROFILE_FILE"
    
    # Setup variables - will prompt for each variable one by one with proper waiting
    setup_variables
    
    # Reload the profile to apply changes
    reload_profile "$PROFILE_FILE"
    
    # Print all environment variables
    print_env_variables
    
    print_success "Global environment setup completed!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_global_env "$@"
fi