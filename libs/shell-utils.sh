#!/bin/bash

# Shell Utils Library
# Consolidated library with shell utilities for automation and tools

# =============================================================================
# INITIAL CONFIGURATION
# =============================================================================

# Get absolute directory of current script
SHELL_UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# COLORS AND MESSAGES
# =============================================================================

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;37m'
NC='\033[0m' # No Color

# Function to display informative messages
function print_info() {
  echo -e "\n${BLUE}ℹ️  $1${NC}"
}

# Function to display success messages
function print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

# Function to display alert messages
function print_alert() {
  echo -e "\n${YELLOW}⚠️  $1${NC}"
}

# Function to display question messages
function print_alert_question() {
  echo -n -e "\n${YELLOW}⚠️  $1${NC}"
}

# Function to display error messages
function print_error() {
  echo -e "${RED}❌ Error: $1${NC}"
}

# Function to display simple messages
function print() {
  echo -e "${CYAN}$1${NC}"
}

# Function to display formatted headers
function print_header() {
  echo -e "\n${YELLOW}===========================================================================${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${YELLOW}===========================================================================${NC}"
}

# Function to display informative headers
function print_header_info() {
  echo -e "\n${CYAN}===========================================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${CYAN}===========================================================================${NC}"
}

# Function to display yellow text
function print_yellow() {
  echo -e "${YELLOW}$1${NC}"
}

# Function to display red text
function print_red() {
  echo -e "${RED}$1${NC}"
}

# =============================================================================
# BASH TOOLS
# =============================================================================

# Function to create directories
create_directories() {
  local ROOT_DIR="$1"
  local directories=("$@")
  for dir in "${directories[@]}"; do
    if [[ "$dir" != "$ROOT_DIR" ]]; then
      full_dir="${ROOT_DIR}/${dir}"
      if [[ ! -d "$full_dir" ]]; then
        print_info "Creating directory: $full_dir"
        mkdir -p "$full_dir"
        print_success "Directory created: $full_dir"
      else
        print_info "Directory already exists: $full_dir"
      fi
    fi
  done
}

# Function to remove a directory
remove_directory() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    if rm -rf "$dir"; then
      print_success "Removed $dir"
      return 0
    else
      print_error "Failed to remove $dir"
      return 1
    fi
  else
    print_alert "$dir not found"
    return 0
  fi
}

# Function to remove multiple directories
remove_directories() {
  local array_name=$1
  local failed_count=0

  # Use eval to get array elements
  eval "local directories=(\"\${$array_name[@]}\")"

  for dir in "${directories[@]}"; do
    if ! remove_directory "$dir"; then
      ((failed_count++))
    fi
  done

  if [[ $failed_count -gt 0 ]]; then
    print_alert "Failed to remove $failed_count directories"
  fi
}

# Function to get user confirmation
get_user_confirmation() {
  local prompt_message="${1:-"Do you want to proceed? (y/n): "}"
  print_alert_question "$prompt_message "
  read -r user_choice
  if [[ "$user_choice" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# Function to cleanup temporary files
cleanup_temp_files() {
    local temp_dir="$1"
    rm -rf "$temp_dir"
}

# =============================================================================
# OPERATING SYSTEM DETECTION
# =============================================================================

# Function to detect operating system and version
detect_os() {
    local os_name=""
    local os_version=""
    local os_codename=""
    
    # Detect OS type
    case "$(uname -s)" in
        Darwin)
            os_name="macOS"
            os_version=$(sw_vers -productVersion)
            
            # Get macOS code name based on version
            case "${os_version%%.*}" in
                10)
                    case "${os_version#*.}" in
                        15*) os_codename="Catalina" ;;
                        14*) os_codename="Mojave" ;;
                        13*) os_codename="High Sierra" ;;
                        12*) os_codename="Sierra" ;;
                        11*) os_codename="El Capitan" ;;
                        10*) os_codename="Yosemite" ;;
                        9*) os_codename="Mavericks" ;;
                        *) os_codename="Unknown" ;;
                    esac
                    ;;
                11) os_codename="Big Sur" ;;
                12) os_codename="Monterey" ;;
                13) os_codename="Ventura" ;;
                14) os_codename="Sonoma" ;;
                15) os_codename="Sequoia" ;;
                *) os_codename="Unknown" ;;
            esac
            ;;
            
        Linux)
            os_name="Linux"
            
            # Check Linux distribution information files
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                os_version="$VERSION_ID"
                os_codename="$PRETTY_NAME"
                os_name="$ID"
                
                # Capitalize first letter of distribution name
                os_name="$(tr '[:lower:]' '[:upper:]' <<< ${os_name:0:1})${os_name:1}"
            elif [ -f /etc/lsb-release ]; then
                . /etc/lsb-release
                os_version="$DISTRIB_RELEASE"
                os_codename="$DISTRIB_CODENAME"
                os_name="$DISTRIB_ID"
            elif [ -f /etc/debian_version ]; then
                os_name="Debian"
                os_version=$(cat /etc/debian_version)
            elif [ -f /etc/redhat-release ]; then
                os_name=$(cat /etc/redhat-release | cut -d ' ' -f 1)
                os_version=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+')
            fi
            ;;
            
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            os_name="Windows"
            if [ -n "$(command -v cmd.exe)" ]; then
                # Get Windows version using systeminfo
                os_version=$(cmd.exe /c ver 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
                
                # Try to get Windows edition
                if [ -n "$(command -v wmic)" ]; then
                    os_codename=$(wmic os get Caption /value 2>/dev/null | grep -o "Windows.*" | sed 's/Windows //')
                fi
            fi
            ;;
            
        *)
            print_error "Unsupported operating system"
            return 1
            ;;
    esac
    
    # Export variables
    export OS_NAME="$os_name"
    export OS_VERSION="$os_version"
    export OS_CODENAME="$os_codename"
    
    # Print OS information
    print_success "Detected Operating System: $os_name $os_version $os_codename"

    export os="$os_name"
}

# =============================================================================
# MENU AND INTERFACE
# =============================================================================

# Global variable to store menu choices
MENU_CHOICES=""

# Function to install dialog
install_dialog() {
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y dialog
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install dialog
        else
            echo "Unsupported OS."
            return 1
        fi
    fi
}

# Function to display menu using dialog
display_dialog_menu() {
    install_dialog

    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All Apps" off)

    if [ -z "$choices" ]; then
        print_alert "No option was selected."
    else
        print_success "Selected options: $choices"
    fi
}

# Function to display menu without using dialog
display_menu() {
    echo ""
    print_header_info "Menu"
    echo ""
    print "Select the type of applications to install:"
    echo ""
    print "1) Basic Apps"
    print "2) Development Apps"
    print "3) All Apps"
    echo ""
    
    print_yellow "Enter the numbers of desired options (separated by space) and press ENTER:"
    read -r selection
    
    # Check if input is not empty
    if [ -z "$selection" ]; then
        print_alert "No option was selected."
        MENU_CHOICES=""
        return 1
    fi
    
    # Process and validate input
    local choices=""
    local valid_options=true
    
    for num in $selection; do
        if [[ "$num" =~ ^[1-3]$ ]]; then
            choices+="$num "
        else
            print_error "Invalid option: $num. Ignoring."
            valid_options=false
        fi
    done
    
    # Remove trailing space
    choices=$(echo "$choices" | xargs)
    
    if [ -z "$choices" ]; then
        print_alert "No valid option was selected."
        MENU_CHOICES=""
        return 1
    fi
    
    if [ "$valid_options" = false ]; then
        print_alert "Some invalid options were ignored."
    fi
    
    print_success "Opções selecionadas: $choices"
    
    # Set global variable
    MENU_CHOICES="$choices"
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Function to execute a script with description
execute_script() {
  local script_path=$1
  local description=$2

  if [ -f "$script_path" ]; then
    print_info "$description"
    bash "$script_path"
    print_success "Script execution $script_path completed successfully."
  else
    print_error "Script $script_path not found. Aborting."
  fi
}

# =============================================================================
# GIT REPOSITORY MANAGEMENT
# =============================================================================

# Function to clone a repository
clone_repository() {
    local repo_url="$1"
    local repo_path="$2"
    local repo_name=$(basename "$repo_url" .git)
    local full_repo_path="$repo_path"

    if [[ -d "$full_repo_path" ]]; then
        print_info "Repository directory already exists: $full_repo_path"
        print_info "Updating repository instead of cloning..."
        if (cd "$full_repo_path" && git pull origin main); then
            print_success "Repository updated successfully: $repo_name"
        else
            print_alert "Failed to update repository: $repo_name. Continuing with next repository."
        fi
    else
        print_info "Cloning repository: $repo_name"
        if git clone "$repo_url" "$repo_path"; then
            print_success "Repository cloned successfully: $repo_name"
        else
            print_alert "Failed to clone repository: $repo_name. Skipping and continuing with next repository."
        fi
    fi
}

# Function to update a repository
update_repository() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")

    print_info "Updating repository: $repo_name"
    if (cd "$repo_path" && git pull origin main); then
        print_success "Repository updated successfully: $repo_name"
    else
        print_alert "Failed to update repository: $repo_name. Continuing with next repository."
    fi
}

# Function to merge changes from a branch
merge_back_repository() {
    local repo_path="$1"
    local branch="$2"
    local repo_name=$(basename "$repo_path")

    print_info "Merging back changes from branch $branch in repository: $repo_name"
    if (cd "$repo_path" && git merge "$branch"); then
        print_success "Branch $branch merged successfully in repository: $repo_name"
    else
        print_alert "Failed to merge branch $branch in repository: $repo_name. Continuing with next repository."
    fi
}

# Function to manage repositories - Update or Clone repo
manage_repositories() {
   # Process arguments in pairs (target_dir and repo_url)
   while [[ $# -ge 2 ]]; do
       local repo_url="$1"
       local target_dir="$2"
       shift 2

       local repo_name=$(basename "$repo_url" .git)
       local project_root="$(dirname "$target_dir")"
       local repo_path="$target_dir/$repo_name"

       if [[ -d "$repo_path" ]]; then
           update_repository "$repo_path"
       else
           clone_repository "$repo_url" "$target_dir"
       fi
   done
}

# =============================================================================
# BROWSER
# =============================================================================

# Function to open browser
open_browser() { 
    local url="$1"
    local display_name="$2"
    if command -v xdg-open &> /dev/null; then
        xdg-open "$url"
    elif command -v open &> /dev/null; then
        open "$url"
    else
        print_info "Manually visit $display_name URL: $url"
    fi
}

# =============================================================================
# LIBRARY INFORMATION
# =============================================================================

# Function to display library information
shell_utils_info() {
    print_header "Shell Utils Library"
    print_info "Consolidated library with shell utilities for automation"
    echo ""
    print "Available features:"
    print "• Colors and formatted messages"
    print "• Directory management tools"
    print "• Operating system detection"
    print "• Interactive menus"
    print "• Script execution"
    print "• Git repository management"
    print "• Cross-platform browser opening"
    echo ""
    print_success "Library loaded successfully!"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Automatically detect OS when library is loaded
detect_os

# Display information if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    shell_utils_info
fi