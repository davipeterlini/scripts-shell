#!/bin/bash

echo "Starting fundamental development applications for macOS..."

# Check and start Rancher Desktop
if open -Ra "Rancher Desktop"; then
    echo "Starting Rancher Desktop..."
    open -a Rancher\ Desktop
else
    echo "Rancher Desktop is not installed. Consider installing it via install_apps.sh."
fi

# Check and start Visual Studio Code
if open -Ra "Visual Studio Code"; then
    echo "Starting Visual Studio Code..."
    open -a Visual\ Studio\ Code
else
    echo "Visual Studio Code is not installed. Consider installing it via install_apps.sh."
fi

# Check and start iTerm2
if open -Ra "iTerm"; then
    echo "Starting iTerm2..."
    open -a iTerm
else
    echo "iTerm2 is not installed. Consider installing it via install_apps.sh."
fi

# Check and start Google Chrome
if open -Ra "Google Chrome"; then
    echo "Starting Google Chrome..."
    open -a "Google Chrome"
else
    echo "Google Chrome is not installed. Consider installing it via install_apps.sh."
fi

# Check and start Rambox
if open -Ra "Rambox"; then
    echo "Starting Rambox..."
    open -a Rambox
else
    echo "Rambox is not installed. Consider installing it via install_apps.sh."
fi

echo "All fundamental development applications have been checked and started where available."
