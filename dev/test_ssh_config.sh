#!/bin/bash

# Import color functions
source utils/colors_message.sh

# Function to test SSH connections
function test_ssh_connections() {
  print_info "Testing SSH connections..."

  local ssh_config_file="$HOME/.ssh/config"

  if [ ! -f "$ssh_config_file" ]; then
    print_alert "SSH configuration file not found at $ssh_config_file."
    exit 1
  fi

  # Detect configured hosts
  local hosts=$(grep -E "^Host " "$ssh_config_file" | awk '{print $2}')

  for host in $hosts; do
    # Ignore hosts with special characters like * or ?
    if [[ "$host" != *"*"* && "$host" != *"?"* ]]; then
      # Extract the real hostname
      local hostname=$(grep -A5 "^Host $host" "$ssh_config_file" | grep "HostName" | head -1 | awk '{print $2}')

      if [ -n "$hostname" ]; then
        print_info "Testing connection to $host ($hostname)..."

        # Attempt SSH connection
        test_connection "$host" "$hostname"
      fi
    fi
  done
}

# Function to test connection based on hostname
function test_connection() {
  local host="$1"
  local hostname="$2"

  case "$hostname" in
    "github.com")
      ssh -T git@"$host" -o BatchMode=yes -o ConnectTimeout=5 2>&1 | grep -q "successfully authenticated"
      ;;
    "bitbucket.org")
      ssh -T git@"$host" -o BatchMode=yes -o ConnectTimeout=5 2>&1 | grep -q "logged in as"
      ;;
    *)
      print_info "Skipping test for $host (unknown service)"
      return
      ;;
  esac

  if [ $? -eq 0 ]; then
    print_success "Connection to $host successful!"
  else
    print_alert "Connection to $host failed. Please check your SSH keys and configuration."
  fi
}

# Run the SSH connection tests
test_ssh_connections
