#!/bin/bash

# Import color scheme and profile selection script
source ./utils/colors_message.sh
source ./utils/choose_shell_profile.sh

create_env_file() {
    local user_profile_dir="$HOME"
    local env_example_path="./dev/.env.example"
    local env_target_path="$user_profile_dir/.env"

    if [ -f "$env_example_path" ]; then
        cp "$env_example_path" "$env_target_path"
        echo -e "${GREEN}.env file created at $env_target_path${NC}"
    else
        echo -e "${RED}Error: $env_example_path does not exist.${NC}"
        exit 1
    fi
}

# Function to add the export line to the profile
add_export_to_profile() {
  local profile_path="$HOME/$1"
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

# Main script flow
main() {
    create_env_file

    local profile
    profile=$(get_user_profile_choice)
    add_export_to_profile "$profile"

    # Reload the profile to apply changes
    if [ -f "$HOME/$profile" ]; then
      echo -e "${YELLOW}Reloading the profile file $profile...${NC}"
      source "$HOME/$profile"
    else
      echo -e "${RED}Could not reload the profile file $profile because it does not exist.${NC}"
      exit 1
    fi

    print_env_variables
}

# Execute the script
main