#!/bin/bash

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