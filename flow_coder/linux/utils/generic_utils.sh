#!/bin/bash

# Constants
OS_TYPE_MAC="Mac"
OS_TYPE_LINUX="Linux"

command_exists() {
    command -v "$1" &> /dev/null
}

cleanup_temp_files() {
    local temp_dir="$1"
    rm -rf "$temp_dir"
}

wait_for_user_confirmation() {
    local message="$1"
    print "$message"
    read -r
}

download_file() {
    local url=$1
    local output_file=$2
    
    if command_exists curl; then
        curl -L "$url" -o "$output_file"
        return $?
    elif command_exists wget; then
        wget -O "$output_file" "$url"
        return $?
    else
        print_error "Neither curl nor wget found. Please install one of these tools."
        return 1
    fi
}

confirm_action() {
  local prompt="$1"
  local choice
  
  read -p "$prompt (y/n): " choice
  case "$choice" in
    [Yy]* ) return 0 ;;
    * ) return 1 ;;
  esac
}
