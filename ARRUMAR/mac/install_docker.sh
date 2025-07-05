#!/bin/bash

# Load utility scripts
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(dirname "$SCRIPT_DIR")
source "$ROOT_DIR/utils/colors_message.sh"
source "$ROOT_DIR/utils/detect_os.sh"
source "$ROOT_DIR/mac/install_homebrew.sh"

# Function to install Docker and related tools
install_docker_tools() {
    print_info "Installing Docker CLI, Docker Compose, and Colima..."
    
    # Install Docker CLI and Docker Compose
    brew install docker docker-compose
    
    # Install Colima (Container runtimes on macOS)
    brew install colima
    
    print_success "Docker tools installed successfully!"
}

# Function to start Colima with custom configuration
start_colima() {
    print_info "Starting Colima with custom configuration..."
    
    # Stop Colima if it's already running
    colima stop 2>/dev/null || true
    
    # Start Colima with custom configuration
    # Default: 2 CPUs, 2GB memory, 10GB disk
    colima start --cpu 2 --memory 2 --disk 10
    
    print_success "Colima started successfully!"
}

# Function to configure Docker credentials
configure_docker_credentials() {
    print_info "Configuring Docker credentials..."
    
    # Create Docker config directory if it doesn't exist
    mkdir -p ~/.docker
    
    # Create config.json with the exact specified content
    echo '{
    "auths": {},
    "HttpHeaders": {
    "User-Agent": "Docker-Client/20.10.8 (darwin)"
    }
}' > ~/.docker/config.json
    
    print_success "Docker credentials configured successfully with the specified format!"
}

# Function to verify Docker installation
verify_docker_installation() {
    print_info "Verifying Docker installation..."
    
    # Check Docker CLI
    if ! command -v docker &> /dev/null; then
        print_error "Docker CLI is not installed or not in PATH"
        return 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        return 1
    fi
    
    # Check Colima
    if ! command -v colima &> /dev/null; then
        print_error "Colima is not installed or not in PATH"
        return 1
    fi
    
    # Check if Docker daemon is running via Colima
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running. Make sure Colima is started."
        return 1
    fi
    
    # Verify config.json has the correct content
    if [ ! -f ~/.docker/config.json ]; then
        print_error "Docker config.json file is missing"
        return 1
    fi
    
    print_success "Docker is installed and running correctly!"
    
    # Display Docker version information
    print_info "Docker version information:"
    docker version
    
    # Display Docker system information
    print_info "Docker system information:"
    docker info | grep -E 'Server Version|Operating System|OSType|Architecture|CPUs|Total Memory'
    
    return 0
}

# Function to add Docker to shell profile
add_to_shell_profile() {
    print_info "Adding Docker environment to shell profile..."
    
    # Detect shell profile
    if [ -f ~/.zshrc ]; then
        PROFILE=~/.zshrc
    elif [ -f ~/.bashrc ]; then
        PROFILE=~/.bashrc
    elif [ -f ~/.bash_profile ]; then
        PROFILE=~/.bash_profile
    else
        print_error "Could not detect shell profile"
        return 1
    fi
    
    # Add Docker environment setup to profile if not already present
    if ! grep -q "# Docker environment setup" "$PROFILE"; then
        echo "" >> "$PROFILE"
        echo "# Docker environment setup" >> "$PROFILE"
        echo 'if command -v colima &> /dev/null; then' >> "$PROFILE"
        echo '  # Check if Colima is running, start if not' >> "$PROFILE"
        echo '  if ! colima status 2>/dev/null | grep -q "Running"; then' >> "$PROFILE"
        echo '    echo "Starting Colima Docker environment..."' >> "$PROFILE"
        echo '    colima start' >> "$PROFILE"
        echo '  fi' >> "$PROFILE"
        echo 'fi' >> "$PROFILE"
        
        print_success "Added Docker environment setup to $PROFILE"
    else
        print_info "Docker environment setup already exists in $PROFILE"
    fi
}

# Main function
main() {
    # Check if running on macOS
    os=$(detect_os)
    if [ "$os" != "macOS" ]; then
        print_error "This script is intended for macOS only."
        exit 1
    fi
    
    # Ensure Homebrew is installed
    install_homebrew
    
    # Install Docker tools
    install_docker_tools
    
    # Start Colima
    start_colima
    
    # Configure Docker credentials with the exact specified format
    configure_docker_credentials
    
    # Add Docker to shell profile
    add_to_shell_profile
    
    # Verify installation
    verify_docker_installation
    
    print_success "Docker installation and configuration completed successfully!"
    print_info "You can now use Docker commands. To manage Docker, use the following commands:"
    print_info "  - Start Docker: colima start"
    print_info "  - Stop Docker: colima stop"
    print_info "  - Check status: colima status"
    print_info "  - Docker commands: docker [command]"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi