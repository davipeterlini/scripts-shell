#!/bin/bash

# Function to detect the operating system
source utils/detect_os.sh

# Function to check if Docker is already installed
check_docker_installed() {
    if command -v docker &> /dev/null; then
        echo "Docker is already installed."
        docker --version
        docker-compose --version
        return 0
    fi
    return 1
}

# Function to check if Colima is already installed and running
check_colima_installed() {
    if command -v colima &> /dev/null; then
        echo "Colima is already installed."
        colima version
        if ! colima status | grep -q "Running"; then
            echo "Starting Colima..."
            colima start
        else
            echo "Colima is already running."
        fi
        return 0
    fi
    return 1
}

# Function to install Docker on macOS
install_docker_mac() {
    echo "Installing Docker on macOS..."
    install_homebrew
    brew install colima docker docker-compose
    start_colima
    colima nerdctl install
    echo "Docker installed successfully on macOS."
}

# Function to install Homebrew on macOS
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Function to start Colima if not running
start_colima() {
    if ! colima status | grep -q "Running"; then
        colima start
    fi
}

# Function to install Docker on Linux
install_docker_linux() {
    echo "Installing Docker on Linux..."
    detect_linux_distribution
    install_docker_based_on_distribution
    start_docker_service
    echo "Docker installed successfully on Linux."
}

# Function to detect Linux distribution
detect_linux_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$ID
    fi
}

# Function to install Docker based on Linux distribution
install_docker_based_on_distribution() {
    if [ "$OS_NAME" == "ubuntu" ]; then
        sudo apt-get update
        sudo apt-get install -y docker.io docker-compose
    elif [ "$OS_NAME" == "fedora" ]; then
        sudo dnf install -y docker docker-compose
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
}

# Function to start Docker service on Linux
start_docker_service() {
    sudo systemctl start docker
    sudo systemctl enable docker
}

# Function to install Docker on Windows
install_docker_windows() {
    echo "Installing Docker on Windows..."
    download_docker_desktop_installer
    run_docker_desktop_installer
    echo "Docker installed successfully on Windows."
}

# Function to download Docker Desktop installer for Windows
download_docker_desktop_installer() {
    curl -L "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -o DockerDesktopInstaller.exe
}

# Function to run Docker Desktop installer on Windows
run_docker_desktop_installer() {
    start DockerDesktopInstaller.exe
}

# Function to test Docker installation
test_docker() {
    echo "Testing Docker installation..."
    docker run hello-world
    if [ $? -eq 0 ]; then
        echo "Docker is running correctly."
    else
        echo "Docker test failed."
    fi
}

# Main script execution
main() {
    detect_os

    if [ "$OS" == "mac" ]; then
        check_colima_installed || install_docker_mac
        check_docker_installed || install_docker_mac
    elif [ "$OS" == "linux" ]; then
        check_docker_installed || install_docker_linux
    elif [ "$OS" == "windows" ]; then
        check_docker_installed || install_docker_windows
    else
        echo "Unsupported OS"
        exit 1
    fi

    # Verify Docker installation
    if [ "$OS" == "mac" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Reload shell to ensure Docker is in the PATH
    source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null

    # Ensure Docker is in the PATH for the current session
    if ! command -v docker &> /dev/null; then
        echo "Docker command not found. Please ensure Docker is installed and in your PATH."
        exit 1
    fi

    docker --version
    docker-compose --version

    # Test Docker installation
    test_docker
}

main