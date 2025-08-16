#!/bin/bash

# Utility to initialize the shell scripts library in another project
# This script helps with setting up the library in external projects

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source required utilities if present
if [ -f "${SCRIPT_DIR}/colors_message.sh" ]; then
  source "${SCRIPT_DIR}/colors_message.sh"
else
  # Fallback minimal color definitions
  RED='\033[1;31m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
  
  # Minimal print functions
  print_success() { echo -e "${GREEN}✅ $1${NC}"; }
  print_error() { echo -e "${RED}❌ Error: $1${NC}"; }
  print_info() { echo -e "\n${BLUE}ℹ️ $1${NC}"; }
  print_alert() { echo -e "\n${YELLOW}⚠️ $1${NC}"; }
fi

# Function to check if git is available
check_git() {
  if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install git first."
    return 1
  fi
  return 0
}

# Function to install the library via git clone
install_via_clone() {
  local target_dir="$1"
  local repo_url="$2"
  
  if [ -d "$target_dir" ]; then
    print_alert "Directory $target_dir already exists."
    read -p "Do you want to overwrite it? (y/n): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      print_info "Installation canceled."
      return 1
    fi
    rm -rf "$target_dir"
  fi
  
  print_info "Installing shell scripts library to $target_dir..."
  
  if git clone "$repo_url" "$target_dir"; then
    # Remove .git directory to avoid git conflicts
    rm -rf "$target_dir/.git"
    print_success "Library installed successfully to $target_dir!"
    return 0
  else
    print_error "Failed to clone repository."
    return 1
  fi
}

# Function to install the library via git submodule
install_via_submodule() {
  local target_dir="$1"
  local repo_url="$2"
  
  # Check if in a git repository
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    print_error "Not in a git repository. Please run this from a git repository root."
    return 1
  fi
  
  if [ -d "$target_dir" ]; then
    print_alert "Directory $target_dir already exists."
    read -p "Do you want to remove it and reinstall? (y/n): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      print_info "Installation canceled."
      return 1
    fi
    rm -rf "$target_dir"
    # Check if it's a submodule and remove it
    if grep -q "submodule \"$target_dir\"" .gitmodules 2>/dev/null; then
      git submodule deinit -f -- "$target_dir"
      git rm -f "$target_dir"
    fi
  fi
  
  print_info "Adding shell scripts library as a git submodule to $target_dir..."
  
  if git submodule add "$repo_url" "$target_dir" && 
     git submodule init "$target_dir" && 
     git submodule update "$target_dir"; then
    print_success "Submodule installed successfully to $target_dir!"
    return 0
  else
    print_error "Failed to add submodule."
    return 1
  fi
}

# Function to create helper scripts in the target project
create_helper_scripts() {
  local target_dir="$1"
  local helpers_dir="${2:-scripts}"
  
  mkdir -p "$helpers_dir"
  
  # Create update script
  cat > "$helpers_dir/update-scripts-lib.sh" << EOF
#!/bin/bash

# Script to update the shell scripts library
SCRIPTS_LIB_DIR="$target_dir"

# Check if it's a git submodule
if [ -f ".gitmodules" ] && grep -q "submodule \"$target_dir\"" .gitmodules 2>/dev/null; then
  echo "Updating git submodule..."
  git submodule update --remote --merge "$SCRIPTS_LIB_DIR"
  echo "Submodule updated successfully!"
else
  echo "Not a git submodule. Please reinstall the library."
fi
EOF
  
  # Create loader script
  cat > "$helpers_dir/load-scripts-lib.sh" << EOF
#!/bin/bash

# Helper script to load the shell scripts library
SCRIPTS_LIB_DIR="$target_dir"

# Source common utilities
source "\$SCRIPTS_LIB_DIR/utils/colors_message.sh"
source "\$SCRIPTS_LIB_DIR/utils/bash_tools.sh"
source "\$SCRIPTS_LIB_DIR/utils/load_env.sh"

# Usage example:
# source "\$(dirname "\$0")/load-scripts-lib.sh"
# print_success "Library loaded successfully!"
# find_project_root
EOF
  
  # Make scripts executable
  chmod +x "$helpers_dir/update-scripts-lib.sh"
  chmod +x "$helpers_dir/load-scripts-lib.sh"
  
  print_success "Helper scripts created in $helpers_dir/"
  print_info "Usage: source \"\$(dirname \"\$0\")/helpers/load-scripts-lib.sh\""
}

# Function to display usage information
show_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Initialize the shell scripts library in another project."
  echo ""
  echo "Options:"
  echo "  -d, --dir DIR        Target directory for installation (default: lib/shell-scripts)"
  echo "  -r, --repo URL       Repository URL (default: current origin URL)"
  echo "  -s, --submodule      Install as git submodule (default: simple clone)"
  echo "  -h, --helpers DIR    Create helper scripts in DIR (default: scripts)"
  echo "  --help               Display this help message"
  echo ""
  echo "Example:"
  echo "  $0 --dir lib/utils --submodule"
}

# Main function
init_lib() {
  # Default values
  local target_dir="lib/shell-scripts"
  local helpers_dir="scripts"
  local repo_url=""
  local use_submodule=false
  
  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--dir)
        target_dir="$2"
        shift 2
        ;;
      -r|--repo)
        repo_url="$2"
        shift 2
        ;;
      -s|--submodule)
        use_submodule=true
        shift
        ;;
      -h|--helpers)
        helpers_dir="$2"
        shift 2
        ;;
      --help)
        show_usage
        return 0
        ;;
      *)
        print_error "Unknown option: $1"
        show_usage
        return 1
        ;;
    esac
  done
  
  # Check if git is installed
  check_git || return 1
  
  # Get repository URL if not provided
  if [ -z "$repo_url" ]; then
    # Try to get the origin URL of the current repository
    if git -C "$PROJECT_ROOT" remote get-url origin 2>/dev/null; then
      repo_url=$(git -C "$PROJECT_ROOT" remote get-url origin)
    else
      print_error "No repository URL provided and couldn't determine origin URL."
      print_info "Please specify a repository URL with --repo."
      return 1
    fi
  fi
  
  # Perform installation
  if [ "$use_submodule" = true ]; then
    install_via_submodule "$target_dir" "$repo_url" || return 1
  else
    install_via_clone "$target_dir" "$repo_url" || return 1
  fi
  
  # Create helper scripts
  if [ -n "$helpers_dir" ]; then
    create_helper_scripts "$target_dir" "$helpers_dir"
  fi
  
  print_info "Installation complete!"
  print_info "See LIBRARY_USAGE.md for detailed usage instructions."
  
  return 0
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  init_lib "$@"
fi