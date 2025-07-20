#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors_message.sh"
source "$SCRIPT_DIR/detect_os.sh"
source "$SCRIPT_DIR/setup_ides.sh"

# Default plugin directories and file types
PLUGIN_NAME_VSCODE="ciandt-global.ciandt-flow"
FLOWCODER_PLUGIN_ID="27434"

# Install FlowCoder plugin for VS Code
install_plugin_vscode() {
  # Check if VS Code is installed
  # TODO - se não estiver sido instalado faça a instalação da IDE setup_ide.sh
  if ! command -v code &> /dev/null; then
    print_error "VS Code command line tool not found."
    print_alert "You may need to install the plugin manually using: code --install-extension $plugin_file"
    return 1
  fi

  detect_os
  # Get OS and architecture information from detect_so function
  OS_TYPE="$os"
  OS_ARQ="$os_arq"
  ARCH_TYPE="$ARCH"
  
  print_info "Installing VS Code extension for $OS_TYPE on $ARCH_TYPE architecture"
  
  # Path to the extension build directory
  EXTENSION_BUILD_DIR="extensions/vscode/build"
  
  # Check if the build directory exists
  if [ ! -d "$EXTENSION_BUILD_DIR" ]; then
    print_alert "Extension build directory not found: $EXTENSION_BUILD_DIR"
    return 1
  fi
  
  # Find the VSIX file matching the current OS and architecture
  # First try to find an exact match for OS and architecture
  VSIX_FILE=$(find "$EXTENSION_BUILD_DIR" -name "*${OS_ARQ}*${ARCH_TYPE}*.vsix" | head -n 1)

  # If no specific match found, try to find any VSIX file
  if [ -z "$VSIX_FILE" ]; then
    print_info "No specific build found for $OS_ARQ-$ARCH_TYPE, looking for any compatible build"
    VSIX_FILE=$(find "$EXTENSION_BUILD_DIR" -name "*.vsix" | head -n 1)
  fi
  
  if [ -z "$VSIX_FILE" ]; then
    print_alert "No VSIX file found in $EXTENSION_BUILD_DIR"
    return 1
  fi
  
  print_info "Installing extension from: $VSIX_FILE"
  
  if code --install-extension "$VSIX_FILE" --force; then
    print_success "VS Code extension installed successfully!"
    return 0
  else
    print_alert "Failed to install VS Code extension."
    return 1
  fi
}

# Install JetBrains Toolbox CLI and use it to install FlowCoder plugin
install_plugin_jetbrains() {
  print_info "Installing JetBrains Toolbox CLI..."
  
  # Determine OS type for installation
  detect_os
  local os_type="$OS_NAME"
  local arch="$ARCH"
  local toolbox_cli_dir="$HOME/.local/bin"
  local toolbox_cli_path="$toolbox_cli_dir/jetbrains-toolbox-cli"
  
  # Create directory if it doesn't exist
  mkdir -p "$toolbox_cli_dir"
  
  # Download and install JetBrains Toolbox CLI based on OS
  case "$os_type" in
    "macOS")
      local download_url="https://raw.githubusercontent.com/JetBrains/toolbox-cli/master/bin/mac/jetbrains-toolbox-cli"
      curl -L "$download_url" -o "$toolbox_cli_path"
      ;;
    "Linux")
      local download_url="https://raw.githubusercontent.com/JetBrains/toolbox-cli/master/bin/linux/jetbrains-toolbox-cli"
      curl -L "$download_url" -o "$toolbox_cli_path"
      ;;
    "Windows")
      print_alert "For Windows, please download the JetBrains Toolbox CLI manually from:"
      print_alert "https://github.com/JetBrains/toolbox-cli"
      return 1
      ;;
    *)
      print_error "Unsupported operating system: $os_type"
      return 1
      ;;
  esac
  
  # Make the CLI executable
  chmod +x "$toolbox_cli_path"
  
  # Check if installation was successful
  if ! command -v "$toolbox_cli_path" &> /dev/null; then
    print_error "Failed to install JetBrains Toolbox CLI."
    print_alert "Please install it manually from: https://github.com/JetBrains/toolbox-cli"
    return 1
  fi
  
  print_success "JetBrains Toolbox CLI installed successfully!"
  
  # Install FlowCoder plugin using the toolbox CLI
  print_info "Installing FlowCoder plugin (ID: $FLOWCODER_PLUGIN_ID) using JetBrains Toolbox CLI..."
  
  # Get IDE type from user
  print_alert "Select JetBrains IDE type for plugin installation:"
  echo "1) IntelliJ IDEA"
  echo "2) PyCharm"
  echo "3) WebStorm"
  echo "4) PhpStorm"
  echo "5) Other (specify name)"
  read -r choice

  local ide_code
  case "$choice" in
    1) ide_code="intellij" ;;
    2) ide_code="pycharm" ;;
    3) ide_code="webstorm" ;;
    4) ide_code="phpstorm" ;;
    5)
      print_alert "Enter the JetBrains IDE code (e.g., rubymine, clion): "
      read -r ide_code
      ;;
    *)
      print_error "Invalid choice. Exiting plugin installation."
      return 1
      ;;
  esac
  
  # Install the plugin using the toolbox CLI
  if "$toolbox_cli_path" plugin install --ide-code "$ide_code" --plugin-id "$FLOWCODER_PLUGIN_ID"; then
    print_success "FlowCoder plugin installed successfully via JetBrains Toolbox CLI!"
    return 0
  else
    print_error "Failed to install FlowCoder plugin via JetBrains Toolbox CLI."
    print_alert "You may need to install the plugin manually through the JetBrains Marketplace."
    return 1
  fi
}

# Install FlowCoder plugin for VS Code
install_plugin_marketplace_vscode() {
  PLUGIN_NAME_VSCODE="ciandt-global.ciandt-flow"
  # Check if VS Code is installed
  # TODO - se não estiver sido instalado faça a instalação da IDE setup_ide.sh
  if ! command -v code &> /dev/null; then
    print_error "VS Code command line tool not found."
    print_alert "You may need to install the plugin manually using: code --install-extension $plugin_file"
    return 1
  fi

  print_info "Installing VS Code extension from: Flow Coder Extension"
  
  # Check if the extension is already installed
  if code --list-extensions | grep -q "$PLUGIN_NAME_VSCODE"; then
    print_info "Extension $PLUGIN_NAME_VSCODE is already installed. Removing it first..."
    code --uninstall-extension "$PLUGIN_NAME_VSCODE"
  else
    print_info "Extension $PLUGIN_NAME_VSCODE is not installed. Proceeding with installation..."
  fi
  
  # Install the plugin
  print_info "Installing VS Code extension from: Flow Coder Extension"
  if code --install-extension "$PLUGIN_NAME_VSCODE"; then
    print_success "VS Code extension installed successfully!"
    return 0
  else
    print_error "Failed to install VS Code extension."
    return 1
  fi
}

install_plugin_marketplace_jetbrains() {
  print_info "Installing JetBrains Toolbox CLI..."
  FLOWCODER_PLUGIN_ID="27434"
  
  # Determine OS type for installation
  detect_os
  local os_type="$OS_NAME"
  local arch="$ARCH"
  local toolbox_cli_dir="$HOME/.local/bin"
  local toolbox_cli_path="$toolbox_cli_dir/jetbrains-toolbox-cli"
  
  # Create directory if it doesn't exist
  mkdir -p "$toolbox_cli_dir"
  
  # Download and install JetBrains Toolbox CLI based on OS
  case "$os_type" in
    "macOS")
      local download_url="https://raw.githubusercontent.com/JetBrains/toolbox-cli/master/bin/mac/jetbrains-toolbox-cli"
      curl -L "$download_url" -o "$toolbox_cli_path"
      ;;
    "Linux")
      local download_url="https://raw.githubusercontent.com/JetBrains/toolbox-cli/master/bin/linux/jetbrains-toolbox-cli"
      curl -L "$download_url" -o "$toolbox_cli_path"
      ;;
    "Windows")
      print_alert "For Windows, please download the JetBrains Toolbox CLI manually from:"
      print_alert "https://github.com/JetBrains/toolbox-cli"
      return 1
      ;;
    *)
      print_error "Unsupported operating system: $os_type"
      return 1
      ;;
  esac
  
  # Make the CLI executable
  chmod +x "$toolbox_cli_path"
  
  # Check if installation was successful
  if ! command -v "$toolbox_cli_path" &> /dev/null; then
    print_error "Failed to install JetBrains Toolbox CLI."
    print_alert "Please install it manually from: https://github.com/JetBrains/toolbox-cli"
    return 1
  fi
  
  print_success "JetBrains Toolbox CLI installed successfully!"
  
  # Install FlowCoder plugin using the toolbox CLI
  print_info "Installing FlowCoder plugin (ID: $FLOWCODER_PLUGIN_ID) using JetBrains Toolbox CLI..."
  
  # Get IDE type from user
  print_alert "Select JetBrains IDE type for plugin installation:"
  echo "1) IntelliJ IDEA"
  echo "2) PyCharm"
  echo "3) WebStorm"
  echo "4) PhpStorm"
  echo "5) Other (specify name)"
  read -r choice

  local ide_code
  case "$choice" in
    1) ide_code="intellij" ;;
    2) ide_code="pycharm" ;;
    3) ide_code="webstorm" ;;
    4) ide_code="phpstorm" ;;
    5)
      print_alert "Enter the JetBrains IDE code (e.g., rubymine, clion): "
      read -r ide_code
      ;;
    *)
      print_error "Invalid choice. Exiting plugin installation."
      return 1
      ;;
  esac
  
  # Install the plugin using the toolbox CLI
  if "$toolbox_cli_path" plugin install --ide-code "$ide_code" --plugin-id "$FLOWCODER_PLUGIN_ID"; then
    print_success "FlowCoder plugin installed successfully via JetBrains Toolbox CLI!"
    return 0
  else
    print_error "Failed to install FlowCoder plugin via JetBrains Toolbox CLI."
    print_alert "You may need to install the plugin manually through the JetBrains Marketplace."
    return 1
  fi
}

# Main function
install_flow_coder() {
  # First check for installed IDEs
  check_installed_ides

  # Install plugins based on available IDEs
  if [ "$IDE_VSCODE_AVAILABLE" = true ]; then
    print_info "Installing FlowCoder plugin for VS Code..."
    install_plugin_vscode
  fi

  if [ "$IDE_JETBRAINS_AVAILABLE" = true ]; then
    print_info "Installing FlowCoder plugin for JetBrains IDE..."
    install_plugin_jetbrains
  fi

  if [ "$IDE_VSCODE_AVAILABLE" = false ] && [ "$IDE_JETBRAINS_AVAILABLE" = false ]; then
    print_error "No supported IDEs found. Please install VS Code or a JetBrains IDE first."
    print_info "You can run the install_ides.sh script to install an IDE."
    # TODO - verificar se precisa passar a IDE
    setup_ides
    return 1
  fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_flow_coder "$@"
fi