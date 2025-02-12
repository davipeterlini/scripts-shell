#!/bin/bash

# Remove existing build directory if it exists
rm -rf coder-framework/build

# Create directories for build outputs
mkdir -p coder-framework/build/mac
mkdir -p coder-framework/build/linux
mkdir -p coder-framework/build/windows

# Build macOS .dmg
echo "Building macOS .dmg..."
pkgbuild --root coder-framework/install --identifier com.example.coder --version 1.0 --install-location /usr/local/bin coder-framework/build/mac/coder.pkg
hdiutil create coder-framework/build/mac/coder.dmg -volname "Coder Installer" -srcfolder coder-framework/build/mac/coder.pkg

# Build Linux .deb
echo "Building Linux .deb..."
if ! command -v dpkg-deb &> /dev/null; then
    echo "dpkg-deb could not be found, installing it..."
    brew install dpkg
fi
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
mkdir -p coder-framework/build/linux/coder/usr/local/bin
cp coder-framework/install/install_coder.sh coder-framework/build/linux/coder/usr/local/bin/install_coder.sh
dpkg-deb --build coder-framework/build/linux/coder
mv coder-framework/build/linux/coder.deb coder-framework/build/linux/coder_1.0_all.deb

# Build Windows .exe
echo "Building Windows .exe..."
cp coder-framework/install/install_coder.bat coder-framework/build/windows/install_coder.bat
makensis -V4 -DOutFile=coder-framework/build/windows/coder_installer.exe -DInstallDir=$PROGRAMFILES\Coder -DSourceDir=coder-framework/build/windows coder-framework/install_coder.nsi

echo "Build completed. Installers are located in the coder-framework/build directory."