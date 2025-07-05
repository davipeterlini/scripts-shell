#!/bin/bash

# Function to detect the operating system and version
detect_os() {
    local os_name=""
    local os_version=""
    local os_codename=""
    
    # Detect OS type
    case "$(uname -s)" in
        Darwin)
            os_name="macOS"
            os_version=$(sw_vers -productVersion)
            
            # Get macOS codename based on version
            case "${os_version%%.*}" in
                10)
                    case "${os_version#*.}" in
                        15*) os_codename="Catalina" ;;
                        14*) os_codename="Mojave" ;;
                        13*) os_codename="High Sierra" ;;
                        12*) os_codename="Sierra" ;;
                        11*) os_codename="El Capitan" ;;
                        10*) os_codename="Yosemite" ;;
                        9*) os_codename="Mavericks" ;;
                        *) os_codename="Unknown" ;;
                    esac
                    ;;
                11) os_codename="Big Sur" ;;
                12) os_codename="Monterey" ;;
                13) os_codename="Ventura" ;;
                14) os_codename="Sonoma" ;;
                15) os_codename="Sequoia" ;;
                *) os_codename="Unknown" ;;
            esac
            ;;
            
        Linux)
            os_name="Linux"
            
            # Check for common Linux distribution information files
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                os_version="$VERSION_ID"
                os_codename="$PRETTY_NAME"
                os_name="$ID"
                
                # Capitalize first letter of distribution name
                os_name="$(tr '[:lower:]' '[:upper:]' <<< ${os_name:0:1})${os_name:1}"
            elif [ -f /etc/lsb-release ]; then
                . /etc/lsb-release
                os_version="$DISTRIB_RELEASE"
                os_codename="$DISTRIB_CODENAME"
                os_name="$DISTRIB_ID"
            elif [ -f /etc/debian_version ]; then
                os_name="Debian"
                os_version=$(cat /etc/debian_version)
            elif [ -f /etc/redhat-release ]; then
                os_name=$(cat /etc/redhat-release | cut -d ' ' -f 1)
                os_version=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+')
            fi
            ;;
            
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            os_name="Windows"
            if [ -n "$(command -v cmd.exe)" ]; then
                # Get Windows version using systeminfo
                os_version=$(cmd.exe /c ver 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
                
                # Try to get Windows edition
                if [ -n "$(command -v wmic)" ]; then
                    os_codename=$(wmic os get Caption /value 2>/dev/null | grep -o "Windows.*" | sed 's/Windows //')
                fi
            fi
            ;;
            
        *)
            print_error "Sistema operacional não suportado"
            return 1
            ;;
    esac
    
    # Export variables
    export OS_NAME="$os_name"
    export OS_VERSION="$os_version"
    export OS_CODENAME="$os_codename"
    
    # Print OS information
    print_success "Sistema Operacional Detectado: $os_name $os_version $os_codename"

    export os="$os_name"
}

# Execute main function only if the script is being run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  detect_os "$@"
fi