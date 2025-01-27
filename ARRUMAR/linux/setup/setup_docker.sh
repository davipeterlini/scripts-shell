#!/bin/bash

# Update existing list of packages
echo "Updating package database..."
sudo apt update

# Install prerequisite packages which let apt use packages over HTTPS
echo "Installing prerequisites..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add the GPG key for the official Docker repository to the system
echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository to APT sources
echo "Adding Docker's repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package database with Docker packages from the newly added repo
echo "Updating package database..."
sudo apt update

# Ensure installation from the Docker repo instead of the default Ubuntu repo
echo "Ensuring installation from the Docker repo..."
apt-cache policy docker-ce

# Finally, install Docker
echo "Installing Docker..."
sudo apt install -y docker-ce

# Add current user to the Docker group to avoid needing to use sudo with Docker
echo "Adding current user to the Docker group..."
sudo usermod -aG docker ${USER}

# Prompt the user that they need to log out and back in for this to take effect
echo "Docker installation is now complete. Please log out and then log back in so that your group membership is re-evaluated."

# Install Docker Compose (optional)
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Test Docker installation
echo "Testing Docker installation..."
docker --version
if [ $? -eq 0 ]; then
    echo "Docker was installed successfully!"
    # Test running a Docker container
    echo "Running 'Hello World' container to confirm Docker is working..."
    docker run hello-world
else
    echo "Docker installation failed."
fi