#!/bin/bash

# Function to display a menu using dialog
display_menu() {
    local choices=$(dialog --stdout --checklist "Select the type of apps to install:" 15 50 3 \
        1 "Basic Apps" on \
        2 "Development Apps" off \
        3 "All Linux Apps" off)

    echo "$choices"
}

# Function to install apps on Linux with apt-get
install_apps_linux_apt() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        echo "Installing apt-get install -y $app..."
        sudo apt-get install -y "$app"
    done
}

# Function to install apps on Linux with faltpak
install_apps_linux_flat() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        flatpak install flathub -y "$app"
    done
}

# TODO - essa função deve ser modificafa para pegar o pacote correto
# Quando isso for concluido no .env pode ter as duas variáveis: 
#INSTALL_APPS_BASIC_LINUX_FLAT="chrome, zoom, rambox, spotify, "
#INSTALL_APPS_BASIC_LINUX_FLAT_DEV="dbeaver-community, docker, go, postman, visual-studio-code, robot3, intellij-idea, flutter"
# install_flatpak_apps() {
#   # Verifica se a variável de ambiente está definida
#   if [ -z "$INSTALL_APPS_BASIC_LINUX_FLAT_DEV" ]; then
#     echo "A variável INSTALL_APPS_BASIC_LINUX_FLAT_DEV não está definida. Por favor, configure-a antes de executar o script."
#     return 1
#   fi

#   # Converte a lista separada por vírgulas em um array
#   IFS=',' read -r -a APPS <<< "$INSTALL_APPS_BASIC_LINUX_FLAT_DEV"

#   # Atualiza os repositórios do Flatpak
#   echo "Atualizando repositórios do Flatpak..."
#   sudo flatpak update -y

#   # Instala os aplicativos via Flatpak
#   echo "Procurando e instalando aplicativos..."

#   for APP in "${APPS[@]}"; do
#     APP=$(echo "$APP" | xargs) # Remove espaços extras

#     # Procura o aplicativo no Flatpak usando o comando `search`
#     SEARCH_RESULT=$(flatpak search "$APP" | head -n 1)

#     if [[ -n "$SEARCH_RESULT" ]]; then
#       # Exemplo de saída: "Postman (com.getpostman.Postman)  <descrição>"
#       # Extrai o nome do pacote (segundo campo)
#       PACKAGE_NAME=$(echo "$SEARCH_RESULT" | awk '{print $2}')
#       echo "Encontrado $APP: $PACKAGE_NAME"
      
#       # Instala o aplicativo
#       flatpak install flathub "$PACKAGE_NAME" -y
#     else
#       echo "Aplicativo $APP não encontrado no Flatpak."
#     fi
#   done

#   echo "Todos os aplicativos foram processados!"
# }

# Function to install basic apps
install_basic_apps() {
    echo "Installing basic apps..."
    IFS=',' read -r -a basic_apps_apt <<< "$INSTALL_APPS_BASIC_LINUX_APT"
    echo "basic_apps_apt: $basic_apps_apt"
    install_apps_linux_apt "${basic_apps_apt[@]}"
    IFS=',' read -r -a basic_apps_flat <<< "$INSTALL_APPS_BASIC_LINUX_FLAT"
    echo "basic_apps_flat: $basic_apps_flat"
    install_apps_linux_flat "${basic_apps_flat[@]}"
}

# Function to install development apps
install_dev_apps() {
    echo "Installing development apps..."
    IFS=',' read -r -a dev_apps_apt <<< "$INSTALL_APPS_BASIC_LINUX_APT_DEV"
    install_apps_linux_apt "${dev_apps_apt[@]}"
    IFS=',' read -r -a dev_apps_flat <<< "$INSTALL_APPS_BASIC_LINUX_FLAT_DEV"
    install_apps_linux_flat "${dev_apps_flat[@]}"
}

# Function to install all Linux apps
install_all_linux_apps() {
    echo "Installing all Linux apps..."
    IFS=',' read -r -a linux_apps <<< "$APPS_TO_INSTALL_LINUX"
    install_apps_linux "${linux_apps[@]}"
}

# Function to install all macOS apps
install_all_apps() {
    echo "Installing all macOS apps..."
    IFS=',' read -r -a basic_apps_apt <<< "$INSTALL_APPS_BASIC_LINUX_APT"
    IFS=',' read -r -a dev_apps_apt <<< "$INSTALL_APPS_BASIC_LINUX_APT_DEV"
    all_apps_apt=("${basic_apps_apt[@]}" "${dev_apps_apt[@]}")
    IFS=',' read -r -a basic_apps_flat <<< "$INSTALL_APPS_BASIC_LINUX_FLAT"
    IFS=',' read -r -a dev_apps_flat <<< "$INSTALL_APPS_BASIC_LINUX_FLAT_DEV"
    all_apps_flat=("${basic_apps_flat[@]}" "${dev_apps_flat[@]}")
    install_apps_linux_apt "${all_apps_apt[@]}"
    install_apps_linux_flat "${all_apps_flat[@]}"
}

main() {
    # Load environment variables
    source "$(dirname "$0")/../../utils/load_env.sh"
    load_env

    # Check if dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing dialog..."
        sudo apt-get install -y dialog
    fi

    choices=$(display_menu)

    if [[ "$choices" == *"1"* ]]; then
        install_basic_apps
    fi

    if [[ "$choices" == *"2"* ]]; then
        install_dev_apps
    fi

    if [[ "$choices" == *"3"* ]]; then
        install_all_linux_apps
    fi
}

main