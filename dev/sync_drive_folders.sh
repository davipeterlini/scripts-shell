#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/load_env.sh"
source "$(dirname "$0")/utils/detect_os.sh"

# Check if Google Drive is installed
check_drive_installed() {
    print_info "Checking if Google Drive is installed..."
    if [[ "$os" == "macOS" ]]; then

        if [ -d "/Applications/Google\ Drive.app" ]; then
            print_success "Google Drive is already installed"
            return 0
        else
            return 1
        fi
    elif [[ "$os" == "linux" ]]; then
        if command -v google-drive-ocamlfuse &> /dev/null; then
            print_success "Google Drive is already installed"
            return 0
        else
            return 1
        fi
    fi
}

# Install Google Drive
install_drive() {
    print_info "Installing Google Drive..."
    
    if [[ "$os" == "macOS" ]]; then
        print_info "Downloading Google Drive for macOS..."
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        print_info "Installing Google Drive via Homebrew..."
        brew install --cask google-drive
        
    elif [[ "$os" == "linux" ]]; then
        print_info "Installing Google Drive for Linux (using google-drive-ocamlfuse)..."
        
        # Check Linux distribution
        if command -v apt-get &> /dev/null; then
            # Debian/Ubuntu
            sudo add-apt-repository ppa:alessandro-strada/ppa -y
            sudo apt-get update
            sudo apt-get install -y google-drive-ocamlfuse
        elif command -v dnf &> /dev/null; then
            # Fedora
            sudo dnf install -y google-drive-ocamlfuse
        elif command -v pacman &> /dev/null; then
            # Arch Linux
            sudo pacman -S google-drive-ocamlfuse
        else
            print_error "Unsupported Linux distribution. Please install google-drive-ocamlfuse manually."
        fi
    fi
    
    print_success "Google Drive installed successfully"
}

# Configure Google Drive login
configure_drive_login() {
    print_info "Configuring Google Drive login..."
    
    # Ask which account to use
    echo -e "${YELLOW}Which Google account do you want to use?${NC}"
    echo "1. Work account"
    echo "2. Personal account"
    read -p "Enter your choice (1/2): " account_choice
    
    if [[ "$account_choice" == "1" ]]; then
        ACCOUNT_TYPE="work"
    elif [[ "$account_choice" == "2" ]]; then
        ACCOUNT_TYPE="personal"
    else
        print_error "Invalid choice. Please select 1 for Work or 2 for Personal."
    fi
    
    print_info "You selected: $ACCOUNT_TYPE account"
    
    if [[ "$os" == "macOS" ]]; then
        # On macOS, open the app and return to the script after login
        print_info "Opening Google Drive application..."
        open -a "Google Drive"
        echo -e "${YELLOW}Please login with your $ACCOUNT_TYPE Google account in the opened window.${NC}"
        echo -e "${YELLOW}After login, press Enter to continue...${NC}"
        read -p ""
        
    elif [[ "$os" == "linux" ]]; then
        # On Linux, configure google-drive-ocamlfuse
        if [[ "$ACCOUNT_TYPE" == "work" ]]; then
            google-drive-ocamlfuse -label work
        else
            google-drive-ocamlfuse -label personal
        fi
        
        # Create mount point
        MOUNT_POINT="$HOME/GoogleDrive-$ACCOUNT_TYPE"
        mkdir -p "$MOUNT_POINT"
        
        # Mount Google Drive
        if [[ "$ACCOUNT_TYPE" == "work" ]]; then
            google-drive-ocamlfuse -label work "$MOUNT_POINT"
        else
            google-drive-ocamlfuse -label personal "$MOUNT_POINT"
        fi
        
        DRIVE_PATH="$MOUNT_POINT"
    fi
    
    print_success "Google Drive login configured"
}

# Find Google Drive path
find_drive_path() {
    print_info "Finding Google Drive path..."
    
    if [[ "$os" == "macOS" ]]; then
        # On macOS, search for Google Drive directory
        PosSIBLE_PATHS=(
            "$HOME/Google Drive"
            "$HOME/Google Drive File Stream"
            "$HOME/Library/CloudStorage/GoogleDrive-*"
        )
        
        for path_pattern in "${PosSIBLE_PATHS[@]}"; do
            for path in $path_pattern; do
                if [ -d "$path" ]; then
                    DRIVE_PATH="$path"
                    print_info "Found Google Drive at: $DRIVE_PATH"
                    
                    # Verify if it's the correct directory
                    echo -e "${YELLOW}Is this the correct Google Drive path? $DRIVE_PATH (y/n)${NC}"
                    read -p "" confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        break 2
                    fi
                fi
            done
        done
        
        # If not found automatically, ask the user
        if [ -z "$DRIVE_PATH" ]; then
            print_alert "Could not automatically find Google Drive path"
            read -p "Please enter the full path to your Google Drive folder: " DRIVE_PATH
            
            if [ ! -d "$DRIVE_PATH" ]; then
                print_error "The provided path does not exist: $DRIVE_PATH"
            fi
        fi
    fi
    
    print_success "Google Drive path set to: $DRIVE_PATH"
}

# Create folder structure
create_folder_structure() {
    print_info "Creating folder structure..."
    
    # Ask for sync folder name
    print_alert "What name would you like to use for your sync folder?"
    print "Default: coder-ide-sync"
    read -p "Enter folder name (or press Enter for default): " folder_name
    
    if [ -z "$folder_name" ]; then
        folder_name="coder-ide-sync"
    fi
    
    # Check if the folder already exists
    SYNC_FOLDER="$DRIVE_PATH/Meu Drive/$folder_name"
    if [ -d "$SYNC_FOLDER" ]; then
        print_info "Sync folder already exists: $SYNC_FOLDER"
    else
        print_error "$SYNC_FOLDER"
        mkdir -p "$SYNC_FOLDER"
        print_success "Created sync folder: $SYNC_FOLDER"
    fi
    
    # Check if no-commit folder exists
    NO_COMMIT_FOLDER="$SYNC_FOLDER/no-commit"
    if [ -d "$NO_COMMIT_FOLDER" ]; then
        print_info "No-commit folder already exists: $NO_COMMIT_FOLDER"
    else
        mkdir -p "$NO_COMMIT_FOLDER"
        print_success "Created no-commit folder: $NO_COMMIT_FOLDER"
    fi
    
    # Ask if user wants to create more sync folders
    echo -e "${YELLOW}Do you want to create additional sync folders? (y/n)${NC}"
    read -p "" create_more
    
    while [[ "$create_more" == "y" || "$create_more" == "Y" ]]; do
        echo -e "${YELLOW}Enter name for additional sync folder:${NC}"
        read -p "" additional_folder
        
        if [ -n "$additional_folder" ]; then
            # Check if folder should be created in the same parent directory
            echo -e "${YELLOW}Create this folder inside $SYNC_FOLDER? (y/n)${NC}"
            read -p "" same_parent
            
            if [[ "$same_parent" == "y" || "$same_parent" == "Y" ]]; then
                ADDITIONAL_SYNC_FOLDER="$SYNC_FOLDER/$additional_folder"
            else
                ADDITIONAL_SYNC_FOLDER="$DRIVE_PATH/Meu Drive/$additional_folder"
            fi
            
            if [ -d "$ADDITIONAL_SYNC_FOLDER" ]; then
                print_info "Folder already exists: $ADDITIONAL_SYNC_FOLDER"
            else
                mkdir -p "$ADDITIONAL_SYNC_FOLDER"
                print_success "Created additional folder: $ADDITIONAL_SYNC_FOLDER"
            fi
        fi
        
        echo -e "${YELLOW}Create more sync folders? (y/n)${NC}"
        read -p "" create_more
    done
}

# Function to get environment directories
get_env_directories() {
    local env_file="$1"
    print_info "Loading directories from environment file: $env_file"
    
    # Load environment variables
    if [ -f "$env_file" ]; then
        source "$env_file"
        
        # Extract directory paths from environment variables
        # This is a simplified example - adjust according to your actual env file structure
        local dirs=()
        
        # Check for PROJECT_DIRS variable or similar in your env file
        if [ -n "$PROJECT_DIRS" ]; then
            IFS=',' read -ra dirs <<< "$PROJECT_DIRS"
            print_success "Found directories in environment: ${dirs[*]}"
            echo "${dirs[@]}"
        else
            print_info "No project directories found in environment file"
            echo ""
        fi
    else
        print_error "Environment file not found: $env_file"
        echo ""
    fi
}

# Setup symbolic links
setup_symlinks() {
    print_info "Setting up symbolic links..."
    
    # Create main symbolic link
    ln -sf "$SYNC_FOLDER" "$HOME/.coder-ide"
    print_success "Created main symbolic link: $HOME/.coder-ide -> $SYNC_FOLDER"
    
    # Select environment
    select_environment
    selected_env=$env_file
    
    # Get directories from environment file
    project_dirs=$(get_env_directories "$selected_env")
    
    # If no directories found in env file, use default directories
    if [ -z "$project_dirs" ]; then
        print_info "Using default project directories"
        mkdir -p "$HOME/projects-cit/flow/coder-assistants" 2>/dev/null
        mkdir -p "$HOME/projects-personal" 2>/dev/null
        
        # Create symbolic links for default projects
        ln -sf "$HOME/.coder-ide/no-commit" "$HOME/projects-cit/flow/coder-assistants/flow-coder-extension"
        ln -sf "$HOME/.coder-ide/no-commit" "$HOME/projects-personal/scripts-shell"
        
        # Add no-commit to .gitignore in each project
        echo "no-commit/" >> "$HOME/projects-cit/flow/coder-assistants/flow-coder-extension/.gitignore" 2>/dev/null
        echo "no-commit/" >> "$HOME/projects-personal/scripts-shell/.gitignore" 2>/dev/null
    else
        # Create symbolic links for projects from environment
        for dir in $project_dirs; do
            if [ -d "$dir" ]; then
                print_info "Creating symbolic link for $dir"
                ln -sf "$HOME/.coder-ide/no-commit" "$dir"
                
                # Add no-commit to .gitignore
                echo "no-commit/" >> "$dir/.gitignore" 2>/dev/null
                print_success "Added no-commit to .gitignore in $dir"
            else
                print_info "Creating directory: $dir"
                mkdir -p "$dir"
                ln -sf "$HOME/.coder-ide/no-commit" "$dir"
                echo "no-commit/" >> "$dir/.gitignore" 2>/dev/null
            fi
        done
    fi
    
    print_success "Created project symbolic links"
}

# Verify setup
verify_setup() {
    print_info "Verifying setup..."
    
    if [ -L "$HOME/.coder-ide" ]; then
        print_success "Main symbolic link is correctly set up"
    else
        print_alert "Main symbolic link was not created correctly"
    fi
    
    # Check project symlinks based on environment or default paths
    local symlinks_ok=true
    
    if [ -n "$project_dirs" ]; then
        # Check symlinks for environment-defined projects
        for dir in $project_dirs; do
            if [ ! -L "$dir/no-commit" ]; then
                print_alert "Symbolic link not correctly set up for: $dir/no-commit"
                symlinks_ok=false
            fi
        done
    else
        # Check default symlinks
        if [ ! -L "$HOME/projects-cit/flow/coder-assistants/flow-coder-extension/no-commit" ] || \
           [ ! -L "$HOME/projects-personal/scripts-shell/no-commit" ]; then
            print_alert "Some project symbolic links may not be correctly set up"
            symlinks_ok=false
        fi
    fi
    
    if $symlinks_ok; then
        print_success "Project symbolic links are correctly set up"
    fi
    
    print_info "Setup verification complete"
}

# Main function
sync_drive_folders() {
    print_header_info "Starting Google Drive folder sync setup..."

    if ! confirm_action "Do you want Google Drive Configuration ?"; then
        print_info "Skipping configuration"
        return 0
    fi
    
    load_env .env.personal
    load_env .env.work
    
    detect_os
    
    if ! check_drive_installed; then
        install_drive
    fi
    
    configure_drive_login
    find_drive_path
    create_folder_structure
    setup_symlinks
    verify_setup
    
    print_success "Google Drive folder sync setup completed successfully!"
    print_info "Your folders are now syncing with Google Drive at: $SYNC_FOLDER"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    sync_drive_folders "$@"
fi