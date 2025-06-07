#!/bin/bash

# Cores para melhor visualização
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir mensagens de log
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Detectar o sistema operacional
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log "macOS detected"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log "Linux detected"
    else
        error "Unsupported operating system: $OSTYPE"
    fi
}

# Verificar se o Google Drive está instalado
check_drive_installed() {
    log "Checking if Google Drive is installed..."
    
    if [[ "$OS" == "macos" ]]; then
        if [ -d "/Applications/Google Drive.app" ]; then
            success "Google Drive is already installed"
            return 0
        else
            return 1
        fi
    elif [[ "$OS" == "linux" ]]; then
        if command -v google-drive-ocamlfuse &> /dev/null; then
            success "Google Drive is already installed"
            return 0
        else
            return 1
        fi
    fi
}

# Instalar o Google Drive
install_drive() {
    log "Installing Google Drive..."
    
    if [[ "$OS" == "macos" ]]; then
        log "Downloading Google Drive for macOS..."
        # Verificar se o Homebrew está instalado
        if ! command -v brew &> /dev/null; then
            log "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        log "Installing Google Drive via Homebrew..."
        brew install --cask google-drive
        
    elif [[ "$OS" == "linux" ]]; then
        log "Installing Google Drive for Linux (using google-drive-ocamlfuse)..."
        
        # Verificar a distribuição Linux
        if command -v apt-get &> /dev/null; then
            # Debian/Ubuntu
            sudo add-apt-repository ppa:alessandro-strada/ppa -y
            sudo apt-get update
            sudo apt-get install -y google-drive-ocamlfuse
        elif command -v dnf &> /dev/null; then
            # Fedora
            sudo dnf install -y google-drive-ocamlfuse
        elif command -v pacman &> /dev/null; then
            # Arch Linux
            sudo pacman -S google-drive-ocamlfuse
        else
            error "Unsupported Linux distribution. Please install google-drive-ocamlfuse manually."
        fi
    fi
    
    success "Google Drive installed successfully"
}

# Configurar o login no Google Drive
configure_drive_login() {
    log "Configuring Google Drive login..."
    
    # Perguntar qual conta usar
    echo -e "${YELLOW}Which Google account do you want to use?${NC}"
    echo "1. Work account"
    echo "2. Personal account"
    read -p "Enter your choice (1/2): " account_choice
    
    if [[ "$account_choice" == "1" ]]; then
        ACCOUNT_TYPE="work"
    elif [[ "$account_choice" == "2" ]]; then
        ACCOUNT_TYPE="personal"
    else
        error "Invalid choice. Please select 1 for Work or 2 for Personal."
    fi
    
    log "You selected: $ACCOUNT_TYPE account"
    
    if [[ "$OS" == "macos" ]]; then
        # No macOS, apenas abrimos o aplicativo e o usuário faz login manualmente
        log "Opening Google Drive application..."
        open -a "Google Drive"
        echo -e "${YELLOW}Please login with your $ACCOUNT_TYPE Google account in the opened window.${NC}"
        echo -e "${YELLOW}After login, press Enter to continue...${NC}"
        read -p ""
        
    elif [[ "$OS" == "linux" ]]; then
        # No Linux, configuramos o google-drive-ocamlfuse
        if [[ "$ACCOUNT_TYPE" == "work" ]]; then
            google-drive-ocamlfuse -label work
        else
            google-drive-ocamlfuse -label personal
        fi
        
        # Criar ponto de montagem
        MOUNT_POINT="$HOME/GoogleDrive-$ACCOUNT_TYPE"
        mkdir -p "$MOUNT_POINT"
        
        # Montar o Google Drive
        if [[ "$ACCOUNT_TYPE" == "work" ]]; then
            google-drive-ocamlfuse -label work "$MOUNT_POINT"
        else
            google-drive-ocamlfuse -label personal "$MOUNT_POINT"
        fi
        
        DRIVE_PATH="$MOUNT_POINT"
    fi
    
    success "Google Drive login configured"
}

# Encontrar o caminho do Google Drive
find_drive_path() {
    log "Finding Google Drive path..."
    
    if [[ "$OS" == "macos" ]]; then
        # No macOS, procurar pelo diretório do Google Drive
        POSSIBLE_PATHS=(
            "$HOME/Google Drive"
            "$HOME/Google Drive File Stream"
            "$HOME/Library/CloudStorage/GoogleDrive-*"
        )
        
        for path_pattern in "${POSSIBLE_PATHS[@]}"; do
            for path in $path_pattern; do
                if [ -d "$path" ]; then
                    DRIVE_PATH="$path"
                    log "Found Google Drive at: $DRIVE_PATH"
                    
                    # Verificar se é o diretório correto
                    echo -e "${YELLOW}Is this the correct Google Drive path? $DRIVE_PATH (y/n)${NC}"
                    read -p "" confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        break 2
                    fi
                fi
            done
        done
        
        # Se não encontrou automaticamente, pedir ao usuário
        if [ -z "$DRIVE_PATH" ]; then
            echo -e "${YELLOW}Could not automatically find Google Drive path.${NC}"
            read -p "Please enter the full path to your Google Drive folder: " DRIVE_PATH
            
            if [ ! -d "$DRIVE_PATH" ]; then
                error "The provided path does not exist: $DRIVE_PATH"
            fi
        fi
    fi
    
    success "Google Drive path set to: $DRIVE_PATH"
}

# Criar estrutura de pastas
create_folder_structure() {
    log "Creating folder structure..."
    
    # Criar pasta de sincronização no Google Drive
    SYNC_FOLDER="$DRIVE_PATH/Meu Drive/coder-ide-sync"
    mkdir -p "$SYNC_FOLDER"
    success "Created sync folder: $SYNC_FOLDER"
    
    # Criar pasta no-commit
    NO_COMMIT_FOLDER="$SYNC_FOLDER/no-commit"
    mkdir -p "$NO_COMMIT_FOLDER"
    success "Created no-commit folder: $NO_COMMIT_FOLDER"
}

# Configurar links simbólicos
setup_symlinks() {
    log "Setting up symbolic links..."
    
    # Criar link simbólico principal
    ln -sf "$SYNC_FOLDER" "$HOME/.coder-ide"
    success "Created main symbolic link: $HOME/.coder-ide -> $SYNC_FOLDER"
    
    # Verificar se os diretórios de destino existem, se não, criar
    mkdir -p "$HOME/projects-cit/flow/coder-assistants" 2>/dev/null
    mkdir -p "$HOME/projects-personal" 2>/dev/null
    
    # Criar links simbólicos para os projetos
    ln -sf "$HOME/.coder-ide/no-commit" "$HOME/projects-cit/flow/coder-assistants/flow-coder-extension"
    ln -sf "$HOME/.coder-ide/no-commit" "$HOME/projects-personal/scripts-shell"
    
    success "Created project symbolic links"
}

# Verificar a configuração
verify_setup() {
    log "Verifying setup..."
    
    if [ -L "$HOME/.coder-ide" ]; then
        success "Main symbolic link is correctly set up"
    else
        warning "Main symbolic link was not created correctly"
    fi
    
    if [ -L "$HOME/projects-cit/flow/coder-assistants/flow-coder-extension" ] && \
       [ -L "$HOME/projects-personal/scripts-shell" ]; then
        success "Project symbolic links are correctly set up"
    else
        warning "Some project symbolic links may not be correctly set up"
    fi
    
    log "Setup verification complete"
}

# Função principal
main() {
    log "Starting Google Drive folder sync setup..."
    
    detect_os
    
    if ! check_drive_installed; then
        install_drive
    fi
    
    configure_drive_login
    find_drive_path
    create_folder_structure
    setup_symlinks
    verify_setup
    
    success "Google Drive folder sync setup completed successfully!"
    log "Your folders are now syncing with Google Drive at: $SYNC_FOLDER"
}

# Executar o script
main