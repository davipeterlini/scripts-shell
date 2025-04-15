shell script
chmod +x grant_permissions.sh
./grant_permissions.sh
```

## Setup DEV enveriment
* Install all apps to use in dev enviremoment
```shell script
./setup_enviroment.sh
```

______________________________________________________________________________________________________________________________


# Bitbucket Scripts

Este diretório contém vários scripts para configurar e gerenciar contas do Bitbucket e chaves SSH. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### configure_multi_ssh_bitbucket_keys.sh
Este script configura múltiplas chaves SSH para diferentes contas do Bitbucket. Ele permite ao usuário adicionar várias chaves SSH ao agente SSH e configurar o SSH para usar diferentes chaves para diferentes contas do Bitbucket.

### connect_bitbucket_ssh_account.sh
Este script conecta uma conta Bitbucket usando uma chave SSH específica. Ele permite ao usuário escolher uma identidade (chave SSH) e adicioná-la ao agente SSH.

### generate-classic-token-bb-local.sh
Este script gera um token clássico para autenticação com a API do Bitbucket. Ele guia o usuário através do processo de criação do token e armazena o token gerado em um arquivo de perfil para uso futuro.

## Passo a Passo para Gerar e Configurar Chave SSH no Bitbucket

### 1. Liberar a permissão
Para liberar a permissão de execução dos scripts execute o script abaixo:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
```

### 2. Configurar Múltiplas Contas Bitbucket
Se você precisar configurar múltiplas contas do Bitbucket no mesmo sistema, execute o seguinte comando:
```shell
./bitbucket/configure_multi_ssh_bitbucket_keys.sh
```

### 3. Conectar a Conta Bitbucket com a Chave SSH
Para conectar sua conta Bitbucket usando a chave SSH gerada, execute o seguinte comando:
```shell
./bitbucket/connect_bitbucket_ssh_account.sh
```

### 4. Gerar o BITBUCKET_TOKEN 
Para gerar a o classic token do bitbuxket, execute o seguinte comando:
```shell
./bitbucket/generate-classic-token-bb-local.sh
```

______________________________________________________________________________________________________________________________

# GitHub Scripts

Este diretório contém vários scripts para configurar e gerenciar contas do GitHub e chaves SSH. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### configure_multi_ssh_github_keys.sh
Este script configura múltiplas chaves SSH para diferentes contas do GitHub. Ele permite ao usuário adicionar várias chaves SSH ao agente SSH e configurar o SSH para usar diferentes chaves para diferentes contas do GitHub.

### connect_git_ssh_account.sh
Este script conecta uma conta GitHub usando uma chave SSH específica. Ele permite ao usuário escolher uma identidade (chave SSH) e adicioná-la ao agente SSH.

### generate-classic-token-gh-local.sh
Este script gera um token clássico para autenticação com a API do GitHub. Ele guia o usuário através do processo de criação do token e armazena o token gerado em um arquivo de perfil para uso futuro.

## Passo a Passo para Gerar e Configurar Chave SSH no Github

### 1. Liberar a permissão
Para liberar a permissão de execução dos scripts execute o script abaixo:
```shell
chmod +x grant_permissions.sh
./grant_permissions.sh
```

### 2. Configurar Múltiplas Contas Github
Se você precisar configurar múltiplas contas do github no mesmo sistema, execute o seguinte comando:
```shell
./github/configure_multi_ssh_github_keys.sh
```

### 3. Conectar a Conta Github com a Chave SSH
Para conectar sua conta Github usando a chave SSH gerada, execute o seguinte comando:
```shell
./github/connect_git_ssh_account.sh
```

### 4. Gerar o Github_TOKEN 
Para gerar a o classic token do Github, execute o seguinte comando:
```shell
./github/generate-classic-token-gh-local.sh
```

______________________________________________________________________________________________________________________________

# MAC Scripts

Este diretório contém scripts para configurar e instalar aplicativos no macOS. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### setup_iterm.sh
Este script configura o iTerm2 com várias otimizações para melhorar a experiência do terminal no macOS.

### install_brew_apps.sh
Este script instala aplicativos usando o Homebrew no macOS.

## Passo a Passo para Configurar o Ambiente de Desenvolvimento no macOS

### 1. Configurar o iTerm2
Para configurar o iTerm2 com otimizações, execute o seguinte comando:
```shell
./mac/setup_iterm.sh
```

### 2. Instalar Aplicativos via Homebrew
Para instalar os aplicativos de desenvolvimento necessários, execute o seguinte comando:
```shell
./mac/install_brew_apps.sh
```

______________________________________________________________________________________________________________________________

# Linux Scripts

Este diretório contém scripts para configurar e instalar aplicativos em sistemas Linux. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### install_flatpak.sh
Este script instala o Flatpak e configura os repositórios necessários.

### install_flatpak_apps.sh
Este script instala aplicativos usando o Flatpak em sistemas Linux.

### install_aptget_apps.sh
Este script instala aplicativos usando o apt-get em sistemas Linux baseados em Debian.

## Passo a Passo para Configurar o Ambiente de Desenvolvimento no Linux

### 1. Instalar o Flatpak
Para instalar o Flatpak e configurar os repositórios, execute o seguinte comando:
```shell
./linux/install_flatpak.sh
```

### 2. Instalar Aplicativos via Flatpak
Para instalar os aplicativos usando o Flatpak, execute o seguinte comando:
```shell
./linux/install_flatpak_apps.sh
```

### 3. Instalar Aplicativos via apt-get
Para instalar os aplicativos usando o apt-get, execute o seguinte comando:
```shell
./linux/install_aptget_apps.sh
```

______________________________________________________________________________________________________________________________

# Docker Scripts

Este diretório contém scripts para instalar e configurar o Docker em diferentes sistemas operacionais. Abaixo está uma descrição detalhada do script presente neste diretório.

## Scripts

### install_docker.sh
Este script instala o Docker em diferentes sistemas operacionais (macOS, Linux, Windows).

## Passo a Passo para Instalar o Docker

### 1. Instalar o Docker
Para instalar o Docker no seu sistema, execute o seguinte comando:
```shell
./docker/install_docker.sh
```

______________________________________________________________________________________________________________________________

# Python Scripts

Este diretório contém scripts para instalar, verificar e desinstalar o Python em diferentes sistemas operacionais. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### check_python_install.sh
Este script verifica a instalação do Python e executa um script de teste.

### install_python.sh
Este script instala o Python em diferentes sistemas operacionais (macOS, Linux, Windows).

### uninstall_python.sh
Este script desinstala o Python de diferentes sistemas operacionais (macOS, Linux, Windows).

## Passo a Passo para Gerenciar a Instalação do Python

### 1. Verificar a Instalação do Python
Para verificar a instalação do Python, execute o seguinte comando:
```shell
./python/check_python_install.sh
```

### 2. Instalar o Python
Para instalar o Python no seu sistema, execute o seguinte comando:
```shell
./python/install_python.sh
```

### 3. Desinstalar o Python
Para desinstalar o Python do seu sistema, execute o seguinte comando:
```shell
./python/uninstall_python.sh
```

______________________________________________________________________________________________________________________________

# Coder Framework Scripts

Este diretório contém scripts para instalar, verificar e desinstalar o Coder Framework. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### check_coder.sh
Este script verifica a instalação do Coder Framework para diferentes versões do Python.

### install_coder.sh
Este script instala o Coder Framework para desenvolvimento em Python.

### uninstall_coder.sh
Este script desinstala o Coder Framework.

### release_scripts.sh
Este script ajuda a liberar e fazer upload de scripts para um bucket especificado.

## Passo a Passo para Gerenciar o Coder Framework

### 1. Verificar a Instalação do Coder
Para verificar a instalação do Coder Framework, execute o seguinte comando:
```shell
./coder-framework/check_coder.sh
```

### 2. Instalar o Coder Framework
Para instalar o Coder Framework, execute o seguinte comando:
```shell
./coder-framework/install_coder.sh
```

### 3. Desinstalar o Coder Framework
Para desinstalar o Coder Framework, execute o seguinte comando:
```shell
./coder-framework/uninstall_coder.sh
```

### 4. Liberar Scripts
Para liberar e fazer upload de scripts, execute o seguinte comando:
```shell
./coder-framework/release_scripts.sh
```

______________________________________________________________________________________________________________________________

# VSCode Scripts

Este diretório contém scripts para configurar e gerenciar o Visual Studio Code. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Scripts

### install_vscode_plugins.sh
Este script instala as extensões do VSCode especificadas no arquivo .env.

### setup_vscode.sh
Este script configura as configurações do VSCode.

### save_vscode_settings.sh
Este script salva as configurações atuais do VSCode.

## Passo a Passo para Configurar o VSCode

### 1. Instalar Plugins do VSCode
Para instalar as extensões do VSCode, execute o seguinte comando:
```shell
./vscode/install_vscode_plugins.sh
```

### 2. Configurar o VSCode
Para configurar as configurações do VSCode, execute o seguinte comando:
```shell
./vscode/setup_vscode.sh
```

### 3. Salvar Configurações do VSCode
Para salvar as configurações atuais do VSCode, execute o seguinte comando:
```shell
./vscode/save_vscode_settings.sh
```

______________________________________________________________________________________________________________________________

# Utility Scripts

Este diretório contém vários scripts utilitários para ajudar em tarefas comuns. Esses scripts são usados por outros scripts principais para realizar operações comuns.

## Scripts

### detect_os.sh
Este script detecta o sistema operacional em uso.

### choose_shell_profile.sh
Este script permite ao usuário escolher o perfil de shell a ser usado.

### colors_message.sh
Este script define cores para mensagens de saída.

### display_menu.sh
Este script exibe um menu usando o utilitário dialog.

### list_projects.sh
Este script lista os projetos disponíveis.

### load_env.sh
Este script carrega variáveis de ambiente de arquivos .env e .env.local.

## Como Usar

Estes scripts utilitários são geralmente chamados por outros scripts principais. Não é necessário executá-los diretamente, mas você pode incluí-los em seus próprios scripts usando o comando `source`.

______________________________________________________________________________________________________________________________

# Configuração do Ambiente

O arquivo `.env` contém várias configurações usadas pelos scripts. Certifique-se de revisar e atualizar este arquivo de acordo com suas necessidades antes de executar os scripts.

______________________________________________________________________________________________________________________________

# Começando

Para configurar seu ambiente de desenvolvimento, siga estas etapas:

1. Clone este repositório para sua máquina local.
2. Execute o script `grant_permissions.sh` para garantir que todos os scripts tenham permissões de execução:
   ```shell
   chmod +x grant_permissions.sh
   ./grant_permissions.sh
   ```
3. Execute o script `setup_enviroment.sh` para instalar e configurar todas as ferramentas e aplicativos necessários:
   ```shell
   ./setup_enviroment.sh