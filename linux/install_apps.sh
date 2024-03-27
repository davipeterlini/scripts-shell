#!/bin/bash

# Update APT packages and indexes
echo "Updating APT packages and indexes..."
uname -m
sudo apt update
sudo apt list --upgradable


extract() {
    local name="$1"
    echo "Extracting $name to /opt..."
    sudo tar -xzf "$name" -C /opt
    
}

cleanup() {
    local name="$1"
    echo "Removing $name..."
    rm "$name"
}

extract_cleanup() {
    local name="$1"
    extract "$name"
    cleanup "$name"
}

create_simbolic_link() { 
    local name="$1"
    sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman
    # TODO - find para achar a pasta
    # TODO find para achamar o binário dentro da pasta 
}

create_icon() { 
    local name="$1"
    # TODO - colocar lógica de criar ícone 
}

download_apps() {
    local url="$1"
    local output="$2"

    echo "Downloading from $url..."
    wget "$url" -O "$output"
}

export_path_profile() { 
    local path_app="$1"
    echo "export PATH=\"$PATH:$HOME/$path_app\"" >> $HOME/.profile
    source $HOME/.profile

}

check_install() {
    local name="$1"
    if dpkg -l | grep -qw "$name"; then
        echo "$name is already installed."
        return 0
    fi
    if command -v "$name" > /dev/null 2>&1; then
        echo "$name is already installed."
        return 0
    fi
    return 1
}

install_cleanup() {
    local name="$1"

    if [[ "$name" == *.tar.gz ]]; then
        echo "Detected tar.gz file. Extracting and cleaning up."
        extract_cleanup "$name"
        create_simbolic_link "$name"
        create_icon "$name"
    elif [[ "$name" == *.deb ]]; then
        echo "Detected deb file. Installing and cleaning up."
        sudo dpkg -i "$name"
        sudo apt-get install -f  # Fix any broken dependencies
        cleanup "$name"
    else
        echo "No file to process, attempting to install $name using apt-get..."
        sudo apt-get install -y "$name"
    fi
}

download_install_cleanup() {
    local description="$1"
    local url="$2"
    local name_app=""
    local filename="${url##*/}"  # Extracts filename from URL

    echo "$filename" # TODO - para testar

    echo "$description"

    if check_install "$name_app"; then
        return 0
    fi

    if [[ -n "$url" ]]; then
        download_apps "$url" "$filename"
    else
        name_app="$2"
        filename=$name_app
    fi

    echo "$filename" # TODO - para testar

    install_cleanup "$filename"
}


install_basic_apps() {
    DESCRIPTION="Installing common dependencies..."

    # Apps without specific pre-installation requirements can be directly installed
    declare -a install_apt_get=(
        "gpg"
        "software-properties-common"
        "apt-transport-https"
        "xclip"
        "wget"
        "curl" 
        "git" 
        "vim"
        "python3"
        "gnome-terminal" 
        "meld"
        "flameshot"
        "virtualbox"
        "vlc"
        "obs-studio"
        "unzip"
        "xz-utils"
        "zip"
        "libglu1-mesa"
    )

    for APP_NAME in "${install_apt_get[@]}"; do
        download_install_cleanup "$DESCRIPTION $APP_NAME" "$APP_NAME"
    done
}

install_google_chrome() {
    DESCRIPTION="Installing Google Chrome..."
    URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    download_install_cleanup "$DESCRIPTION" "$URL"
}

install_zoom() {
    DESCRIPTION="Installing Zoom..."
    URL="https://zoom.us/client/latest/zoom_amd64.deb"
    download_install_cleanup "$DESCRIPTION" "$URL"
}

install_rambox() {
    DESCRIPTION="Installing Rambox... - Check de Last Release - https://github.com/ramboxapp/download/releases"
    URL="https://github.com/ramboxapp/download/releases/download/v2.3.1/Rambox-2.3.1-linux-x64.deb"
    download_install_cleanup "$DESCRIPTION" "$URL"
}

# TODO - possivel pegar última versão 
    # wget -O dbeaver.deb $(wget -qO- https://dbeaver.io/download/ | grep -oP 'https://dbeaver.io/files/\d+\.\d+\.\d+/dbeaver-ce_\d+\.\d+\.\d+_amd64.deb' | head -1)
install_dbeaver() {
    DESCRIPTION="Installing DBeaver... - Check de Last Release - https://dbeaver.io/download/"
    URL="https://download.dbeaver.com/community/24.0.1/dbeaver-ce_24.0.1_amd64.deb"
    download_install_cleanup "$DESCRIPTION" "$URL"
}

# TODO - possivel pegar última versão 
    # wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
    # echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
install_vscode() {
    DESCRIPTION="Installing Visual Studio Code... - Check de Last Release - https://code.visualstudio.com/docs/?dv=linux64_deb"
    URL="https://vscode.download.prss.microsoft.com/dbazure/download/stable/863d2581ecda6849923a2118d93a088b0745d9d6/code_1.87.2-1709912201_amd64.deb"
    download_install_cleanup "$DESCRIPTION" "$URL"
}

install_intellij() {
    DESCRIPTION="Installing IntelliJ IDEA Community Edition... - Check de Last Release - https://www.jetbrains.com/idea/download/download-thanks.html?platform=linux"
    URL="https://download-cdn.jetbrains.com/idea/ideaIU-2023.3.6.tar.gz"
    download_install_cleanup "$DESCRIPTION" "$URL"
}

install_android_studio() {
    DESCRIPTION="Installing Android Studio... - Check de Last Release - https://developer.android.com/studio?hl=pt-br#get-android-studio"
    URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.1.1.21/android-studio-2022.1.1.21-linux.tar.gz"
    download_install_cleanup "$DESCRIPTION" "$URL"
}

# TODO - possivel pegar última versão 
install_postman() {
    DESCRIPTION="Installing Postman...... - Check de Last Release - https://www.postman.com/downloads/"
    URL="https://dl.pstmn.io/download/latest/linux64"
    download_install_cleanup "$DESCRIPTION" "$URL"
}

# TODO - ver instalação antiga 
    # URL="https://github.com/flutter/flutter.git"
    # git clone "$URL" -b stable $HOME/flutter
install_flutter() {
    DESCRIPTION="Installing Flutter... - Check de Last Release - https://docs.flutter.dev/get-started/install/linux/desktop?tab=download"
    URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.4-stable.tar.xz"
    download_install_cleanup "$DESCRIPTION" "$URL"
    export_path_profile "flutter/bin"
}

install_go() {
    DESCRIPTION="Installing Golang... - Check de Last Release - https://go.dev/doc/install"
    URL="https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz"
    download_install_cleanup "$DESCRIPTION" "$URL"
    export_path_profile "usr/local/go/bin"
}




# TODO - ver instalação antiga 
    # echo "Check de Last Release - https://www.spotify.com/br-pt/download/linux/"
    # curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg
    # sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    # echo "deb http://repository.spotify.com stable non-free"
    # sudo tee /etc/apt/sources.list.d/spotify.list
    # curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg
    # sudo apt-key add - echo "deb http://repository.spotify.com stable non-free"
    # sudo tee /etc/apt/sources.list.d/spotify.list
    # sudo apt-get update && sudo apt-get install spotify-client
install_spotify() {
    DESCRIPTION="Installing Spotify... - Check de Last Release - https://www.spotify.com/br-pt/download/android/"
    URL=""
    download_install_cleanup "$DESCRIPTION" "$URL"
}

main() {
    install_basic_apps 
    install_google_chrome
    install_zoom
    install_rambox
    install_intellij
    install_android_studio
    install_dbeaver
    install_postman
    install_vscode
    install_flutter
    install_go
    #install_spotify
}

main

# Cleaning up unnecessary packages after installation
echo "Cleaning up unnecessary packages..."
sudo apt autoremove -y

# TODO - ver novas versões
#install_if_not_installed "rancher-desktop"  # May need to install via other means if not available on APT