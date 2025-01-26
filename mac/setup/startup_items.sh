#!/bin/bash

# Create a LaunchAgent plist file to start Colima at login
create_launch_agent() {
    local plist_file="$HOME/Library/LaunchAgents/com.startup.colima.plist"

    echo "Creating LaunchAgent plist file at $plist_file..."

    cat <<EOL > "$plist_file"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.startup.colima</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/colima</string>
        <string>start</string>
        <string>--memory</string>
        <string>2</string>
        <string>--cpu</string>
        <string>1</string>
        <string>--disk</string>
        <string>10</string>
        <string>--kubernetes</string>
        <string>false</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOL

    echo "Loading the LaunchAgent..."
    launchctl load "$plist_file"
}

# Main function to setup the startup item
main() {
    create_launch_agent
}

# Execute the main function
main