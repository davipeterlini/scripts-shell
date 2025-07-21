#!/bin/bash

# Profile Writer Utility
# Manages writing to shell profiles (.zshrc, .bashrc, etc.) with proper logging

# =============================================================================
# CONFIGURATION
# =============================================================================

# Get absolute directory of current script
PROFILE_WRITER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required utilities
source "${PROFILE_WRITER_DIR}/colors_message.sh"
source "${PROFILE_WRITER_DIR}/detect_profile.sh"

# =============================================================================
# PRIVATE FUNCTIONS
# =============================================================================

# Function to get the name of the calling script
_get_calling_script() {
    local calling_script="${BASH_SOURCE[3]:-${BASH_SOURCE[2]:-${BASH_SOURCE[1]:-unknown}}}"
    if [[ "$calling_script" != "unknown" ]]; then
        basename "$calling_script"
    else
        echo "unknown_script"
    fi
}

# Function to get current timestamp
_get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Function to create a header comment for profile entries
_create_profile_header() {
    local script_name="$1"
    local timestamp="$2"
    
    cat << EOF

# =============================================================================
# Added by: $script_name
# Date: $timestamp
# =============================================================================
EOF
}

# Function to create a footer comment for profile entries
_create_profile_footer() {
    local script_name="$1"
    
    cat << EOF
# =============================================================================
# End of $script_name configuration
# =============================================================================

EOF
}

# Function to check if content already exists in profile
_content_exists_in_profile() {
    local profile_file="$1"
    local content="$2"
    
    if [[ -f "$profile_file" ]] && grep -Fxq "$content" "$profile_file"; then
        return 0
    else
        return 1
    fi
}

# Function to backup profile file
_backup_profile_file() {
    local profile_file="$1"
    local timestamp="$2"
    
    if [[ -f "$profile_file" ]]; then
        local backup_file="${profile_file}.backup.$(date -d "$timestamp" +%Y%m%d_%H%M%S 2>/dev/null || date -j -f '%Y-%m-%d %H:%M:%S' "$timestamp" +%Y%m%d_%H%M%S 2>/dev/null || echo $(date +%Y%m%d_%H%M%S))"
        cp "$profile_file" "$backup_file"
        print_info "Profile backup created: $backup_file"
        return 0
    fi
    return 1
}

# Function to ensure a backup is created before any profile modification
_ensure_profile_backup() {
    local profile_file="$1"
    local timestamp="$2"
    
    # Always create a backup before modifying the profile
    _backup_profile_file "$profile_file" "$timestamp"
}

# Function to validate profile file path
_validate_profile_file() {
    local profile_file="$1"
    
    # Check if it's a valid shell profile file
    case "$(basename "$profile_file")" in
        .bashrc|.bash_profile|.zshrc|.zsh_profile|.profile|.fish_profile)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# =============================================================================
# PUBLIC FUNCTIONS
# =============================================================================

# Function to write content to shell profile with logging
# Usage: write_to_profile "content" [profile_file] [create_backup]
write_to_profile() {
    local content="$1"
    local profile_file="${2:-}"
    local create_backup="${3:-true}"
    
    # Validate input
    if [[ -z "$content" ]]; then
        print_error "Content cannot be empty"
        return 1
    fi
    
    # Detect profile file if not provided
    if [[ -z "$profile_file" ]]; then
        profile_file=$(detect_profile)
        if [[ -z "$profile_file" ]]; then
            print_error "Could not detect shell profile file"
            return 1
        fi
    fi
    
    # Validate profile file
    if ! _validate_profile_file "$profile_file"; then
        print_error "Invalid profile file: $profile_file"
        return 1
    fi
    
    # Get metadata
    local script_name=$(_get_calling_script)
    local timestamp=$(_get_timestamp)
    
    # Check if content already exists
    if _content_exists_in_profile "$profile_file" "$content"; then
        print_info "Content already exists in $profile_file, skipping..."
        return 0
    fi
    
    # Always ensure a backup is created before modifying the profile
    _ensure_profile_backup "$profile_file" "$timestamp"
    
    # Create profile file if it doesn't exist
    if [[ ! -f "$profile_file" ]]; then
        touch "$profile_file"
        print_info "Created profile file: $profile_file"
    fi
    
    # Prepare the complete entry with header and footer
    local profile_header=$(_create_profile_header "$script_name" "$timestamp")
    local profile_footer=$(_create_profile_footer "$script_name")
    local complete_entry="${profile_header}${content}${profile_footer}"
    
    # Write to profile file
    echo "$complete_entry" >> "$profile_file"
    
    print_success "Content added to $profile_file by $script_name"
    print_info "Added at: $timestamp"
    
    return 0
}

# Function to write multiple lines to profile
# Usage: write_lines_to_profile "line1" "line2" "line3" [profile_file] [create_backup]
write_lines_to_profile() {
    local profile_file=""
    local create_backup="true"
    local lines=()
    
    # Parse arguments
    for arg in "$@"; do
        if [[ "$arg" =~ ^.*\.(bashrc|bash_profile|zshrc|zsh_profile|profile|fish_profile)$ ]] || [[ "$arg" == *"/.bashrc" ]] || [[ "$arg" == *"/.zshrc" ]] || [[ "$arg" == *"/.profile" ]]; then
            profile_file="$arg"
        elif [[ "$arg" == "true" ]] || [[ "$arg" == "false" ]]; then
            create_backup="$arg"
        else
            lines+=("$arg")
        fi
    done
    
    # Check if we have any lines to write
    if [[ ${#lines[@]} -eq 0 ]]; then
        print_error "No content lines provided"
        return 1
    fi
    
    # Join lines with newlines
    local content
    printf -v content '%s\n' "${lines[@]}"
    
    # Remove trailing newline
    content="${content%$'\n'}"
    
    # Call the main write function
    write_to_profile "$content" "$profile_file" "$create_backup"
}

# Function to write export statements to profile
# Usage: write_exports_to_profile "VAR1=value1" "VAR2=value2" [profile_file] [create_backup]
write_exports_to_profile() {
    local profile_file=""
    local create_backup="true"
    local exports=()
    
    # Parse arguments
    for arg in "$@"; do
        if [[ "$arg" =~ ^.*\.(bashrc|bash_profile|zshrc|zsh_profile|profile|fish_profile)$ ]] || [[ "$arg" == *"/.bashrc" ]] || [[ "$arg" == *"/.zshrc" ]] || [[ "$arg" == *"/.profile" ]]; then
            profile_file="$arg"
        elif [[ "$arg" == "true" ]] || [[ "$arg" == "false" ]]; then
            create_backup="$arg"
        else
            exports+=("export $arg")
        fi
    done
    
    # Check if we have any exports to write
    if [[ ${#exports[@]} -eq 0 ]]; then
        print_error "No export statements provided"
        return 1
    fi
    
    # Write exports using the lines function
    write_lines_to_profile "${exports[@]}" "$profile_file" "$create_backup"
}

# Function to write PATH additions to profile
# Usage: write_path_to_profile "/new/path" [profile_file] [create_backup]
write_path_to_profile() {
    local new_path="$1"
    local profile_file="${2:-}"
    local create_backup="${3:-true}"
    
    if [[ -z "$new_path" ]]; then
        print_error "Path cannot be empty"
        return 1
    fi
    
    # Create PATH export statement
    local path_statement="export PATH=\"$new_path:\$PATH\""
    
    write_to_profile "$path_statement" "$profile_file" "$create_backup"
}

# Function to write source statements to profile
# Usage: write_source_to_profile "/path/to/file" [profile_file] [create_backup]
write_source_to_profile() {
    local source_file="$1"
    local profile_file="${2:-}"
    local create_backup="${3:-true}"
    
    if [[ -z "$source_file" ]]; then
        print_error "Source file path cannot be empty"
        return 1
    fi
    
    # Create source statement with existence check
    local source_statement="if [ -f \"$source_file\" ]; then source \"$source_file\"; fi"
    
    write_to_profile "$source_statement" "$profile_file" "$create_backup"
}

# Function to remove entries added by a specific script
# Usage: remove_script_entries_from_profile "script_name" [profile_file]
remove_script_entries_from_profile() {
    local script_name="$1"
    local profile_file="${2:-}"
    
    if [[ -z "$script_name" ]]; then
        print_error "Script name cannot be empty"
        return 1
    fi
    
    # Detect profile file if not provided
    if [[ -z "$profile_file" ]]; then
        profile_file=$(detect_profile)
        if [[ -z "$profile_file" ]]; then
            print_error "Could not detect shell profile file"
            return 1
        fi
    fi
    
    if [[ ! -f "$profile_file" ]]; then
        print_info "Profile file does not exist: $profile_file"
        return 0
    fi
    
    # Always ensure a backup is created before modifying the profile
    _ensure_profile_backup "$profile_file" "$(_get_timestamp)"
    
    # Remove entries between script headers and footers
    sed -i.tmp "/^# Added by: $script_name$/,/^# End of $script_name configuration$/d" "$profile_file"
    rm -f "${profile_file}.tmp"
    
    print_success "Removed entries for $script_name from $profile_file"
}

# =============================================================================
# INFORMATION FUNCTIONS
# =============================================================================

# Function to display utility information
profile_writer_info() {
    print_header "Profile Writer Utility"
    print_info "Utility for managing shell profile writes with proper logging"
    echo ""
    print "Available functions:"
    print "• write_to_profile - Write content to shell profile"
    print "• write_lines_to_profile - Write multiple lines to profile"
    print "• write_exports_to_profile - Write export statements to profile"
    print "• write_path_to_profile - Add PATH entries to profile"
    print "• write_source_to_profile - Add source statements to profile"
    print "• remove_script_entries_from_profile - Remove entries by script name"
    echo ""
    print_success "Profile Writer Utility loaded successfully!"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Display information if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    profile_writer_info
fi