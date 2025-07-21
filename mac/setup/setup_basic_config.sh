#!/bin/bash

# Import color utilities for messages
source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"
source "$(dirname "$0")/mac/install_homebrew.sh"

# Keyboard configuration
configure_keyboard() {
    print_header_info "Configuring keyboard..."
    
    # Swap Command and Control keys for all keyboards
    print_info "Swapping Command and Control keys for all keyboards..."
    
    # Global configuration for all keyboards
    defaults write NSGlobalDomain com.apple.keyboard.modifiermapping -array-add \
        '<dict>
            <key>HIDKeyboardModifierMappingDst</key>
            <integer>2</integer>
            <key>HIDKeyboardModifierMappingSrc</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>HIDKeyboardModifierMappingDst</key>
            <integer>0</integer>
            <key>HIDKeyboardModifierMappingSrc</key>
            <integer>2</integer>
        </dict>'
    
    # Add Portuguese -> Brazilian ABNT2 keyboard
    print_info "Adding Portuguese -> Brazilian ABNT2 keyboard..."
    defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
        '<dict>
            <key>InputSourceKind</key>
            <string>KeyboardLayout</string>
            <key>KeyboardLayout ID</key>
            <integer>1278</integer>
            <key>KeyboardLayout Name</key>
            <string>Portuguese</string>
        </dict>'
    
    # Show keyboard icon in menu bar to switch keyboards
    print_info "Enabling keyboard icon in menu bar..."
    defaults write com.apple.TextInputMenu visible -bool true
    
    # Configure FN key to switch keyboard layout
    print_info "Configuring FN key to switch keyboard layout..."
    defaults write com.apple.HIToolbox AppleFnUsageType -int 2
    
    return 0
}

# Trackpad configuration
configure_trackpad() {
    print_header_info "Configuring trackpad..."
    
    # Invert trackpad scroll direction (Natural Scrolling)
    print_info "Inverting trackpad scroll direction..."
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    
    return 0
}

# Appearance configuration
configure_appearance() {
    print_header_info "Configuring appearance..."
    
    # Enable dark mode
    print_info "Enabling dark mode..."
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    
    return 0
}

# Control center configuration
configure_control_center() {
    print_header_info "Configuring Control Center..." 
    
    # Enable sound icon in menu bar
    print_info "Enabling sound icon in menu bar..."
    defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
    
    # Enable bluetooth icon in menu bar
    print_info "Enabling bluetooth icon in menu bar..."
    defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
    
    # Enable temperature monitoring (CPU/GPU) icon in menu bar
    print_info "Enabling temperature monitoring in menu bar..."
    # Note: This usually requires a third-party app like iStat Menus
    defaults write com.bjango.istatmenus.status ShowCPU -bool true
    defaults write com.bjango.istatmenus.status ShowTemp -bool true
    
    return 0
}

# Dock configuration
configure_dock() {
    print_header_info "Configuring Dock..."
    
    # Reduce Dock size
    print_info "Reducing Dock size..."
    defaults write com.apple.dock tilesize -int 36
    
    # Hide and show Dock automatically
    print_info "Configuring Dock to auto-hide..."
    defaults write com.apple.dock autohide -bool false
    
    return 0
}

# Apply all changes
apply_changes() {
    print_info "Applying changes..."
    killall Dock 2>/dev/null || true
    killall ControlCenter 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
    
    return 0
}

# Configure all options
configure_all() {
    configure_keyboard
    configure_trackpad
    configure_appearance
    configure_control_center
    configure_dock
    apply_changes
    
    print_success "Basic macOS configuration completed!"
    print
    print_alert "Some changes may require a restart to take full effect."
    print
    
    return 0
}

add_dock_utilities() {
  print_header_info "Adding separator and utilities to Dock with dockutil..."
  install_dockutil

  # Remove duplicates if they already exist
  print_info "Removing duplicate items from Dock..."
  dockutil --remove "Disk Utility" --no-restart
  dockutil --remove "Activity Monitor" --no-restart
  dockutil --remove '' --section apps --no-restart  # remove blank separators

  # Add separator
  print_info "Adding separator to Dock..."
  dockutil --add '' --type spacer --after Finder --no-restart

  # Add Disk Utility
  print_info "Adding Disk Utility to Dock..."
  dockutil --add "/System/Applications/Utilities/Disk Utility.app" --no-restart

  # Add Activity Monitor
  print_info "Adding Activity Monitor to Dock..."
  dockutil --add "/System/Applications/Utilities/Activity Monitor.app" --no-restart

  # Restart Dock to apply changes
  print_info "Restarting Dock to apply changes..."
  killall Dock

  print_success "Dock configured successfully!"
}

install_dockutil() {
  print_info "Checking Homebrew installation..."
  
  # Use the install_homebrew function from mac/install_homebrew.sh script
  install_homebrew

  print_info "Checking dockutil installation..."

  if ! brew list dockutil &>/dev/null; then
    print_alert "Installing dockutil..."
    brew install dockutil
  else
    print_success "dockutil is already installed."
  fi

  print_success "All ready! You can use dockutil now."
}

open_utilities() {
  print_info "Opening Activity Monitor..."
  open -a "Activity Monitor"

  print_info "Opening Disk Utility..."
  open -a "Disk Utility"
}

setup_basic_config() {
    print_header_info "Basic Setup for MAC"

    if ! get_user_confirmation "Do you want Setup Basic Mac ?"; then
        print_info "Skipping configuration"
        return 0
    fi
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root/sudo."
        exit 1
    fi
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script only works on macOS systems."
        exit 1
    fi
    
    # Check arguments for selective execution
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: $0 [option]"
        echo "Options:"
        echo "  --keyboard    Configure keyboard only"
        echo "  --trackpad    Configure trackpad only"
        echo "  --appearance  Configure appearance only"
        echo "  --control     Configure control center only"
        echo "  --dock        Configure dock only"
        echo "  --all         Configure everything (default)"
        echo "  --help        Show this help"
        exit 0
    elif [[ "$1" == "--keyboard" ]]; then
        configure_keyboard
        apply_changes
    elif [[ "$1" == "--trackpad" ]]; then
        configure_trackpad
        apply_changes
    elif [[ "$1" == "--appearance" ]]; then
        configure_appearance
        apply_changes
    elif [[ "$1" == "--control" ]]; then
        configure_control_center
        apply_changes
    elif [[ "$1" == "--dock" ]]; then
        configure_dock
        add_dock_utilities
        open_utilities
        apply_changes
    else
        # Configure everything by default
        configure_all
    fi
    
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_basic_config "$@"
fi