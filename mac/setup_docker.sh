#!/bin/bash

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para desinstalar pacotes usando brew ou remover manualmente
remove_docker_components() {
    echo "Removendo componentes Docker..."

    # Remover Rancher Desktop
    if brew list --cask rancher > /dev/null 2>&1; then
        brew uninstall --cask rancher
    else
        echo "Rancher Desktop não instalado via brew."
    fi

    # Remover Docker Desktop
    if brew list --cask docker > /dev/null 2>&1; then
        brew uninstall --cask docker
    else
        echo "Docker Desktop não instalado via brew."
    fi

    # Remover Docker CLI e Docker Compose
    brew uninstall docker docker-compose

    # Remover manualmente se brew não estiver disponível
    sudo rm -rf /Applications/Docker.app
    sudo rm -rf ~/.docker
    sudo rm -rf /usr/local/bin/docker
    sudo rm -rf /usr/local/bin/docker-compose
    sudo rm -rf /usr/local/bin/docker-credential-osxkeychain
    sudo rm -rf /usr/local/bin/com.docker.cli
}

install_or_reinstall_colima() {
    echo "Instalando ou reinstalando Colima e dependências..."

    # Atualizar brew
    brew update

    # Reinstalar Colima se já estiver instalado
    if brew list colima > /dev/null 2>&1; then
        brew reinstall colima
    else
        brew install colima
    fi

    # Reinstalar Docker CLI e Docker Compose se já estiverem instalados
    if brew list docker > /dev/null 2>&1; then
        brew reinstall docker
    else
        brew install docker
    fi

    if brew list docker-compose > /dev/null 2>&1; then
        brew reinstall docker-compose
    else
        brew install docker-compose
    fi
    
    if brew list docker-credential-helper > /dev/null 2>&1; then
        brew reinstall docker-credential-helper
    else
        brew install docker-credential-helper
    fi
    docker-credential-osxkeychain version
}

# # Função para configurar Colima para iniciar na inicialização
# configure_colima_autostart_old() {
#     echo "Configurando Colima para iniciar na inicialização..."

#     # Criar script de inicialização
#     cat <<EOF > ~/start_colima.sh
# #!/bin/bash
# colima start
# EOF

#     chmod +x ~/start_colima.sh

#     # Adicionar script ao .zshrc para iniciar Colima automaticamente
#     if ! grep -Fxq "~/start_colima.sh &" ~/.zshrc; then
#         echo "~/start_colima.sh &" >> ~/.zshrc
#     fi

#     # Configurar variável de ambiente DOCKER_HOST
#     if ! grep -Fxq "export DOCKER_HOST=unix:///Users/davi.peterlini/.colima/default/docker.sock" ~/.zshrc; then
#         echo 'export DOCKER_HOST=unix:///Users/davi.peterlini/.colima/default/docker.sock' >> ~/.zshrc
#     fi

#     # Recarregar o arquivo de configuração do shell
#     source ~/.zshrc
# }

# Função para configurar Colima para iniciar na inicialização do sistema
configure_colima_autostart() {
    echo "Configurando Colima para iniciar na inicialização do sistema..."

    # Criar script de inicialização
    cat <<EOF > ~/start_colima.sh
#!/bin/bash
colima start
EOF

    chmod +x ~/start_colima.sh

    # Criar arquivo plist para LaunchAgents
    cat <<EOF > ~/Library/LaunchAgents/com.user.startcolima.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.startcolima</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/$USER/start_colima.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

    # Carregar o LaunchAgent
    launchctl load ~/Library/LaunchAgents/com.user.startcolima.plist

    # Configurar variável de ambiente DOCKER_HOST
    if ! grep -Fxq "export DOCKER_HOST=unix:///Users/davi.peterlini/.colima/default/docker.sock" ~/.zshrc; then
        echo 'export DOCKER_HOST=unix:///Users/davi.peterlini/.colima/default/docker.sock' >> ~/.zshrc
    fi

    # Recarregar o arquivo de configuração do shell
    source ~/.zshrc

    # Remover script do .zshrc se estiver presente
    #sed -i '' '/start_colima.sh/d' ~/.zshrc
}

# Função para verificar se Docker e Docker Compose estão funcionando
check_docker_installation() {
    echo "Verificando instalação do Docker e Docker Compose..."

    colima start

    if docker --version && docker-compose --version; then
        echo "Docker e Docker Compose foram instalados com sucesso."
    else
        echo "Houve um problema na instalação do Docker ou Docker Compose."
        exit 1
    fi

    # Verificar conexão com o Docker daemon
    if docker info; then
        echo "Conexão com o Docker daemon bem-sucedida."
    else
        echo "Erro ao conectar ao Docker daemon."
        exit 1
    fi
}

# Função para instalar ou reinstalar o Docker Desktop via Homebrew
install_or_reinstall_docker_desktop() {
    echo "Instalando ou reinstalando Docker Desktop via Homebrew..."
    if brew list --cask docker > /dev/null 2>&1; then
        brew reinstall --cask docker
    else
        brew install --cask docker
    fi
}

# Função para instalar ou reinstalar o Rancher Desktop via Homebrew
install_or_reinstall_rancher_desktop() {
    echo "Instalando ou reinstalando Rancher Desktop via Homebrew..."
    if brew list --cask rancher > /dev/null 2>&1; then
        brew reinstall --cask rancher
    else
        brew install --cask rancher
    fi
}

# Executar funções
remove_docker_components
install_or_reinstall_colima
configure_colima_autostart
check_docker_installation

# Instalações opcionais
#install_or_reinstall_docker_desktop
#install_or_reinstall_rancher_desktop

echo "Configuração concluída com sucesso."

# Reiniciar o iTerm2
osascript -e 'tell application "iTerm" to quit' && open -a iTerm
