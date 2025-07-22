#!/bin/bash

# Utils
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/utils/profile_writer.sh"

# Function to check if Java is installed and has the correct version
_check_java_version() {
  print_info "Checking Java version..."

  if ! command -v java &> /dev/null; then
    print_alert "Java is not installed."
    return 1
  fi

  java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  java_major_version=$(echo "$java_version" | awk -F '.' '{print $1}')

  # Check if java_major_version is a valid integer
  if [[ -z "$java_major_version" ]] || ! [[ "$java_major_version" =~ ^[0-9]+$ ]]; then
    print_alert "Could not determine Java version. Output: $java_version"
    return 1
  fi

  if [ "$java_major_version" -lt 17 ]; then
    print_alert "Java 17 or higher is required. Current version: $java_version"
    return 1
  fi

  print_success "Java version $java_version is compatible."
  return 0
}

# Function to check if SDKMAN is installed
_check_sdkman() {
  print_info "Checking for SDKMAN..."

  # Check if SDKMAN is available as a command
  if command -v sdk &> /dev/null; then
    print_success "SDKMAN is installed."
    return 0
  fi

  # Check if SDKMAN is available but needs to be loaded
  if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    print_success "SDKMAN is installed but needs to be loaded."
    # Source SDKMAN
    export SDKMAN_DIR="$HOME/.sdkman"
    [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && \. "$SDKMAN_DIR/bin/sdkman-init.sh"
    return 0
  fi

  print_alert "SDKMAN is not installed."
  return 1
}

# Function to install SDKMAN
_install_sdkman() {
  print_info "Installing SDKMAN..."

  # Install SDKMAN using the official install script
  curl -s "https://get.sdkman.io" | bash

  # Setup SDKMAN in the current shell
  export SDKMAN_DIR="$HOME/.sdkman"
  [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && \. "$SDKMAN_DIR/bin/sdkman-init.sh"

  # Verify installation
  if command -v sdk &> /dev/null; then
    print_success "SDKMAN installed successfully."
    
    # Add SDKMAN initialization to .zshrc using profile_writer
    _configure_sdkman_in_profile
    
    return 0
  else
    print_error "Failed to install SDKMAN."
    return 1
  fi
}

# Function to configure SDKMAN in profile (.zshrc)
_configure_sdkman_in_profile() {
  print_info "Configuring SDKMAN in shell profile..."
  
  # Define the SDKMAN initialization content
  local sdkman_init_content="export SDKMAN_DIR=\"\$HOME/.sdkman\"
[ -s \"\$SDKMAN_DIR/bin/sdkman-init.sh\" ] && source \"\$SDKMAN_DIR/bin/sdkman-init.sh\""

  # Write to profile using profile_writer
  write_lines_to_profile "$sdkman_init_content" "$HOME/.zshrc"
  
  print_success "SDKMAN configuration added to shell profile"
}

# Function to install Java using SDKMAN
_install_java_with_sdkman() {
  print_info "Installing Java 17.0.14-jbr using SDKMAN..."

  # Install the required Java version
  if sdk install java 17.0.14-jbr; then
    # Use the installed version
    sdk use java 17.0.14-jbr
    sdk default java 17.0.14-jbr
    print_success "Java 17.0.14-jbr installed and set as default."
    return 0
  else
    print_error "Failed to install Java 17.0.14-jbr using SDKMAN."
    return 1
  fi
}

setup_java() {
  print_header_info "Check Setup Java"

  if ! get_user_confirmation "Do you want Check Setup Java ?"; then
      print_info "Skipping configuration"
      return 0
  fi

  # Check if Java is already installed with correct version
  if _check_java_version; then
    print_success "Java is already installed with the required version."
    
    # Ensure SDKMAN is properly configured in profile even if Java is already installed
    if _check_sdkman; then
      _configure_sdkman_in_profile
    fi
    
    return 0
  fi

  # Use SDKMAN for Java installation
  if _check_sdkman || _install_sdkman; then
    _install_java_with_sdkman
    # Check if Java is now installed with correct version
    if _check_java_version; then
      return 0
    fi
  fi

  print_error "Failed to install Java. Please install Java 17 or higher manually."
  return 1
}

# Run the script only if not being imported
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_java "$@"
fi