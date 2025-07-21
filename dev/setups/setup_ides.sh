#!/bin/bash
#
# IDE Setup Script
# This script checks for installed IDEs (VS Code and JetBrains) and offers to install them if not found.
#

# Setup paths and import utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/utils/colors_message.sh"
source "$ROOT_DIR/utils/detect_os.sh"

# Constants
readonly VSCODE_DOWNLOAD_URL="https://code.visualstudio.com/download"
readonly JETBRAINS_DOWNLOAD_URL="https://www.jetbrains.com/products/"
readonly JETBRAINS_TOOLBOX_URL="https://www.jetbrains.com/toolbox-app/"

_check_vscode() {
  local vscode_found=false
  local vscode_version=""

  # Check for VS Code in PATH
  if command -v code > /dev/null 2>&1; then
    vscode_found=true
    vscode_version=$(code --version | head -n 1)
    print_success "Visual Studio Code is installed (command 'code')"
    print_info "VS Code version: $vscode_version"
  elif command -v code-insiders > /dev/null 2>&1; then
    vscode_found=true
    vscode_version=$(code-insiders --version | head -n 1)
    print_success "Visual Studio Code Insiders is installed"
    print_info "VS Code Insiders version: $vscode_version"
  # Check for VS Code app on macOS
  elif [[ "$OSTYPE" == "darwin"* ]] && [ -d "/Applications/Visual Studio Code.app" ]; then
    vscode_found=true
    print_success "Visual Studio Code is installed (macOS application)"
  fi

  # Export result
  if $vscode_found; then
    export IDE_VSCODE_AVAILABLE=true
    return 0
  else
    export IDE_VSCODE_AVAILABLE=false
    return 1
  fi
}

_check_jetbrains() {
  local jetbrains_found=false
  local jetbrains_ide=""

  # Define common JetBrains IDEs and their commands
  declare -A jetbrains_ides
  jetbrains_ides["IntelliJ_IDEA"]="idea intellij idea.sh"
  jetbrains_ides["PyCharm"]="pycharm charm pycharm.sh"
  jetbrains_ides["WebStorm"]="webstorm wstorm webstorm.sh"
  jetbrains_ides["PhpStorm"]="phpstorm pstorm phpstorm.sh"
  jetbrains_ides["CLion"]="clion clion.sh"
  jetbrains_ides["Rider"]="rider rider.sh"
  jetbrains_ides["GoLand"]="goland goland.sh"
  jetbrains_ides["RubyMine"]="rubymine mine rubymine.sh"
  jetbrains_ides["DataGrip"]="datagrip datagrip.sh"
  jetbrains_ides["Android_Studio"]="studio androidstudio studio.sh"

  # Check for JetBrains applications on macOS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Map keys to app names
    declare -A app_names
    app_names["IntelliJ_IDEA"]="IntelliJ IDEA"
    app_names["PyCharm"]="PyCharm"
    app_names["WebStorm"]="WebStorm"
    app_names["PhpStorm"]="PhpStorm"
    app_names["CLion"]="CLion"
    app_names["Rider"]="Rider"
    app_names["GoLand"]="GoLand"
    app_names["RubyMine"]="RubyMine"
    app_names["DataGrip"]="DataGrip"
    app_names["Android_Studio"]="Android Studio"
    
    for ide_key in "${!app_names[@]}"; do
      app_name="${app_names[$ide_key]}"
      if [ -d "/Applications/${app_name}.app" ]; then
        jetbrains_found=true
        jetbrains_ide="$app_name"
        print_success "$app_name is installed (macOS application)"
      fi
    done
  fi

  # Check for JetBrains commands in PATH
  if ! $jetbrains_found; then
    for ide_key in "${!jetbrains_ides[@]}"; do
      commands=${jetbrains_ides[$ide_key]}
      for cmd in $commands; do
        if command -v "$cmd" > /dev/null 2>&1; then
          jetbrains_found=true
          # Convert key to friendly name
          case "$ide_key" in
            "IntelliJ_IDEA") jetbrains_ide="IntelliJ IDEA" ;;
            "Android_Studio") jetbrains_ide="Android Studio" ;;
            *) jetbrains_ide="$ide_key" ;;
          esac
          print_success "$jetbrains_ide is installed (command '$cmd')"
          break
        fi
      done
      # Break outer loop if IDE found
      if $jetbrains_found; then
        break
      fi
    done
  fi

  # Check for JetBrains directories on Linux
  if ! $jetbrains_found && [[ "$OSTYPE" == "linux"* ]]; then
    local jetbrains_dirs=("$HOME/.local/share/JetBrains" "/opt/jetbrains")
    for dir in "${jetbrains_dirs[@]}"; do
      if [ -d "$dir" ]; then
        jetbrains_found=true
        print_success "JetBrains directory found at $dir"
        break
      fi
    done
  fi

  # Check for JetBrains directories on Windows
  if ! $jetbrains_found && [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    local jetbrains_dirs=("$APPDATA/JetBrains" "/c/Program Files/JetBrains")
    for dir in "${jetbrains_dirs[@]}"; do
      if [ -d "$dir" ]; then
        jetbrains_found=true
        print_success "JetBrains directory found at $dir"
        break
      fi
    done
  fi

  # Export result
  if $jetbrains_found; then
    export IDE_JETBRAINS_AVAILABLE=true
    export IDE_JETBRAINS_TYPE="$jetbrains_ide"
    return 0
  else
    export IDE_JETBRAINS_AVAILABLE=false
    return 1
  fi
}

_check_installed_ides() {
  print_info "Checking for installed IDEs..."

  local vscode_installed=false
  local jetbrains_installed=false

  # Check for VS Code
  if _check_vscode; then
    vscode_installed=true
  fi

  # Check for JetBrains IDEs
  if _check_jetbrains; then
    jetbrains_installed=true
  fi

  # Summary
  if ! $vscode_installed && ! $jetbrains_installed; then
    print_error "No supported IDEs found. Please install VS Code or a JetBrains IDE."
    return 1
  fi

  print_info "IDE check completed."
  return 0
}

_install_homebrew() {
  print_info "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for current session
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    print_error "Failed to install Homebrew."
    return 1
  fi
  
  return 0
}

install_vscode() {
  if [ "$IDE_VSCODE_AVAILABLE" = true ]; then
    print_info "VS Code is already installed."
    return 0
  fi

  print_info "Installing Visual Studio Code..."
  
  # Use the detect_os function to determine OS type
  detect_os
  local os_type="$os"

  case "$os_type" in
    "macOS")
      # macOS installation via Homebrew
      if ! command -v brew &> /dev/null; then
        if ! _install_homebrew; then
          print_error "Please install VS Code manually from $VSCODE_DOWNLOAD_URL"
          return 1
        fi
      fi
      
      # Check if VS Code is already installed via Homebrew
      if ! brew list --cask | grep -q "visual-studio-code"; then
        print_info "Installing Visual Studio Code via Homebrew..."
        brew install --cask visual-studio-code
      else
        print_info "Visual Studio Code is already installed via Homebrew."
      fi
      ;;
    "Linux")
      # Linux installation
      if command -v apt &> /dev/null; then
        # Debian/Ubuntu
        print_info "Installing VS Code via apt..."
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
        sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt update
        sudo apt install -y code
        rm microsoft.gpg
      elif command -v dnf &> /dev/null; then
        # Fedora/RHEL
        print_info "Installing VS Code via dnf..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update
        sudo dnf install -y code
      else
        print_error "Unsupported Linux distribution. Please install VS Code manually from $VSCODE_DOWNLOAD_URL"
        return 1
      fi
      ;;
    "Windows")
      # Windows installation
      print_error "Automatic installation on Windows not supported. Please install VS Code manually from $VSCODE_DOWNLOAD_URL"
      return 1
      ;;
    *)
      print_error "Unsupported operating system. Please install VS Code manually from $VSCODE_DOWNLOAD_URL"
      return 1
      ;;
  esac

  # Verify installation
  if command -v code &> /dev/null || [[ "$OSTYPE" == "darwin"* && -d "/Applications/Visual Studio Code.app" ]]; then
    print_success "VS Code installed successfully!"
    export IDE_VSCODE_AVAILABLE=true
    return 0
  else
    print_error "VS Code installation failed."
    return 1
  fi
}

install_jetbrains() {
  if [ "$IDE_JETBRAINS_AVAILABLE" = true ]; then
    print_info "JetBrains IDE is already installed."
    return 0
  fi

  print_info "Installing JetBrains IDE..."
  
  # Use the detect_os function to determine OS type
  detect_os
  local os_type="$os"

  # Get IDE type from user
  print_alert "Select JetBrains IDE to install:"
  echo "1) IntelliJ IDEA Community"
  echo "2) PyCharm Community"
  echo "3) WebStorm (requires license)"
  echo "4) PhpStorm (requires license)"
  echo "5) Other (specify name)"
  read -r choice

  local ide_name
  local ide_package
  case "$choice" in
    1) 
      ide_name="IntelliJ IDEA"
      ide_package="intellij-idea-community"
      ;;
    2) 
      ide_name="PyCharm"
      ide_package="pycharm-community"
      ;;
    3) 
      ide_name="WebStorm"
      ide_package="webstorm"
      ;;
    4) 
      ide_name="PhpStorm"
      ide_package="phpstorm"
      ;;
    5)
      print_alert "Enter the JetBrains IDE name (e.g., RubyMine, CLion): "
      read -r ide_name
      ide_package=$(echo "$ide_name" | tr '[:upper:]' '[:lower:]')
      ;;
    *)
      print_error "Invalid choice. Exiting IDE installation."
      return 1
      ;;
  esac

  case "$os_type" in
    "macOS")
      # macOS installation via Homebrew
      if ! command -v brew &> /dev/null; then
        if ! _install_homebrew; then
          print_error "Please install $ide_name manually from $JETBRAINS_DOWNLOAD_URL"
          return 1
        fi
      fi
      
      print_info "Installing $ide_name via Homebrew..."
      brew install --cask "$ide_package"
      ;;
    "Linux")
      # Linux installation - recommend JetBrains Toolbox
      print_info "For Linux, we recommend installing the JetBrains Toolbox App"
      print_info "Please visit: $JETBRAINS_TOOLBOX_URL"
      print_info "The Toolbox App will help you install and manage JetBrains IDEs"
      return 1
      ;;
    "Windows")
      # Windows installation
      print_error "Automatic installation on Windows not supported. Please install $ide_name manually from $JETBRAINS_DOWNLOAD_URL"
      return 1
      ;;
    *)
      print_error "Unsupported operating system. Please install $ide_name manually from $JETBRAINS_DOWNLOAD_URL"
      return 1
      ;;
  esac

  # Verify installation by checking again
  if _check_jetbrains; then
    print_success "$ide_name installation completed!"
    return 0
  else
    print_error "$ide_name installation may have failed. Please verify manually."
    return 1
  fi
}

_prompt_ide_installation() {
  print_alert "No supported IDEs found. Would you like to install one? (y/n)"
  read -r install_choice
  
  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    print_alert "Which IDE would you like to install?"
    echo "1) Visual Studio Code (recommended)"
    echo "2) JetBrains IDE"
    read -r ide_choice
    
    case "$ide_choice" in
      1) install_vscode ;;
      2) install_jetbrains ;;
      *) print_error "Invalid choice. Exiting." ;;
    esac
  else
    print_alert "No IDE will be installed. You may need to install one manually."
  fi
}

setup_ides() {
  _check_installed_ides
  
  # If no IDEs are installed, offer to install one
  if [ "$IDE_VSCODE_AVAILABLE" = false ] && [ "$IDE_JETBRAINS_AVAILABLE" = false ]; then
    _prompt_ide_installation
  fi
  
  return 0
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_ides "$@"
fi