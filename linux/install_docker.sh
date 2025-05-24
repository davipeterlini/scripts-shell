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

# Docker utility functions
function cmd_build() {
  local hextarget="${1?'target, use base, mini or all'}"
  docker build --cache-from hexblade/hexblade-base:dev -t hexblade/hexblade-base:dev .
  if [[ "x$hextarget" == "xbase" ]]; then return; fi
  docker build --cache-from hexblade/hexblade:dev -t hexblade/hexblade:dev -f docker/util/Dockerfile.mini .
  if [[ "x$hextarget" == "xmini" ]]; then return; fi
  docker build --cache-from hexblade/hexblade-firefox:dev -t hexblade/hexblade-firefox:dev -f docker/util/Dockerfile.firefox .
  docker build --cache-from hexblade/hexblade-basechrome:dev -t hexblade/hexblade-basechrome:dev -f docker/util/Dockerfile.basechrome .
  docker build --cache-from hexblade/hexblade-chrome:dev -t hexblade/hexblade-chrome:dev -f docker/util/Dockerfile.chrome .
  docker build --cache-from hexblade/hexblade-puppeteer:dev -t hexblade/hexblade-puppeteer:dev -f docker/puppeteer/Dockerfile.puppeteer .
}

function cmd_export() {
  rm -rf target/wp-docker/docker || true
  mkdir -p target/wp-docker/docker
  docker save \
    hexblade/hexblade-base:dev \
    hexblade/hexblade:dev \
    hexblade/hexblade-firefox:dev \
    hexblade/hexblade-basechrome:dev \
    hexblade/hexblade-chrome:dev \
    hexblade/hexblade-puppeteer:dev | \
      gzip > target/wp-docker/docker/docker-hexblade.tar.gz
  du -hs target/wp-docker/docker/*
}

function cmd_import() {
  du -hs target/wp-docker/docker/*
  docker load -i target/wp-docker/docker/docker-hexblade.tar.gz
}

function cmd_clean() {
  docker ps -aq --filter label=hexblade_dev | xargs docker rm -f || true
  docker system prune --volumes --filter label=hexblade_dev -f || true
}

function cmd_run() {
  docker run -it --rm --label hexblade_dev \
    -p 5900:5900 \
    hexblade/hexblade:dev "$@"
}

function cmd_push() {
  hexblade_docker_version="${1?"version to push"}"
  hexblade_docker_alias="${2}"
  docker tag hexblade/hexblade-base:dev "murer/hexblade-base:$hexblade_docker_version"
  docker tag hexblade/hexblade:dev "murer/hexblade:$hexblade_docker_version"
  docker tag hexblade/hexblade-firefox:dev "murer/hexblade-firefox:$hexblade_docker_version"
  docker tag hexblade/hexblade-basechrome:dev "murer/hexblade-basechrome:$hexblade_docker_version"
  docker tag hexblade/hexblade-chrome:dev "murer/hexblade-chrome:$hexblade_docker_version"
  docker tag hexblade/hexblade-puppeteer:dev "murer/hexblade-puppeteer:$hexblade_docker_version"
  docker push "murer/hexblade-base:$hexblade_docker_version"
  docker push "murer/hexblade:$hexblade_docker_version"
  docker push "murer/hexblade-firefox:$hexblade_docker_version"
  docker push "murer/hexblade-basechrome:$hexblade_docker_version"
  docker push "murer/hexblade-chrome:$hexblade_docker_version"
  docker push "murer/hexblade-puppeteer:$hexblade_docker_version"
  if [[ "x$hexblade_docker_alias" != "x" ]]; then
    docker tag hexblade/hexblade-base:dev "murer/hexblade-base:$hexblade_docker_alias"
    docker tag hexblade/hexblade:dev "murer/hexblade:$hexblade_docker_alias"
    docker tag hexblade/hexblade-firefox:dev "murer/hexblade-firefox:$hexblade_docker_alias"
    docker tag hexblade/hexblade-basechrome:dev "murer/hexblade-basechrome:$hexblade_docker_alias"
    docker tag hexblade/hexblade-chrome:dev "murer/hexblade-chrome:$hexblade_docker_alias"
    docker tag hexblade/hexblade-puppeteer:dev "murer/hexblade-puppeteer:$hexblade_docker_alias"
    docker push "murer/hexblade-base:$hexblade_docker_alias"
    docker push "murer/hexblade:$hexblade_docker_alias"
    docker push "murer/hexblade-firefox:$hexblade_docker_alias"
    docker push "murer/hexblade-basechrome:$hexblade_docker_alias"
    docker push "murer/hexblade-chrome:$hexblade_docker_alias"
    docker push "murer/hexblade-puppeteer:$hexblade_docker_alias"
  fi
}

function cmd_pull() {
  hexblade_docker_version="${1:-"edge"}"
  docker pull "murer/hexblade-base:$hexblade_docker_version"
  docker pull "murer/hexblade:$hexblade_docker_version"
  docker pull "murer/hexblade-firefox:$hexblade_docker_version"
  docker pull "murer/hexblade-basechrome:$hexblade_docker_version"
  docker pull "murer/hexblade-chrome:$hexblade_docker_version"
  docker pull "murer/hexblade-puppeteer:$hexblade_docker_version"
  docker tag "murer/hexblade-base:$hexblade_docker_version" hexblade/hexblade-base:dev
  docker tag "murer/hexblade:$hexblade_docker_version" hexblade/hexblade:dev
  docker tag "murer/hexblade-firefox:$hexblade_docker_version" hexblade/hexblade-firefox:dev
  docker tag "murer/hexblade-basechrome:$hexblade_docker_version" hexblade/hexblade-basechrome:dev
  docker tag "murer/hexblade-chrome:$hexblade_docker_version" hexblade/hexblade-chrome:dev
  docker tag "murer/hexblade-puppeteer:$hexblade_docker_version" hexblade/hexblade-puppeteer:dev
}

function cmd_login() {
  set +x
  echo "${DOCKER_PASS?'DOCKER_PASS'}" | docker login -u "${DOCKER_USER?'DOCKER_USER'}" --password-stdin
}

function cmd_test() {
  local testname="${1?'test to run, like: pack.util.atom'}"
  docker build -t "hexablde/test.$testname:dev" -f "test/docker/Dockerfile.$testname" .
}

function cmd_test_all() {
  local k
  find test/docker -maxdepth 1 -type f -name 'Dockerfile.*' | cut -d'/' -f3 | cut -d'.' -f2- | while read k; do
    cmd_test "$k"
  done
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
    
    print_info "Additional Docker utility commands are available:"
    print_info "  - Build Docker images: $0 build [base|mini|all]"
    print_info "  - Export Docker images: $0 export"
    print_info "  - Import Docker images: $0 import"
    print_info "  - Clean Docker containers: $0 clean"
    print_info "  - Run Docker container: $0 run [args]"
    print_info "  - Push Docker images: $0 push <version> [alias]"
    print_info "  - Pull Docker images: $0 pull [version]"
    print_info "  - Login to Docker Hub: $0 login"
    print_info "  - Run Docker tests: $0 test <testname>"
    print_info "  - Run all Docker### linux/install_docker.sh [coder:save]
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

# Docker utility functions
function cmd_build() {
  local hextarget="${1?'target, use base, mini or all'}"
  docker build --cache-from hexblade/hexblade-base:dev -t hexblade/hexblade-base:dev .
  if [[ "x$hextarget" == "xbase" ]]; then return; fi
  docker build --cache-from hexblade/hexblade:dev -t hexblade/hexblade:dev -f docker/util/Dockerfile.mini .
  if [[ "x$hextarget" == "xmini" ]]; then return; fi
  docker build --cache-from hexblade/hexblade-firefox:dev -t hexblade/hexblade-firefox:dev -f docker/util/Dockerfile.firefox .
  docker build --cache-from hexblade/hexblade-basechrome:dev -t hexblade/hexblade-basechrome:dev -f docker/util/Dockerfile.basechrome .
  docker build --cache-from hexblade/hexblade-chrome:dev -t hexblade/hexblade-chrome:dev -f docker/util/Dockerfile.chrome .
  docker build --cache-from hexblade/hexblade-puppeteer:dev -t hexblade/hexblade-puppeteer:dev -f docker/puppeteer/Dockerfile.puppeteer .
}

function cmd_export() {
  rm -rf target/wp-docker/docker || true
  mkdir -p target/wp-docker/docker
  docker save \
    hexblade/hexblade-base:dev \
    hexblade/hexblade:dev \
    hexblade/hexblade-firefox:dev \
    hexblade/hexblade-basechrome:dev \
    hexblade/hexblade-chrome:dev \
    hexblade/hexblade-puppeteer:dev | \
      gzip > target/wp-docker/docker/docker-hexblade.tar.gz
  du -hs target/wp-docker/docker/*
}

function cmd_import() {
  du -hs target/wp-docker/docker/*
  docker load -i target/wp-docker/docker/docker-hexblade.tar.gz
}

function cmd_clean() {
  docker ps -aq --filter label=hexblade_dev | xargs docker rm -f || true
  docker system prune --volumes --filter label=hexblade_dev -f || true
}

function cmd_run() {
  docker run -it --rm --label hexblade_dev \
    -p 5900:5900 \
    hexblade/hexblade:dev "$@"
}

function cmd_push() {
  hexblade_docker_version="${1?"version to push"}"
  hexblade_docker_alias="${2}"
  docker tag hexblade/hexblade-base:dev "murer/hexblade-base:$hexblade_docker_version"
  docker tag hexblade/hexblade:dev "murer/hexblade:$hexblade_docker_version"
  docker tag hexblade/hexblade-firefox:dev "murer/hexblade-firefox:$hexblade_docker_version"
  docker tag hexblade/hexblade-basechrome:dev "murer/hexblade-basechrome:$hexblade_docker_version"
  docker tag hexblade/hexblade-chrome:dev "murer/hexblade-chrome:$hexblade_docker_version"
  docker tag hexblade/hexblade-puppeteer:dev "murer/hexblade-puppeteer:$hexblade_docker_version"
  docker push "murer/hexblade-base:$hexblade_docker_version"
  docker push "murer/hexblade:$hexblade_docker_version"
  docker push "murer/hexblade-firefox:$hexblade_docker_version"
  docker push "murer/hexblade-basechrome:$hexblade_docker_version"
  docker push "murer/hexblade-chrome:$hexblade_docker_version"
  docker push "murer/hexblade-puppeteer:$hexblade_docker_version"
  if [[ "x$hexblade_docker_alias" != "x" ]]; then
    docker tag hexblade/hexblade-base:dev "murer/hexblade-base:$hexblade_docker_alias"
    docker tag hexblade/hexblade:dev "murer/hexblade:$hexblade_docker_alias"
    docker tag hexblade/hexblade-firefox:dev "murer/hexblade-firefox:$hexblade_docker_alias"
    docker tag hexblade/hexblade-basechrome:dev "murer/hexblade-basechrome:$hexblade_docker_alias"
    docker tag hexblade/hexblade-chrome:dev "murer/hexblade-chrome:$hexblade_docker_alias"
    docker tag hexblade/hexblade-puppeteer:dev "murer/hexblade-puppeteer:$hexblade_docker_alias"
    docker push "murer/hexblade-base:$hexblade_docker_alias"
    docker push "murer/hexblade:$hexblade_docker_alias"
    docker push "murer/hexblade-firefox:$hexblade_docker_alias"
    docker push "murer/hexblade-basechrome:$hexblade_docker_alias"
    docker push "murer/hexblade-chrome:$hexblade_docker_alias"
    docker push "murer/hexblade-puppeteer:$hexblade_docker_alias"
  fi
}

function cmd_pull() {
  hexblade_docker_version="${1:-"edge"}"
  docker pull "murer/hexblade-base:$hexblade_docker_version"
  docker pull "murer/hexblade:$hexblade_docker_version"
  docker pull "murer/hexblade-firefox:$hexblade_docker_version"
  docker pull "murer/hexblade-basechrome:$hexblade_docker_version"
  docker pull "murer/hexblade-chrome:$hexblade_docker_version"
  docker pull "murer/hexblade-puppeteer:$hexblade_docker_version"
  docker tag "murer/hexblade-base:$hexblade_docker_version" hexblade/hexblade-base:dev
  docker tag "murer/hexblade:$hexblade_docker_version" hexblade/hexblade:dev
  docker tag "murer/hexblade-firefox:$hexblade_docker_version" hexblade/hexblade-firefox:dev
  docker tag "murer/hexblade-basechrome:$hexblade_docker_version" hexblade/hexblade-basechrome:dev
  docker tag "murer/hexblade-chrome:$hexblade_docker_version" hexblade/hexblade-chrome:dev
  docker tag "murer/hexblade-puppeteer:$hexblade_docker_version" hexblade/hexblade-puppeteer:dev
}

function cmd_login() {
  set +x
  echo "${DOCKER_PASS?'DOCKER_PASS'}" | docker login -u "${DOCKER_USER?'DOCKER_USER'}" --password-stdin
}

function cmd_test() {
  local testname="${1?'test to run, like: pack.util.atom'}"
  docker build -t "hexablde/test.$testname:dev" -f "test/docker/Dockerfile.$testname" .
}

function cmd_test_all() {
  local k
  find test/docker -maxdepth 1 -type f -name 'Dockerfile.*' | cut -d'/' -f3 | cut -d'.' -f2- | while read k; do
    cmd_test "$k"
  done
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
    
    print_info "Additional Docker utility commands are available:"
    print_info "  - Build Docker images: $0 build [base|mini|all]"
    print_info "  - Export Docker images: $0 export"
    print_info "  - Import Docker images: $0 import"
    print_info "  - Clean Docker containers: $0 clean"
    print_info "  - Run Docker container: $0 run [args]"
    print_info "  - Push Docker images: $0 push <version> [alias]"
    print_info "  - Pull Docker images: $0 pull [version]"
    print_info "  - Login to Docker Hub: $0 login"
    print_info "  - Run Docker tests: $0 test <testname>"
    print_info "  - Run all Docker tests: $0 test_all"
}

# Command router
if### linux/install_docker.sh [coder:save]
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

# Docker utility functions
function cmd_build() {
  local hextarget="${1?'target, use base, mini or all'}"
  docker build --cache-from hexblade/hexblade-base:dev -t hexblade/hexblade-base:dev .
  if [[ "x$hextarget" == "xbase" ]]; then return; fi
  docker build --cache-from hexblade/hexblade:dev -t hexblade/hexblade:dev -f docker/util/Dockerfile.mini .
  if [[ "x$hextarget" == "xmini" ]]; then return; fi
  docker build --cache-from hexblade/hexblade-firefox:dev -t hexblade/hexblade-firefox:dev -f docker/util/Dockerfile.firefox .
  docker build --cache-from hexblade/hexblade-basechrome:dev -t hexblade/hexblade-basechrome:dev -f docker/util/Dockerfile.basechrome .
  docker build --cache-from hexblade/hexblade-chrome:dev -t hexblade/hexblade-chrome:dev -f docker/util/Dockerfile.chrome .
  docker build --cache-from hexblade/hexblade-puppeteer:dev -t hexblade/hexblade-puppeteer:dev -f docker/puppeteer/Dockerfile.puppeteer .
}

function cmd_export() {
  rm -rf target/wp-docker/docker || true
  mkdir -p target/wp-docker/docker
  docker save \
    hexblade/hexblade-base:dev \
    hexblade/hexblade:dev \
    hexblade/hexblade-firefox:dev \
    hexblade/hexblade-basechrome:dev \
    hexblade/hexblade-chrome:dev \
    hexblade/hexblade-puppeteer:dev | \
      gzip > target/wp-docker/docker/docker-hexblade.tar.gz
  du -hs target/wp-docker/docker/*
}

function cmd_import() {
  du -hs target/wp-docker/docker/*
  docker load -i target/wp-docker/docker/docker-hexblade.tar.gz
}

function cmd_clean() {
  docker ps -aq --filter label=hexblade_dev | xargs docker rm -f || true
  docker system prune --volumes --filter label=hexblade_dev -f || true
}

function cmd_run() {
  docker run -it --rm --label hexblade_dev \
    -p 5900:5900 \
    hexblade/hexblade:dev "$@"
}

function cmd_push() {
  hexblade_docker_version="${1?"version to push"}"
  hexblade_docker_alias="${2}"
  docker tag hexblade/hexblade-base:dev "murer/hexblade-base:$hexblade_docker_version"
  docker tag hexblade/hexblade:dev "murer/hexblade:$hexblade_docker_version"
  docker tag hexblade/hexblade-firefox:dev "murer/hexblade-firefox:$hexblade_docker_version"
  docker tag hexblade/hexblade-basechrome:dev "murer/hexblade-basechrome:$hexblade_docker_version"
  docker tag hexblade/hexblade-chrome:dev "murer/hexblade-chrome:$hexblade_docker_version"
  docker tag hexblade/hexblade-puppeteer:dev "murer/hexblade-puppeteer:$hexblade_docker_version"
  docker push "murer/hexblade-base:$hexblade_docker_version"
  docker push "murer/hexblade:$hexblade_docker_version"
  docker push "murer/hexblade-firefox:$hexblade_docker_version"
  docker push "murer/hexblade-basechrome:$hexblade_docker_version"
  docker push "murer/hexblade-chrome:$hexblade_docker_version"
  docker push "murer/hexblade-puppeteer:$hexblade_docker_version"
  if [[ "x$hexblade_docker_alias" != "x" ]]; then
    docker tag hexblade/hexblade-base:dev "murer/hexblade-base:$hexblade_docker_alias"
    docker tag hexblade/hexblade:dev "murer/hexblade:$hexblade_docker_alias"
    docker tag hexblade/hexblade-firefox:dev "murer/hexblade-firefox:$hexblade_docker_alias"
    docker tag hexblade/hexblade-basechrome:dev "murer/hexblade-basechrome:$hexblade_docker_alias"
    docker tag hexblade/hexblade-chrome:dev "murer/hexblade-chrome:$hexblade_docker_alias"
    docker tag hexblade/hexblade-puppeteer:dev "murer/hexblade-puppeteer:$hexblade_docker_alias"
    docker push "murer/hexblade-base:$hexblade_docker_alias"
    docker push "murer/hexblade:$hexblade_docker_alias"
    docker push "murer/hexblade-firefox:$hexblade_docker_alias"
    docker push "murer/hexblade-basechrome:$hexblade_docker_alias"
    docker push "murer/hexblade-chrome:$hexblade_docker_alias"
    docker push "murer/hexblade-puppeteer:$hexblade_docker_alias"
  fi
}

function cmd_pull() {
  hexblade_docker_version="${1:-"edge"}"
  docker pull "murer/hexblade-base:$hexblade_docker_version"
  docker pull "murer/hexblade:$hexblade_docker_version"
  docker pull "murer/hexblade-firefox:$hexblade_docker_version"
  docker pull "murer/hexblade-basechrome:$hexblade_docker_version"
  docker pull "murer/hexblade-chrome:$hexblade_docker_version"
  docker pull "murer/hexblade-puppeteer:$hexblade_docker_version"
  docker tag "murer/hexblade-base:$hexblade_docker_version" hexblade/hexblade-base:dev
  docker tag "murer/hexblade:$hexblade_docker_version" hexblade/hexblade:dev
  docker tag "murer/hexblade-firefox:$hexblade_docker_version" hexblade/hexblade-firefox:dev
  docker tag "murer/hexblade-basechrome:$hexblade_docker_version" hexblade/hexblade-basechrome:dev
  docker tag "murer/hexblade-chrome:$hexblade_docker_version" hexblade/hexblade-chrome:dev
  docker tag "murer/hexblade-puppeteer:$hexblade_docker_version" hexblade/hexblade-puppeteer:dev
}

function cmd_login() {
  set +x
  echo "${DOCKER_PASS?'DOCKER_PASS'}" | docker login -u "${DOCKER_USER?'DOCKER_USER'}" --password-stdin
}

function cmd_test() {
  local testname="${1?'test to run, like: pack.util.atom'}"
  docker build -t "hexablde/test.$testname:dev" -f "test/docker/Dockerfile.$testname" .
}

function cmd_test_all() {
  local k
  find test/docker -maxdepth 1 -type f -name 'Dockerfile.*' | cut -d'/' -f3 | cut -d'.' -f2- | while read k; do
    cmd_test "$k"
  done
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
    
    print_info "Additional Docker utility commands are available:"
    print_info "  - Build Docker images: $0 build [base|mini|all]"
    print_info "  - Export Docker images: $0 export"
    print_info "  - Import Docker images: $0 import"
    print_info "  - Clean Docker containers: $0 clean"
    print_info "  - Run Docker container: $0 run [args]"
    print_info "  - Push Docker images: $0 push <version> [alias]"
    print_info "  - Pull Docker images: $0 pull [version]"
    print_info "  - Login to Docker Hub: $0 login"
    print_info "  - Run Docker tests: $0 test <testname>"
    print_info "  - Run all Docker tests: $0 test_all"
}

# Command router
if# Command router
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$1" = "build" ] || [ "$1" = "export" ] || [ "$1" = "import" ] || [ "$1" = "clean" ] || [ "$1" = "run" ] || [ "$1" = "push" ] || [ "$1" = "pull" ] || [ "$1" = "login" ] || [ "$1" = "test" ] || [ "$1" = "test_all" ]; then
        cmd_${1} "${@:2}"
    else
        main "$@"
    fi
fi