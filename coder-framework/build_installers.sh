#!/bin/bash

# Remove existing build directory if it exists
rm -rf coder-framework/build

# Create directories for build outputs
mkdir -p coder-framework/build/mac
mkdir -p coder-framework/build/linux
mkdir -p coder-framework/build/windows

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Starting Docker..."
    open --background -a Docker
    # Wait until Docker daemon is running
    while ! docker info > /dev/null 2>&1; do
        echo "Waiting for Docker to start..."
        sleep 2
    done
    echo "Docker started."
fi

# Build macOS .dmg using Docker
echo "Building macOS .dmg using Docker..."
docker run --rm -v "$(pwd)/coder-framework:/workspace" -w /workspace -e "USER=$(id -u)" -e "GROUP=$(id -g)" macos-docker:latest /bin/bash -c "
    pkgbuild --root install --identifier com.example.coder --version 1.0 --install-location /usr/local/bin build/mac/coder.pkg
    hdiutil create build/mac/coder.dmg -volname 'Coder Installer' -srcfolder build/mac/coder.pkg
"

# Build Linux .deb using Docker
echo "Building Linux .deb using Docker..."
docker run --rm -v "$(pwd)/coder-framework:/workspace" -w /workspace ubuntu:latest /bin/bash -c "
    apt-get update && apt-get install -y dpkg-dev
    mkdir -p build/linux/coder/DEBIAN
    cat <<EOF > build/linux/coder/DEBIAN/control
Package: coder
Version: 1.0
Section: base
Priority: optional
Architecture: all
Depends: python3, python3-pip
Maintainer: Your Name <your_email@example.com>
Description: Coder installation package
EOF
    mkdir -p build/linux/coder/usr/local/bin
    cp install/install_coder.sh build/linux/coder/usr/local/bin/install_coder.sh
    dpkg-deb --build build/linux/coder
    mv build/linux/coder.deb build/linux/coder_1.0_all.deb
"

# Build Windows .exe using Docker
echo "Building Windows .exe using Docker..."
docker run --rm -v "$(pwd)/coder-framework:/workspace" -w /workspace windows-docker:latest /bin/bash -c "
    cp install/install_coder.bat build/windows/install_coder.bat
    makensis -V4 -DOutFile=build/windows/coder_installer.exe -DInstallDir=\$PROGRAMFILES\Coder -DSourceDir=build/windows install_coder.nsi
"

echo "Build completed. Installers are located in the coder-framework/build directory."