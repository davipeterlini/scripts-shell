#!/bin/bash

# Function to create the launchd configuration file
create_launchd_config() {
    local plist_file="$HOME/Library/LaunchAgents/com.user.colima-hibernation.plist"
    local user_name=$(whoami)
    local script_path="/Users/$user_name/colima_hibernation.sh"

    echo "Creating launchd configuration file at $plist_file..."

    cat <<EOL > "$plist_file"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.colima-hibernation</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$script_path</string>
        <string>sleep</string>
    </array>
    <key>WatchPaths</key>
    <array>
        <string>/private/var/vm/sleepimage</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOL

    echo "Setting permissions for the plist file..."
    chmod 644 "$plist_file"

    echo "Unloading the launchd agent if it is already loaded..."
    launchctl unload "$plist_file" 2>/dev/null

    echo "Loading the launchd agent..."
    launchctl load "$plist_file"
}

# Main function to setup the launchd scheduler
main() {
    create_launchd_config
}

# Execute the main function
main