#!/bin/bash

# Shell Utils Library
# Biblioteca consolidada com utilitários shell para automatização e ferramentas

# =============================================================================
# CONFIGURAÇÃO INICIAL
# =============================================================================

# Obter diretório absoluto do script atual
SHELL_UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# CORES E MENSAGENS
# =============================================================================

# Definições de cores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;37m'
NC='\033[0m' # No Color

# Função para exibir mensagens informativas
function print_info() {
  echo -e "\n${BLUE}ℹ️  $1${NC}"
}

# Função para exibir mensagens de sucesso
function print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

# Função para exibir mensagens de alerta
function print_alert() {
  echo -e "\n${YELLOW}⚠️  $1${NC}"
}

# Função para exibir mensagens de pergunta
function print_alert_question() {
  echo -n -e "\n${YELLOW}⚠️  $1${NC}"
}

# Função para exibir mensagens de erro
function print_error() {
  echo -e "${RED}❌ Error: $1${NC}"
}

# Função para exibir mensagens simples
function print() {
  echo -e "${CYAN}$1${NC}"
}

# Função para exibir cabeçalhos formatados
function print_header() {
  echo -e "\n${YELLOW}===========================================================================${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${YELLOW}===========================================================================${NC}"
}

# Função para exibir cabeçalhos informativos
function print_header_info() {
  echo -e "\n${CYAN}===========================================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${CYAN}===========================================================================${NC}"
}

# Função para exibir texto amarelo
function print_yellow() {
  echo -e "${YELLOW}$1${NC}"
}

# Função para exibir texto vermelho
function print_red() {
  echo -e "${RED}$1${NC}"
}

# =============================================================================
# FERRAMENTAS BASH
# =============================================================================

# Função para criar diretórios
create_directories() {
  local ROOT_DIR="$1"
  local directories=("$@")
  for dir in "${directories[@]}"; do
    if [[ "$dir" != "$ROOT_DIR" ]]; then
      full_dir="${ROOT_DIR}/${dir}"
      if [[ ! -d "$full_dir" ]]; then
        print_info "Creating directory: $full_dir"
        mkdir -p "$full_dir"
        print_success "Directory created: $full_dir"
      else
        print_info "Directory already exists: $full_dir"
      fi
    fi
  done
}

# Função para remover um diretório
remove_directory() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    if rm -rf "$dir"; then
      print_success "Removed $dir"
      return 0
    else
      print_error "Failed to remove $dir"
      return 1
    fi
  else
    print_alert "$dir not found"
    return 0
  fi
}

# Função para remover múltiplos diretórios
remove_directories() {
  local array_name=$1
  local failed_count=0

  # Usar eval para obter os elementos do array
  eval "local directories=(\"\${$array_name[@]}\")"

  for dir in "${directories[@]}"; do
    if ! remove_directory "$dir"; then
      ((failed_count++))
    fi
  done

  if [[ $failed_count -gt 0 ]]; then
    print_alert "Failed to remove $failed_count directories"
  fi
}

# Função para obter confirmação do usuário
get_user_confirmation() {
  local prompt_message="${1:-"Do you want to proceed? (y/n): "}"
  print_alert_question "$prompt_message "
  read -r user_choice
  if [[ "$user_choice" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# Função para limpeza de arquivos temporários
cleanup_temp_files() {
    local temp_dir="$1"
    rm -rf "$temp_dir"
}

# =============================================================================
# DETECÇÃO DE SISTEMA OPERACIONAL
# =============================================================================

# Função para detectar o sistema operacional e versão
detect_os() {
    local os_name=""
    local os_version=""
    local os_codename=""
    
    # Detectar tipo de OS
    case "$(uname -s)" in
        Darwin)
            os_name="macOS"
            os_version=$(sw_vers -productVersion)
            
            # Obter nome de código do macOS baseado na versão
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
            
            # Verificar arquivos de informação de distribuição Linux
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                os_version="$VERSION_ID"
                os_codename="$PRETTY_NAME"
                os_name="$ID"
                
                # Capitalizar primeira letra do nome da distribuição
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
                # Obter versão do Windows usando systeminfo
                os_version=$(cmd.exe /c ver 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
                
                # Tentar obter edição do Windows
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
    
    # Exportar variáveis
    export OS_NAME="$os_name"
    export OS_VERSION="$os_version"
    export OS_CODENAME="$os_codename"
    
    # Imprimir informações do OS
    print_success "Sistema Operacional Detectado: $os_name $os_version $os_codename"

    export os="$os_name"
}

# =============================================================================
# MENU E INTERFACE
# =============================================================================

# Variável global para armazenar escolhas do menu
MENU_CHOICES=""

# Função para instalar dialog
install_dialog() {
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y dialog
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install dialog
        else
            echo "Unsupported OS."
            return 1
        fi
    fi
}

# Função para exibir menu usando dialog
display_dialog_menu() {
    install_dialog

    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All Apps" off)

    if [ -z "$choices" ]; then
        print_alert "Nenhuma opção foi selecionada."
    else
        print_success "Opções selecionadas: $choices"
    fi
}

# Função para exibir menu sem usar dialog
display_menu() {
    echo ""
    print_header_info "Menu"
    echo ""
    print "Selecione o tipo de aplicativos para instalar:"
    echo ""
    print "1) Basic Apps"
    print "2) Development Apps"
    print "3) All Apps"
    echo ""
    
    print_yellow "Digite os números das opções desejadas (separados por espaço) e pressione ENTER:"
    read -r selection
    
    # Verificar se a entrada não está vazia
    if [ -z "$selection" ]; then
        print_alert "Nenhuma opção foi selecionada."
        MENU_CHOICES=""
        return 1
    fi
    
    # Processar e validar entrada
    local choices=""
    local valid_options=true
    
    for num in $selection; do
        if [[ "$num" =~ ^[1-3]$ ]]; then
            choices+="$num "
        else
            print_error "Opção inválida: $num. Ignorando."
            valid_options=false
        fi
    done
    
    # Remover espaço final
    choices=$(echo "$choices" | xargs)
    
    if [ -z "$choices" ]; then
        print_alert "Nenhuma opção válida foi selecionada."
        MENU_CHOICES=""
        return 1
    fi
    
    if [ "$valid_options" = false ]; then
        print_alert "Algumas opções inválidas foram ignoradas."
    fi
    
    print_success "Opções selecionadas: $choices"
    
    # Definir variável global
    MENU_CHOICES="$choices"
}

# =============================================================================
# EXECUÇÃO DE SCRIPTS
# =============================================================================

# Função para executar um script com descrição
execute_script() {
  local script_path=$1
  local description=$2

  if [ -f "$script_path" ]; then
    print_info "$description"
    bash "$script_path"
    print_success "Execução do script $script_path concluída com sucesso."
  else
    print_error "O script $script_path não foi encontrado. Abortando."
  fi
}

# =============================================================================
# GERENCIAMENTO DE REPOSITÓRIOS GIT
# =============================================================================

# Função para clonar um repositório
clone_repository() {
    local repo_url="$1"
    local repo_path="$2"
    local repo_name=$(basename "$repo_url" .git)
    local full_repo_path="$repo_path"

    if [[ -d "$full_repo_path" ]]; then
        print_info "Repository directory already exists: $full_repo_path"
        print_info "Updating repository instead of cloning..."
        if (cd "$full_repo_path" && git pull origin main); then
            print_success "Repository updated successfully: $repo_name"
        else
            print_alert "Failed to update repository: $repo_name. Continuing with next repository."
        fi
    else
        print_info "Cloning repository: $repo_name"
        if git clone "$repo_url" "$repo_path"; then
            print_success "Repository cloned successfully: $repo_name"
        else
            print_alert "Failed to clone repository: $repo_name. Skipping and continuing with next repository."
        fi
    fi
}

# Função para atualizar um repositório
update_repository() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")

    print_info "Updating repository: $repo_name"
    if (cd "$repo_path" && git pull origin main); then
        print_success "Repository updated successfully: $repo_name"
    else
        print_alert "Failed to update repository: $repo_name. Continuing with next repository."
    fi
}

# Função para fazer merge de mudanças de uma branch
merge_back_repository() {
    local repo_path="$1"
    local branch="$2"
    local repo_name=$(basename "$repo_path")

    print_info "Merging back changes from branch $branch in repository: $repo_name"
    if (cd "$repo_path" && git merge "$branch"); then
        print_success "Branch $branch merged successfully in repository: $repo_name"
    else
        print_alert "Failed to merge branch $branch in repository: $repo_name. Continuing with next repository."
    fi
}

# Função para gerenciar repositórios - Atualizar ou Clonar repo
manage_repositories() {
   # Processar argumentos em pares (target_dir e repo_url)
   while [[ $# -ge 2 ]]; do
       local repo_url="$1"
       local target_dir="$2"
       shift 2

       local repo_name=$(basename "$repo_url" .git)
       local project_root="$(dirname "$target_dir")"
       local repo_path="$target_dir/$repo_name"

       if [[ -d "$repo_path" ]]; then
           update_repository "$repo_path"
       else
           clone_repository "$repo_url" "$target_dir"
       fi
   done
}

# =============================================================================
# NAVEGADOR
# =============================================================================

# Função para abrir navegador
open_browser() { 
    local url="$1"
    local display_name="$2"
    if command -v xdg-open &> /dev/null; then
        xdg-open "$url"
    elif command -v open &> /dev/null; then
        open "$url"
    else
        print_info "Manually visit $display_name URL: $url"
    fi
}

# =============================================================================
# INFORMAÇÕES DA BIBLIOTECA
# =============================================================================

# Função para exibir informações da biblioteca
shell_utils_info() {
    print_header "Shell Utils Library"
    print_info "Biblioteca consolidada com utilitários shell para automatização"
    echo ""
    print "Funcionalidades disponíveis:"
    print "• Cores e mensagens formatadas"
    print "• Ferramentas para gerenciamento de diretórios"
    print "• Detecção de sistema operacional"
    print "• Menus interativos"
    print "• Execução de scripts"
    print "• Gerenciamento de repositórios Git"
    print "• Abertura de navegador multiplataforma"
    echo ""
    print_success "Library loaded successfully!"
}

# =============================================================================
# INICIALIZAÇÃO
# =============================================================================

# Detectar OS automaticamente quando a biblioteca é carregada
detect_os

# Exibir informações se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    shell_utils_info
fi