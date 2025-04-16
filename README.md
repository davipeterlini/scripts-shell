# Scripts principais 

## Liberar a permissão de execução dos scripts
Antes de executar qualquer script deve liberar a permissão de execução dos scripts execute o script abaixo:
```shell
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

## Passo a Passo para Gerar e Configurar Chave SSH no Bitbucket

### 1. Configurar Múltiplas Contas Bitbucket
Este script configura múltiplas chaves SSH para diferentes contas do Bitbucket. Ele permite ao usuário adicionar várias chaves SSH ao agente SSH e configurar o SSH para usar diferentes chaves para diferentes contas do Bitbucket, execute o seguinte comando:
```shell
./bitbucket/configure_multi_ssh_bitbucket_keys.sh
```

### 2. Conectar a Conta Bitbucket com a Chave SSH
Este script conecta uma conta Bitbucket usando uma chave SSH específica. Ele permite ao usuário escolher uma identidade (chave SSH) e adicioná-la ao agente SSH, execute o seguinte comando:
```shell
./bitbucket/connect_bitbucket_ssh_account.sh
```

### 3. Gerar o BITBUCKET_TOKEN 
Este script gera um token clássico para autenticação com a API do Bitbucket. Ele guia o usuário através do processo de criação do token e armazena o token gerado em um arquivo de perfil para uso futuro, execute o seguinte comando:
```shell
./bitbucket/generate-classic-token-bb-local.sh
```
______________________________________________________________________________________________________________________________

# Coder Framework Scripts

Este diretório contém scripts para instalar, verificar e desinstalar o Coder Framework. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Uso dos Scripts do Coder Framework

### Verificar a Instalação do Coder
Para verificar a instalação do Coder Framework, execute o seguinte comando:
```shell
./coder-framework/check_coder.sh
```

### Instalar o Coder Framework
Este script verifica a instalação do Coder Framework para diferentes versões do Python, execute o seguinte comando:
```shell
./coder-framework/install_coder.sh
```

### Desinstalar o Coder Framework
Este script desinstala o Coder Framework, execute o seguinte comando:
```shell
./coder-framework/uninstall_coder.sh
```

### Liberar Scripts
Este script ajuda a liberar e fazer upload de scripts para um bucket especificado, execute o seguinte comando:
```shell
./coder-framework/release_scripts.sh
```
______________________________________________________________________________________________________________________________

# Docker Scripts

Este diretório contém scripts para instalar e configurar o Docker em diferentes sistemas operacionais. Abaixo está uma descrição detalhada do script presente neste diretório.

## Passo a Passo para Instalar o Docker

### 1. Instalar o Docker
Este script instala o Docker em diferentes sistemas operacionais (macOS, Linux, Windows), execute o seguinte comando:
```shell
./docker/install_docker.sh
```

______________________________________________________________________________________________________________________________

# GitHub Scripts

Este diretório contém vários scripts para configurar e gerenciar contas do GitHub e chaves SSH. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Passo a Passo para Gerar e Configurar Chave SSH no Github

### 2. Configurar Múltiplas Contas Github
Este script configura múltiplas chaves SSH para diferentes contas do GitHub. Ele permite ao usuário adicionar várias chaves SSH ao agente SSH e configurar o SSH para usar diferentes chaves para diferentes contas do GitHub.
Se você precisar configurar múltiplas contas do github no mesmo sistema, execute o seguinte comando:
```shell
./github/configure_multi_ssh_github_keys.sh
```

### 3. Conectar a Conta Github com a Chave SSH
Este script conecta uma conta GitHub usando uma chave SSH específica. Ele permite ao usuário escolher uma identidade (chave SSH) e adicioná-la ao agente SSH.
Para conectar sua conta Github usando a chave SSH gerada, execute o seguinte comando:
```shell
./github/connect_git_ssh_account.sh
```

### 4. Gerar o Github_TOKEN 
Este script gera um token clássico para autenticação com a API do GitHub. Ele guia o usuário através do processo de criação do token e armazena o token gerado em um arquivo de perfil para uso futuro.
Para gerar a o classic token do Github, execute o seguinte comando:
```shell
./github/generate-classic-token-gh-local.sh
```
______________________________________________________________________________________________________________________________

# Linux Scripts

Este diretório contém scripts para configurar e instalar aplicativos em sistemas Linux. Abaixo está uma descrição detalhada de cada script presente neste diretório.

## Passo a Passo para Configurar o Ambiente de Desenvolvimento no Linux

### 1. Instalar o Flatpak
Este script instala o Flatpak e configura os repositórios necessários.
Para instalar o Flatpak e configurar os repositórios, execute o seguinte comando:
```shell
./linux/install_flatpak.sh
```

### 2. Instalar Aplicativos via Flatpak
Este script instala aplicativos usando o Flatpak em sistemas Linux.
Para instalar os aplicativos usando o Flatpak, execute o seguinte comando:
```shell
./linux/install_flatpak_apps.sh
```

### 3. Instalar Aplicativos via apt-get
Este script instala aplicativos usando o apt-get em sistemas Linux baseados em Debian.
Para instalar os aplicativos usando o apt-get, execute o seguinte comando:
```shell
./linux/install_aptget_apps.sh
```
______________________________________________________________________________________________________________________________




# MAC Scripts

./install_brew_apps.sh app1 app2 app3
```

## Other Scripts

### `setup_iterm.sh`

Configures iTerm2 with custom settings and themes.

**Features:**
- Downloads and installs custom color schemes
- Sets up Oh My Zsh with custom plugins and themes
- Configures iTerm2 preferences
- Installs Powerline fonts for enhanced terminal appearance

**Usage:**
```bash
./setup_iterm.sh
```

### `setup_terminal.sh`

Sets up the default Terminal app with custom configurations.

**Features:**
- Installs Oh My Zsh
- Configures custom themes and plugins for Zsh
- Sets up aliases and environment variables

**Usage:**
```bash
./setup_terminal.sh
```

### `update_all_apps_mac.sh`

Updates all installed Homebrew packages and applications.

**Features:**
- Updates Homebrew itself
- Updates all installed formulae
- Updates all installed casks
- Performs cleanup to remove old versions

**Usage:**
```bash
./update_all_apps_mac.sh
```

## Additional Files

### `install_brew_apps.sh`

This script is responsible for installing applications using Homebrew. It's the core script for setting up your macOS development environment.

**Key Functions:**
- `install_homebrew()`: Installs Homebrew if not already present
- `install_brew_apps()`: Installs specified applications using Homebrew
- Error handling and progress reporting

## Usage Instructions

1. Ensure you have granted execute permissions to all scripts:
   ```
   chmod +x *.sh
   ```

2. Run the main script to install Homebrew apps:
   ```
   ./install_brew_apps.sh app1 app2 app3
   ```
   Replace `app1 app2 app3` with the names of the applications you want to install.

3. Run other scripts as needed for additional setup:
   ```
   ./setup_iterm.sh
   ./setup_terminal.sh
   ```

4. To update all apps:
   ```
   ./update_all_apps_mac.sh



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