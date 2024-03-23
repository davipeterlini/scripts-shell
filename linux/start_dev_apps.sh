#!/bin/bash

echo "Starting fundamental development applications for Linux..."

# Start Docker
if systemctl is-active --quiet docker; then
    echo "Docker is already running."
else
    echo "Starting Docker..."
    sudo systemctl start docker
fi

# Check and start Visual Studio Code
if hash code 2>/dev/null; then
    echo "Starting Visual Studio Code..."
    code &
else
    echo "Visual Studio Code is not installed. Consider installing it via install_apps.sh."
fi

# Check and start GNOME Terminal
if hash gnome-terminal 2>/dev/null; then
    echo "Starting GNOME Terminal..."
    gnome-terminal &
else
    echo "GNOME Terminal is not installed. Consider using your Linux distribution's package manager to install it."
fi

# Check and start Google Chrome
if hash google-chrome 2>/dev/null; then
    echo "Starting Google Chrome..."
    google-chrome &
else
    echo "Google Chrome is not installed. Consider installing it via install_apps.sh."
fi

# Check and start Rambox
if hash rambox 2>/dev/null; then
    echo "Starting Rambox..."
    rambox &
else
    echo "Rambox is not installed. Consider installing it via install_apps.sh."
fi

echo "All fundamental development applications have been checked and started where available."
