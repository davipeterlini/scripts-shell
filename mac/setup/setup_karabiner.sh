#!/bin/bash

source "$(dirname "$0")/utils/colors_message.sh"
source "$(dirname "$0")/utils/bash_tools.sh"

_check_brew_installed() {
    if ! command -v brew &> /dev/null; then
        print_alert "Homebrew is not installed."
        if get_user_confirmation "Do you want to install Homebrew now?"; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            print_error "Homebrew is required to continue. Aborting."
            exit 1
        fi
    else
        print_info "Homebrew is already installed."
    fi
}

_install_karabiner() {
    print_header_info "Karabiner-Elements"
    
    if brew list --cask karabiner-elements &>/dev/null; then
        print_success "Karabiner-Elements is already installed."
    else
        print_info "Karabiner-Elements is not installed."
        if get_user_confirmation "Do you want to install Karabiner-Elements now?"; then
            print_info "Installing Karabiner-Elements..."
            brew install --cask karabiner-elements
            
            if [ $? -eq 0 ]; then
                print_success "Karabiner-Elements installed successfully!"
            else
                print_error "Error installing Karabiner-Elements."
                exit 1
            fi
        else
            print_error "Karabiner-Elements is required to continue. Aborting."
            exit 1
        fi
    fi
}

_create_config_directory() {
    local config_dir="$HOME/.config/karabiner"
    
    if [ ! -d "$config_dir" ]; then
        print_info "Creating configuration directory..."
        mkdir -p "$config_dir"
    fi
    
    return 0
}

_initialize_karabiner_config() {
    print_info "Initializing Karabiner-Elements configuration"
    
    local config_file="$HOME/.config/karabiner/karabiner.json"
    local base_config_file="$(dirname "$0")/karabine_config/base_config.json"
    
    # Check if base configuration file exists
    if [ ! -f "$base_config_file" ]; then
        print_error "Base configuration file not found: $base_config_file"
        exit 1
    fi
    
    # Check if configuration file already exists
    if [ -f "$config_file" ]; then
        print_info "Configuration file found."
        if get_user_confirmation "Do you want to backup the current configuration?"; then
            local backup_file="${config_file}.backup.$(date +%Y%m%d%H%M%S)"
            cp "$config_file" "$backup_file"
            print_success "Backup created at: $backup_file"
        fi
        
        # Check if file has the necessary structure
        if ! jq -e '.profiles[0].complex_modifications' "$config_file" > /dev/null 2>&1; then
            print_alert "The existing configuration file does not have the necessary structure."
            if get_user_confirmation "Do you want to replace with the base configuration file?"; then
                cp "$base_config_file" "$config_file"
                print_success "Configuration file replaced successfully."
            else
                print_error "Cannot continue without the correct structure. Aborting."
                exit 1
            fi
        fi
    else
        print_info "Creating new configuration file..."
        # Copy the base configuration file
        cp "$base_config_file" "$config_file"
        print_success "Configuration file created at: $config_file"
    fi
    
    # Garantir que a estrutura complex_modifications.rules exista
    local temp_file=$(mktemp)
    jq '
        if .profiles[0].complex_modifications.rules == null then
            .profiles[0].complex_modifications.rules = []
        else
            .
        end
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    return 0
}

_restart_karabiner() {
    print_header "Restarting Karabiner-Elements"
    
    if get_user_confirmation "Do you want to restart Karabiner-Elements to apply the changes?"; then
        print_info "Trying to restart Karabiner-Elements..."
        
        # Method 1: Try to restart using launchctl
        if launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server &>/dev/null; then
            print_success "Karabiner-Elements restarted successfully!"
            return 0
        else
            print_alert "Could not restart the service using launchctl. Trying alternative method..."
        fi
        
        # Method 2: Try to quit and restart the application
        if pkill -f "karabiner"; then
            print_info "Karabiner processes terminated. Restarting the application..."
            sleep 2
        fi
        
        # Open the Karabiner-Elements application
        if open -a "Karabiner-Elements"; then
            print_success "Karabiner-Elements started successfully!"
            
            # Give time for Karabiner-Elements to start and detect devices
            print_info "Waiting for Karabiner-Elements to initialize (10 seconds)..."
            sleep 10
        else
            print_alert "Could not open Karabiner-Elements automatically."
            print_info "Please open Karabiner-Elements manually to apply the changes."
            print_info "You can find it in the Applications folder or using Spotlight (Cmd+Space)."
        fi
    else
        print_alert "The changes will only take effect after restarting Karabiner-Elements."
    fi
}

_ensure_jq_installed() {
    if ! command -v jq &> /dev/null; then
        print_alert "jq is not installed."
        if get_user_confirmation "Do you want to install jq now? (required to process JSON files)"; then
            print_info "Installing jq..."
            brew install jq
        else
            print_error "jq is required to continue. Aborting."
            exit 1
        fi
    fi
}

_rule_exists() {
    local config_file="$1"
    local rule_description="$2"
    
    # Check if a rule with the same description already exists
    # First we check if the complex_modifications.rules structure exists
    if ! jq -e '.profiles[0].complex_modifications.rules' "$config_file" > /dev/null 2>&1; then
        return 1  # Structure doesn't exist, so the rule doesn't exist
    fi
    
    # Now we check if there's a rule with the specified description
    local existing_rule=$(jq -r --arg desc "$rule_description" '.profiles[0].complex_modifications.rules[] | select(.description == $desc) | .description' "$config_file")
    
    if [ -n "$existing_rule" ]; then
        return 0  # Rule exists
    else
        return 1  # Rule doesn't exist
    fi
}

_remove_rule() {
    local config_file="$1"
    local rule_description="$2"
    local temp_file=$(mktemp)
    
    # Remove the rule with the specified description
    jq --arg desc "$rule_description" '
        if .profiles[0].complex_modifications.rules != null then
            .profiles[0].complex_modifications.rules = [.profiles[0].complex_modifications.rules[] | select(.description != $desc)]
        else
            .
        end
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    return $?
}

_check_karabiner_running() {
    if ! pgrep -q "karabiner"; then
        print_alert "Karabiner-Elements is not running."
        if get_user_confirmation "Do you want to start Karabiner-Elements now?"; then
            print_info "Starting Karabiner-Elements..."
            open -a "Karabiner-Elements"
            
            # Give time for Karabiner-Elements to start and detect devices
            print_info "Waiting for Karabiner-Elements to initialize (10 seconds)..."
            sleep 10
            
            # Check again if it's running
            if ! pgrep -q "karabiner"; then
                print_error "Could not start Karabiner-Elements. Please start it manually."
                return 1
            fi
        else
            print_error "Karabiner-Elements needs to be running to continue. Aborting."
            return 1
        fi
    fi
    
    return 0
}

_initialize_default_profile_with_all_keyboards() {
    local config_file="$HOME/.config/karabiner/karabiner.json"
    local temp_file=$(mktemp)
    
    print_info "Initializing default profile with all available keyboards..."
    
    # Check if the configuration file exists
    if [ ! -f "$config_file" ]; then
        print_error "Karabiner configuration file not found: $config_file"
        return 1
    fi
    
    # Check if there are devices in the configuration
    if ! jq -e '.devices' "$config_file" > /dev/null 2>&1; then
        print_alert "No devices found in Karabiner configuration."
        print_info "Please wait while Karabiner-Elements detects your devices..."
        return 1
    fi
    
    # Create a list of devices for the default profile
    jq '
        if .devices then
            .profiles[0].devices = [
                .devices[] | 
                select(.is_keyboard == true or .is_keyboard == null) | 
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": .product_id,
                        "vendor_id": .vendor_id
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "simple_modifications": []
                }
            ]
        else
            .
        end
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    
    if [ $? -eq 0 ]; then
        print_success "Default profile initialized with all available keyboards!"
        return 0
    else
        print_error "Error initializing the default profile."
        return 1
    fi
}

_list_available_keyboards() {
    print_header "Available Keyboards"
    
    local config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Check if the configuration file exists
    if [ ! -f "$config_file" ]; then
        print_error "Karabiner configuration file not found: $config_file"
        return 1
    fi
    
    # Check if Karabiner-Elements is running
    _check_karabiner_running || return 1
    
    # Extract the list of devices
    local devices=$(jq -r '.devices[] | select(.is_keyboard == true or .is_keyboard == null) | "\(.vendor_id):\(.product_id):\(.name // "Keyboard without name")"' "$config_file" 2>/dev/null)
    
    if [ -z "$devices" ]; then
        print_alert "No keyboards found in Karabiner configuration."
        print_info "Please check if your keyboards are connected and if Karabiner-Elements detected them."
        
        # Try to initialize the profile with all available devices
        if get_user_confirmation "Do you want to try using all available devices?"; then
            _initialize_default_profile_with_all_keyboards
            return 0
        else
            return 1
        fi
    fi
    
    # Display the list of keyboards
    print_info "The following keyboards are available:"
    echo ""
    
    local count=0
    while IFS=: read -r vendor_id product_id name; do
        count=$((count + 1))
        print_yellow "$count) $name"
        print "   ID: $vendor_id:$product_id"
    done <<< "$devices"
    
    echo ""
    return 0
}

_select_keyboard() {
    local config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Extract the list of devices
    local devices=$(jq -r '.devices[] | select(.is_keyboard == true or .is_keyboard == null) | "\(.vendor_id):\(.product_id):\(.name // "Keyboard without name")"' "$config_file" 2>/dev/null)
    
    if [ -z "$devices" ]; then
        print_error "No keyboards found in Karabiner configuration."
        
        # Try to use the internal keyboard as fallback
        if get_user_confirmation "Do you want to use the internal keyboard as fallback?"; then
            echo "1452:610:Apple Internal Keyboard"
            return 0
        else
            return 1
        fi
    fi
    
    # Count the number of devices
    local device_count=$(echo "$devices" | wc -l | tr -d ' ')
    
    # Ask the user to select a keyboard
    local selection
    while true; do
        print_info "Enter the number of the keyboard you want to configure (1-$device_count):"
        read -r selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "$device_count" ]; then
            break
        else
            print_error "Invalid selection. Please enter a number between 1 and $device_count."
        fi
    done
    
    # Get the selected device
    local selected_device=$(echo "$devices" | sed -n "${selection}p")
    
    # Return the selected device
    echo "$selected_device"
    return 0
}

_enable_keyboard_for_profile() {
    local config_file="$HOME/.config/karabiner/karabiner.json"
    local device_info="$1"  # formato: vendor_id:product_id:name
    local profile_index="$2"  # profile index (usually 0 for the default profile)
    
    # Extract vendor_id and product_id
    IFS=: read -r vendor_id product_id name <<< "$device_info"
    
    print_info "Enabling keyboard '$name' for the profile..."
    
    # Create a temporary file
    local temp_file=$(mktemp)
    
    # Check if the profile already has devices configured
    local has_devices=$(jq -r --argjson idx "$profile_index" '.profiles[$idx].devices != null' "$config_file")
    
    if [ "$has_devices" = "true" ]; then
        # Add the device to the existing list
        jq --arg vendor "$vendor_id" --arg product "$product_id" --argjson profile_idx "$profile_index" '
            .profiles[$profile_idx].devices += [
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": $product,
                        "vendor_id": $vendor
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "simple_modifications": []
                }
            ]
        ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    else
        # Create a new list of devices
        jq --arg vendor "$vendor_id" --arg product "$product_id" --argjson profile_idx "$profile_index" '
            .profiles[$profile_idx].devices = [
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": $product,
                        "vendor_id": $vendor
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "simple_modifications": []
                }
            ]
        ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Keyboard '$name' enabled successfully for the profile!"
        return 0
    else
        print_error "Error enabling keyboard '$name' for the profile."
        return 1
    fi
}

_apply_config_from_file() {
    local config_file_path="$1"
    local auto_apply="$2"  # If set to "yes", applies automatically without asking
    local karabiner_config_file="$HOME/.config/karabiner/karabiner.json"
    
    # Check if the configuration file exists
    if [ ! -f "$config_file_path" ]; then
        print_error "Configuration file not found: $config_file_path"
        return 1
    fi
    
    # Show configuration description
    local title=$(jq -r '.title' "$config_file_path")
    local description=$(jq -r '.rules[0].description' "$config_file_path")
    
    print_header_info "Configuring: $title"
    print_info "Description: $description"
    
    # Check if the rule already exists and remove it automatically
    if _rule_exists "$karabiner_config_file" "$description"; then
        print_info "The rule '$description' already exists in the configuration. Removing to overwrite..."
        _remove_rule "$karabiner_config_file" "$description"
    fi
    
    if [ "$auto_apply" = "yes" ] || get_user_confirmation "Do you want to apply this configuration?"; then
        local temp_file=$(mktemp)
        print_info "Adding rule: $description"
        
        # Extract the rules from the JSON file
        local rules=$(jq -c '.rules' "$config_file_path")
        
        # Add the rules to the configuration file
        jq --argjson new_rules "$rules" '
            if .profiles[0].complex_modifications.rules == null then
                .profiles[0].complex_modifications.rules = $new_rules
            else
                .profiles[0].complex_modifications.rules += $new_rules
            end
        ' "$karabiner_config_file" > "$temp_file" && mv "$temp_file" "$karabiner_config_file"
        
        print_success "Configuration '$title' added successfully!"
    else
        print_alert "Configuration '$title' was not applied."
    fi
}

list_available_configs() {
    print_header "Available Configurations"
    
    local config_dir="$(dirname "$0")/karabine_config/configs"
    
    if [ ! -d "$config_dir" ]; then
        print_error "Configurations directory not found: $config_dir"
        return 1
    fi
    
    print_info "The following configurations are available:"
    echo ""
    
    local count=0
    for config_file in "$config_dir"/*.json; do
        if [ -f "$config_file" ]; then
            count=$((count + 1))
            local filename=$(basename "$config_file" .json)
            local title=$(jq -r '.title // "No title"' "$config_file")
            local description=$(jq -r '.rules[0].description // "No description"' "$config_file")
            print_yellow "- $filename: $title"
            print "  $description"
        fi
    done
    
    if [ $count -eq 0 ]; then
        print_alert "No configurations found in directory: $config_dir"
    fi
    
    echo ""
    print "To apply a specific configuration, run:"
    print_yellow "  $0 <configuration_name>"
    echo ""
    print "To apply all configurations, run:"
    print_yellow "  $0 all"
    print ""
    print "To apply all configurations without additional confirmations:"
    print_yellow "  $0 all auto"
}

apply_config() {
    local config_name="$1"
    local auto_apply="$2"  # If set to "yes", applies automatically without asking
    local config_file="$(dirname "$0")/karabine_config/configs/${config_name}.json"
    
    # Check if the file exists
    if [ -f "$config_file" ]; then
        _apply_config_from_file "$config_file" "$auto_apply"
    else
        print_error "Configuration '$config_name' not found."
        print_info "Run '$0 list' to see available configurations."
        return 1
    fi
}

apply_all_configs() {
    local auto_apply="$1"  # If set to "yes", applies automatically without asking
    local config_dir="$(dirname "$0")/karabine_config/configs"
    
    if [ ! -d "$config_dir" ]; then
        print_error "Configurations directory not found: $config_dir"
        return 1
    fi
    
    local file_count=$(find "$config_dir" -name "*.json" | wc -l | tr -d ' ')
    
    if [ "$file_count" -eq 0 ]; then
        print_alert "No configurations found in directory: $config_dir"
        return 1
    fi
    
    if [ "$auto_apply" = "yes" ] || get_user_confirmation "Do you want to apply ALL $file_count available configurations?"; then
        local count=0
        
        for config_file in "$config_dir"/*.json; do
            if [ -f "$config_file" ]; then
                count=$((count + 1))
                print_header "Configuration $count of $file_count"
                _apply_config_from_file "$config_file" "yes"  # Apply automatically without asking again
            fi
        done
        
        print_success "All $count configurations have been processed."
    else
        print_alert "Operation cancelled by user."
    fi
}

configure_keyboards() {
    local command="$1"
    local auto_apply="$2"
    
    # Check if Karabiner-Elements is running
    _check_karabiner_running || return 1
    
    # Initialize the default profile with all available keyboards
    _initialize_default_profile_with_all_keyboards
    
    # List the available keyboards
    _list_available_keyboards || {
        print_alert "Could not list available keyboards."
        print_info "Applying configurations to all keyboards..."
        
        # Apply the configurations according to the command
        case "$command" in
            "list")
                list_available_configs
                ;;
            "all")
                apply_all_configs "$auto_apply"
                ;;
            *)
                # Check if the command is a filename without extension
                if [ -f "$(dirname "$0")/karabine_config/configs/${command}.json" ]; then
                    apply_config "$command" "$auto_apply"
                else
                    print_error "Unknown command or configuration: $command"
                    print_info "Run '$0 list' to see available configurations."
                    return 1
                fi
                ;;
        esac
        
        return 0
    }
    
    # Continue configuring keyboards until the user decides to stop
    local continue_config="yes"
    while [ "$continue_config" = "yes" ]; do
        # Select a keyboard
        local selected_keyboard=$(_select_keyboard)
        
        if [ -z "$selected_keyboard" ]; then
            print_error "Failed to select keyboard. Aborting."
            return 1
        fi
        
        # Extract the keyboard name
        local keyboard_name=$(echo "$selected_keyboard" | cut -d':' -f3)
        print_header "Configuring keyboard: $keyboard_name"
        
        # Enable the keyboard for the default profile (index 0)
        _enable_keyboard_for_profile "$selected_keyboard" 0
        
        # Apply the configurations according to the command
        case "$command" in
            "list")
                list_available_configs
                ;;
            "all")
                apply_all_configs "$auto_apply"
                ;;
            *)
                # Check if the command is a filename without extension
                if [ -f "$(dirname "$0")/karabine_config/configs/${command}.json" ]; then
                    apply_config "$command" "$auto_apply"
                else
                    print_error "Unknown command or configuration: $command"
                    print_info "Run '$0 list' to see available configurations."
                    return 1
                fi
                ;;
        esac
        
        # Ask if they want to configure another keyboard
        if ! get_user_confirmation "Do you want to configure another keyboard?"; then
            continue_config="no"
        fi
    done
    
    # Restart Karabiner-Elements to apply the changes
    _restart_karabiner
    
    return 0
}

setup_karabiner() {
    local command="$1"
    local auto_mode="$2"  # If set to "auto", applies automatically without asking
    local auto_apply="no"

    if ! get_user_confirmation "Do you want to config Karabine?"; then
        print_info "Skipping Karabine configuration"
        return 0
    fi
    
    if [ "$auto_mode" = "auto" ]; then
        auto_apply="yes"
    fi
    
    _check_brew_installed
    _ensure_jq_installed
    _install_karabiner
    _create_config_directory
    _initialize_karabiner_config
    
    # If no command is provided, show the list of configurations
    if [ -z "$command" ]; then
        list_available_configs
        return 0
    fi
    
    # Configure specific keyboards
    configure_keyboards "$command" "$auto_apply"
    
    print_header "Configuration Completed"
    print_success "Karabiner-Elements has been configured successfully!"
    print_info "If Karabiner-Elements was not automatically restarted, please:"
    print "1. Open the Karabiner-Elements application manually"
    print "2. Check if the configurations were applied correctly"
    print "3. If you are using an external keyboard, you may need to configure it in Karabiner-Elements preferences"
    print "4. Make sure the external keyboard is enabled in the 'Devices' section of Karabiner-Elements"
    print "For language switching configurations to work, check if the keyboard shortcut"
    print "is configured correctly in System Preferences > Keyboard > Shortcuts > Input Sources."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_karabiner "$@"
fi