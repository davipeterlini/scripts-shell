
#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors_message.sh"

# Function to execute a script with a description
execute_script() {
  local script_path=$1
  local description=$2

  if [ -f "$script_path" ]; then
    print_info "$description"
    bash "$script_path"
    print_success "Execution of script $script_path completed successfully."
  else
    print_error "The script $script_path was not found. Aborting."
  fi
}