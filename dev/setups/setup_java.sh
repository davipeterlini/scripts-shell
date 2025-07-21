#!/bin/bash

source "$(dirname "$0")/../../utils/colors_message.sh"
source "$(dirname "$0")/../../utils/load_env.sh"
source "$(dirname "$0")/../../utils/bash_tools.sh"

# Function to check if Java is installed and has the correct version
check_java_version() {
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
check_sdkman() {
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
install_sdkman() {
  print_info "Installing SDKMAN..."

  # Install SDKMAN using the official install script
  curl -s "https://get.sdkman.io" | bash

  # Setup SDKMAN in the current shell
  export SDKMAN_DIR="$HOME/.sdkman"
  [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && \. "$SDKMAN_DIR/bin/sdkman-init.sh"

  # Verify installation
  if command -v sdk &> /dev/null; then
    print_success "SDKMAN installed successfully."
    return 0
  else
    print_error "Failed to install SDKMAN."
    return 1
  fi
}

# Function to install Java using SDKMAN
install_java_with_sdkman() {
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

# Main function
setup_java() {
  print_header_info "Check Installation Java"

  # Check if Java is already installed with correct version
  if check_java_version; then
    print_success "Java is already installed with the required version."
    return 0
  fi

  # Use SDKMAN for Java installation
  if check_sdkman || install_sdkman; then
    install_java_with_sdkman
    # Check if Java is now installed with correct version
    if check_java_version; then
      return 0
    fi
  fi

  print_error "Failed to install Java. Please install Java 17 or higher manually."
  return 1
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_java "$@"
fi