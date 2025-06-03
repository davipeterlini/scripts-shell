#!/bin/bash

# Function to ask the user which shell they are using and set the profile file
choose_shell_profile() {
  print_header "Which shell are you using? (Enter the corresponding number)"
  print_info "1) bash"
  print_info "2) zsh"
  read -p "Choose an option (1 or 2): " shell_choice

  case $shell_choice in
    1)
      profile_file="$HOME/.bashrc"
      print_success "Profile file set to $profile_file"
      ;;
    2)
      profile_file="$HOME/.zshrc"
      print_success "Profile file set to $profile_file"
      ;;
    *)
      print_error "Invalid option. Exiting..."
      exit 1
      ;;
  esac

  export PROFILE_FILE="$profile_file"
}