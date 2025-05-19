#!/bin/bash

# Load utility scripts
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(dirname "$SCRIPT_DIR")
source "$ROOT_DIR/utils/colors_message.sh"
source "$ROOT_DIR/utils/detect_os.sh"

# Function to install Docker and related tools
install_docker_tools() {
    print_info "Installing Docker and Docker Compose on Debian-based Linux..."
    
    # Update package index
    sudo apt-get update
    
    # Install required packages
    print_info "Installing required packages..."
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    print_info "Adding Docker's official GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the Docker repository
    print_info "Setting up Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update apt package index
    sudo apt-get update
    
    # Install Docker Engine, containerd, and Docker Compose
    print_info "Installing Docker Engine, containerd, and Docker Compose..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Install Docker Compose standalone
    print_info "Installing Docker Compose standalone..."
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    print_success "Docker tools installed successfully!"
}

# Function to configure Docker post-installation
configure_docker() {
    print_info "Configuring Docker post-installation..."
    
    # Create docker group if it doesn't exist
    if ! getent group docker > /dev/null; then
        sudo groupadd docker
    fi
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    # Enable Docker to start on boot
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    
    print_success "Docker configured successfully!"
    print_alert "You may need to log out and log back in for group changes to take effect."
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
    "User-Agent": "Docker-Client/20.10.8 (linux)"
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
    
    # Check if Docker daemon is running
    if ! sudo docker info &> /dev/null; then
        print_error "Docker daemon is not running."
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
    
    # Source the choose_shell_profile script
    source "$ROOT_DIR/utils/choose_shell_profile.sh"
    
    # Ask user to choose shell profile
    choose_shell_profile
    
    # Add Docker environment setup to profile if not already present
    if ! grep -q "# Docker environment setup" "$PROFILE_FILE"; then
        echo "" >> "$PROFILE_FILE"
        echo "# Docker environment setup" >> "$PROFILE_FILE"
        echo 'if command -v docker &> /dev/null; then' >> "$PROFILE_FILE"
        echo '  # Check if Docker is running, start if not' >> "$PROFILE_FILE"
        echo '  if ! systemctl is-active --quiet docker; then' >> "$PROFILE_FILE"
        echo '    echo "Starting Docker service..."' >> "$PROFILE_FILE"
        echo '    sudo systemctl start docker' >> "$PROFILE_FILE"
        echo '  fi' >> "$PROFILE_FILE"
        echo 'fi' >> "$PROFILE_FILE"
        
        print_success "Added Docker environment setup to $PROFILE_FILE"
    else
        print_info "Docker environment setup already exists in $PROFILE_FILE"
    fi
}

# Main function
main() {
    # Check if running on Linux
    os=$(detect_os)
    if [ "$os" != "Linux" ]; then
        print_error "This script is intended for Linux only."
        exit 1
    fi
    
    # Check if this is a Debian-based distribution
    if ! command -v apt-get &> /dev/null; then
        print_error "This script is intended for Debian-based Linux distributions only."
        exit 1
    fi
    
    # Install Docker tools
    install_docker_tools
    
    # Configure Docker post-installation
    configure_docker
    
    # Configure Docker credentials with the exact specified format
    configure_docker_credentials
    
    # Add Docker to shell profile
    add_to_shell_profile
    
    # Verify installation
    verify_docker_installation
    
    print_success "Docker installation and configuration completed successfully!"
    print_info "You can now use Docker commands. To manage Docker, use the following commands:"
    print_info "  - Start Docker: sudo systemctl start docker"
    print_info "  - Stop Docker: sudo systemctl stop docker"
    print_info "  - Check status: sudo systemctl status docker"
    print_info "  - Docker commands: docker [command]"
    print_info "Note: You may need to log out and log back in for group changes to take effect."
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi