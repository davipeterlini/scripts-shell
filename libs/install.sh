#!/bin/bash

# Shell Utils Library Installer
# Automatic installer for Shell Utils library

set -e

# Configuration
REPO_URL="https://github.com/seu-usuario/shell-utils.git"
INSTALL_DIR="/usr/local/lib"
BIN_DIR="/usr/local/bin"
LIB_NAME="shell-utils"
VERSION="1.0.0"

# Cores para output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Basic output functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ Error: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if running as root (for global installation)
check_root() {
    if [[ $EUID -ne 0 ]] && [[ "$1" == "global" ]]; then
        print_error "Global installation requires root privileges. Use: sudo $0 global"
        exit 1
    fi
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux) OS="linux" ;;
        CYGWIN*|MINGW*|MSYS*) OS="windows" ;;
        *) OS="unknown" ;;
    esac
}

# Install dependencies
install_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Install Git first."
        exit 1
    fi
    
    # Check curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        print_error "curl or wget are required for download."
        exit 1
    fi
    
    print_success "Dependencies verified"
}

# Install locally in project
install_local() {
    local target_dir="${1:-./libs}"
    
    print_info "Installing Shell Utils locally in: $target_dir"
    
    # Create directory if it doesn't exist
    mkdir -p "$target_dir"
    
    # Download file directly
    if command -v curl &> /dev/null; then
        curl -sL "https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh" -o "$target_dir/shell-utils.sh"
    elif command -v wget &> /dev/null; then
        wget -q "https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh" -O "$target_dir/shell-utils.sh"
    fi
    
    chmod +x "$target_dir/shell-utils.sh"
    
    print_success "Installed in: $target_dir/shell-utils.sh"
    print_info "Para usar: source \"$target_dir/shell-utils.sh\""
}

# Install globally in system
install_global() {
    print_info "Installing Shell Utils globally..."
    
    # Create directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    
    # Download and install library
    if command -v curl &> /dev/null; then
        curl -sL "https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh" -o "$INSTALL_DIR/$LIB_NAME.sh"
    elif command -v wget &> /dev/null; then
        wget -q "https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh" -O "$INSTALL_DIR/$LIB_NAME.sh"
    fi
    
    chmod +x "$INSTALL_DIR/$LIB_NAME.sh"
    
    # Criar wrapper executável
    cat > "$BIN_DIR/$LIB_NAME" << 'EOF'
#!/bin/bash
# Shell Utils Library Wrapper
source "/usr/local/lib/shell-utils.sh"
shell_utils_info
EOF
    
    chmod +x "$BIN_DIR/$LIB_NAME"
    
    print_success "Installed globally in: $INSTALL_DIR/$LIB_NAME.sh"
    print_info "Para usar: source \"$INSTALL_DIR/$LIB_NAME.sh\""
    print_info "Available command: $LIB_NAME"
}

# Install via package manager (prepare structure)
install_package() {
    print_info "Preparing structure for packaging..."
    
    local pkg_dir="./package"
    mkdir -p "$pkg_dir"/{usr/local/lib,usr/local/bin,DEBIAN}
    
    # Copy files
    cp libs/shell-utils.sh "$pkg_dir/usr/local/lib/"
    
    # Create control file for Debian
    cat > "$pkg_dir/DEBIAN/control" << EOF
Package: shell-utils
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Depends: bash (>= 4.0)
Maintainer: Your Name <your.email@domain.com>
Description: Shell utilities library for automation and development tools
 A comprehensive shell library providing utilities for:
 - Colored output and formatted messages
 - Directory management
 - OS detection
 - Interactive menus
 - Script execution
 - Git repository management
 - Cross-platform browser opening
EOF
    
    # Create wrapper
    cat > "$pkg_dir/usr/local/bin/shell-utils" << 'EOF'
#!/bin/bash
source "/usr/local/lib/shell-utils.sh"
shell_utils_info
EOF
    
    chmod +x "$pkg_dir/usr/local/bin/shell-utils"
    chmod +x "$pkg_dir/usr/local/lib/shell-utils.sh"
    
    print_success "Package structure created in: $pkg_dir"
    print_info "Para criar pacote .deb: dpkg-deb --build $pkg_dir shell-utils_$VERSION.deb"
}

# Uninstall
uninstall() {
    print_info "Removing Shell Utils..."
    
    # Remove global files
    if [[ -f "$INSTALL_DIR/$LIB_NAME.sh" ]]; then
        rm -f "$INSTALL_DIR/$LIB_NAME.sh"
        print_success "Removed: $INSTALL_DIR/$LIB_NAME.sh"
    fi
    
    if [[ -f "$BIN_DIR/$LIB_NAME" ]]; then
        rm -f "$BIN_DIR/$LIB_NAME"
        print_success "Removed: $BIN_DIR/$LIB_NAME"
    fi
    
    print_success "Uninstallation completed"
}

# Verificar instalação
check_installation() {
    print_info "Checking installation..."
    
    # Check global installation
    if [[ -f "$INSTALL_DIR/$LIB_NAME.sh" ]]; then
        print_success "Global installation found: $INSTALL_DIR/$LIB_NAME.sh"
        
        # Test loading
        if source "$INSTALL_DIR/$LIB_NAME.sh" 2>/dev/null; then
            print_success "Library loads correctly"
        else
            print_error "Error loading library"
        fi
    else
        print_warning "Global installation not found"
    fi
    
    # Check command
    if command -v "$LIB_NAME" &> /dev/null; then
        print_success "Command '$LIB_NAME' available"
    else
        print_warning "Command '$LIB_NAME' not found"
    fi
}

# Help
show_help() {
    cat << EOF
Shell Utils Library Installer v$VERSION

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    local [DIR]     Install locally (default: ./libs)
    global          Install globally (requires sudo)
    package         Create packaging structure
    uninstall       Remove global installation
    check           Check installation
    help            Show this help

EXAMPLES:
    $0 local                    # Install in ./libs/
    $0 local ./vendor           # Install in ./vendor/
    sudo $0 global              # Install globally
    $0 package                  # Create .deb package
    $0 check                    # Check installation

USAGE AFTER INSTALL:
    Local:  source "./libs/shell-utils.sh"
    Global: source "/usr/local/lib/shell-utils.sh"
    Command: shell-utils

EOF
}

# Main function
main() {
    detect_os
    
    case "${1:-help}" in
        "local")
            install_dependencies
            install_local "$2"
            ;;
        "global")
            check_root "global"
            install_dependencies
            install_global
            ;;
        "package")
            install_package
            ;;
        "uninstall")
            check_root "global"
            uninstall
            ;;
        "check")
            check_installation
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "Invalid command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"