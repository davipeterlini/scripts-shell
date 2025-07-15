#!/bin/bash

print_usage() {
  echo "Usage: $0 [repo|scripts]"
  echo "  repo    - Grant permissions to all shell scripts in the entire repository"
  echo "  scripts - Grant permissions to all shell scripts in the scripts directory only (default)"
}

set_script_permissions() {
  local base_dir="$1"
  
  find "$base_dir" -type f -name "*.sh" 2>/dev/null | while read -r script; do
    print "Granting execute permission to: $script"
    chmod +x "$script"
  done
  print
  print_success "Permissions granted for all shell scripts under the target directory: $base_dir"
  print
}

grant_permissions() {
  print_header "Granting permissions for all scripts..."

  local current_dir="$(cd "$(dirname "$0")" && pwd)"
  
  # Configuration: Set the target directory
  # Default is "repo", but can be overridden by command line argument
  local target_dir="${1:-repo}" # Options: "repo" or "scripts"
  
  if [ "$target_dir" == "repo" ]; then
    # Use the current directory as the base for the entire repository
    print_info "Granting execute permissions to shell scripts in the entire repository: $current_dir"
    print
    set_script_permissions "$current_dir"
  elif [ "$target_dir" == "scripts" ]; then
    # Use the scripts subdirectory
    local scripts_dir="$current_dir/scripts"
    if [ -d "$scripts_dir" ]; then
      print_info "Granting execute permissions to shell scripts in the scripts directory: $scripts_dir"
      print
      set_script_permissions "$scripts_dir"
    else
      print_error "Scripts directory not found: $scripts_dir"
      return 1
    fi
  else
    print_error "Invalid target directory value. Use 'repo' or 'scripts'."
    print_usage
    return 1
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  grant_permissions "$@"
fi