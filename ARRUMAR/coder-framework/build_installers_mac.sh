#!/bin/bash

# Remove existing build directory if it exists
rm -rf coder-framework/build

# Create directories for build outputs
mkdir -p coder-framework/build/mac
mkdir -p coder-framework/build/linux
mkdir -p coder-framework/build/windows

# Build macOS .dmg
echo "========================================"
echo "Building macOS .dmg"
echo "========================================"
pkgbuild --root coder-framework/install --identifier com.example.coder --version 1.0 --install-location /usr/local/bin coder-framework/build/mac/coder.pkg
hdiutil create coder-framework/build/mac/coder.dmg -volname "Coder Installer" -srcfolder coder-framework/build/mac/coder.pkg
echo -e "\033[0;32mBuild macOS .dmg completed.\033[0m"

# Build Linux .deb
echo "========================================"
echo "Building Linux .deb"
echo "========================================"
if ! command -v dpkg-deb &> /dev/null; then
    echo "dpkg-deb could not be found, installing it..."
    sudo apt-get install dpkg-dev
fi

# Create the DEBIAN control file
mkdir -p coder-framework/build/linux/coder/DEBIAN
cat <<EOF > coder-framework/build/linux/coder/DEBIAN/control
Package: coder
Version: 1.0
Section: base
Priority: optional
Architecture: all
Depends: python3, python3-pip
Maintainer: Your Name <your_email@example.com>
Description: Coder installation package
EOF

# Create directories for files to be installed
mkdir -p coder-framework/build/linux/coder/usr/local/bin

# Copy necessary files to the package structure
cp coder-framework/install/install_coder.sh coder-framework/build/linux/coder/usr/local/bin/install_coder.sh
# Adicione outros arquivos necessários aqui
# cp coder-framework/install/other_file coder-framework/build/linux/coder/usr/local/bin/

# Build the .deb package
dpkg-deb --build coder-framework/build/linux/coder
mv coder-framework/build/linux/coder.deb coder-framework/build/linux/coder_1.0_all.deb
echo -e "\033[0;32mBuild Linux .deb completed.\033[0m"

# Build Windows .exe
echo "========================================"
echo "Building Windows .exe"
echo "========================================"
if ! command -v makensis &> /dev/null; then
    echo "makensis could not be found, please install it first."
    exit 1
fi
if [ ! -f coder-framework/install/install_coder.bat ]; then
    echo "install_coder.bat not found in coder-framework/install/"
    exit 1
fi
cp coder-framework/install/install_coder.bat coder-framework/build/windows/install_coder.bat
makensis -V4 -DOutFile=coder-framework/build/windows/coder_installer.exe -DInstallDir=$PROGRAMFILES\Coder -DSourceDir=coder-framework/build/windows coder-framework/install_coder.nsi
echo -e "\033[0;32mBuild Windows .exe completed.\033[0m"

echo "Build completed. Installers are located in the coder-framework/build directory."