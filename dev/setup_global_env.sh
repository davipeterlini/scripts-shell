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

# Main script flow
main() {
    create_env_file
    choose_shell_profile
    add_export_to_profile "$PROFILE_FILE"

    # TODO - leve a parte abaixo para uma função separada da main e imprima todas as variáveis do arquivo .env criado
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