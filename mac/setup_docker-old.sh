#!/bin/bash

# Update and install Homebrew if it is not installed
if ! command -v brew >/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Updating Homebrew..."
    brew update
fi

install_colima() {
    echo "Installing Colima..."
    brew install colima
    brew install docker
    brew install docker-compose
    brew install docker-credential-helper
    docker-credential-osxkeychain version

    colima start
    initialize_items
}

initialize_items() {
    SCRIPT_PATH="$HOME/start_colima.sh"
    echo "Creating script to start Colima..."
    echo "#!/bin/bash" > $SCRIPT_PATH
    echo "colima start" >> $SCRIPT_PATH
    chmod +x $SCRIPT_PATH
    
    LINE="~/start_colima.sh &"
    FILE=~/.zshrc
    if ! grep -qF "$LINE" "$FILE"; then
        echo "$LINE" >> "$FILE"
    fi
    source ~/.zshrc
    tail -n 1 ~/.zshrc
    echo "Colima is installed and running correctly."
}

install_docker_desktop() {
    echo "Installing Docker..."
    brew install --cask docker
}

install_rancher_desktop() {
    echo "Installing Rancher Desktop..."
    brew install --cask rancher-cli

    echo "Starting Rancher Desktop..."
    open -g -a Rancher\ Desktop
    
    echo "Waiting for Rancher Desktop to initialize..."
    sleep 60
    echo "Rancher Desktop should now be running."
}

if ! command -v docker >/dev/null; then
    echo "Docker is not installed."
    #install_docker_desktop
else
    echo "Docker is already installed."
    open -g -a Docker
fi

if ! command -v rancher-desktop >/dev/null; then
    echo "Rancher Desktop is not installed."
    #install_rancher_desktop
else
    echo "Rancher Desktop is already installed."
    open -g -a Rancher\ Desktop
fi

if ! command -v colima >/dev/null; then
    echo "Colima is not installed."
    install_colima
else
    echo "COLIMA is already installed."
    #colima start
    initialize_items
fi

docker --version
if docker run hello-world; then
    echo "Docker is installed and running correctly. The 'hello-world' container has been run successfully."
else
    echo "There was an issue verifying the Docker installation."
fi