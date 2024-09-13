#!/bin/bash

# Update and install Homebrew if it is not installed
if ! command -v brew >/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Updating Homebrew..."
    brew update
fi

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    brew install --cask docker
    # Start Docker app to ensure the service is up and running
    
    #echo "Starting Docker..."
    #open -g -a Docker
    
    # Wait until Docker daemon is up and running
    #while ! docker system info &> /dev/null; do
    #    echo "Waiting for Docker to initialize..."
    #    sleep 5
    #done
    #echo "Docker is running successfully."
}

# Function to install Rancher Desktop
install_rancher() {
    echo "Installing Rancher Desktop..."
    brew install --cask rancher-cli
    # Start Rancher Desktop app to ensure it is up and running
    echo "Starting Rancher Desktop..."
    open -g -a Rancher\ Desktop
    # Assuming it takes a minute for Rancher to start up; adjust based on your experience
    echo "Waiting for Rancher Desktop to initialize..."
    sleep 60
    echo "Rancher Desktop should now be running."
}

main() {
    # Check if Docker is installed
    if ! command -v docker >/dev/null; then
        echo "Docker is not installed."
        install_docker
    else
        echo "Docker is already installed."
        # Start Docker if it's not running
        #open -g -a Docker
    fi

    # Check if Rancher Desktop is installed
    if ! command -v rancher-desktop >/dev/null; then
        echo "Rancher Desktop is not installed."
        install_rancher
    else
        echo "Rancher Desktop is already installed."
        # Start Rancher Desktop if it's not running
        open -g -a Rancher\ Desktop
    fi

    # Display Docker version and test Docker installation
    docker --version
    if docker run hello-world; then
        echo "Docker is installed and running correctly. The 'hello-world' container has been run successfully."
    else
        echo "There was an issue verifying the Docker installation."
    fi

    # Additional commands for Rancher Desktop setup or checks can be added below as necessary
}

main