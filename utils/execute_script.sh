#!/bin/bash

# Function to execute a script with a description
execute_script() {
  local script_path=$1
  local description=$2

  if [ -f "$script_path" ]; then
    log "$description"
    bash "$script_path"
  else
    error_exit "O script $script_path não foi encontrado. Abortando."
  fi
}