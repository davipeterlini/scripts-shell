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
}

# Check if Docker is installed
if ! command -v docker >/dev/null; then
    echo "Docker is not installed."
    install_docker
    echo "Docker has been installed."
else
    echo "Docker is already installed."
fi

# Start Docker app to ensure the service is up and running
echo "Ensuring Docker is running..."
open -a Docker

# Wait until Docker daemon is up and running
while ! docker system info > /dev/null 2>&1; do
    echo "Waiting for Docker to initialize..."
    sleep 5
done

echo "Docker is running successfully."

# Optionally, prompt user to allow Docker to start on login
read -p "Do you want Docker to start on login? (y/n) " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # This opens the Docker application preferences where the user can enable 'Start Docker Desktop when you log in'
    open -a Docker --args --preferences
    echo "Please enable 'Start Docker Desktop when you log in' in the Docker preferences."
fi

# Display Docker version and confirm successful Docker setup
docker --version
if docker run hello-world; then
    echo "Docker is installed and running correctly. The 'hello-world' container has been run successfully."
else
    echo "There was an issue verifying the Docker installation."
fi
