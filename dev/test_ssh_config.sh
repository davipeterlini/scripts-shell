#!/bin/bash

# Import color functions
source ../utils/colors_message.sh

# Testar conexões SSH
print_info "Testing SSH connections..."

SSH_CONFIG_FILE="$HOME/.ssh/config"

if [ ! -f "$SSH_CONFIG_FILE" ]; then
  print_alert "SSH configuration file not found at $SSH_CONFIG_FILE."
  exit 1
fi

# Detectar hosts configurados
hosts=$(grep -E "^Host " "$SSH_CONFIG_FILE" | awk '{print $2}')

for host in $hosts; do
  # Ignorar hosts com caracteres especiais como * ou ?
  if [[ "$host" != *"*"* && "$host" != *"?"* ]]; then
    # Extrair o hostname real
    hostname=$(grep -A5 "^Host $host" "$SSH_CONFIG_FILE" | grep "HostName" | head -1 | awk '{print $2}')

    if [ -n "$hostname" ]; then
      print_info "Testing connection to $host ($hostname)..."

      # Tentar conexão SSH
      if [[ "$hostname" == "github.com" ]]; then
        ssh -T git@"$host" -o BatchMode=yes -o ConnectTimeout=5 2>&1 | grep -q "successfully authenticated"
        if [ $? -eq 0 ]; then
          print_success "Connection to $host successful!"
        else
          print_alert "Connection to $host failed. Please check your SSH keys and configuration."
        fi
      elif [[ "$hostname" == "bitbucket.org" ]]; then
        ssh -T git@"$host" -o BatchMode=yes -o ConnectTimeout=5 2>&1 | grep -q "logged in as"
        if [ $? -eq 0 ]; then
          print_success "Connection to $host successful!"
        else
          print_alert "Connection to $host failed. Please check your SSH keys and configuration."
        fi
      else
        print_info "Skipping test for $host (unknown service)"
      fi
    fi
  fi
done
