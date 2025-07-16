# Shell Utils Library

Biblioteca consolidada com utilitários shell para automatização e ferramentas de desenvolvimento.

## Instalação

1. Clone ou baixe o arquivo `shell-utils.sh`
2. Coloque-o no diretório `libs/` do seu projeto
3. Importe a biblioteca em seus scripts

## Uso Básico

### Importar a biblioteca

```bash
#!/bin/bash

# Importar a biblioteca
source "libs/shell-utils.sh"

# Agora você pode usar todas as funções disponíveis
print_success "Biblioteca carregada com sucesso!"
```

### Exemplo de uso em script

```bash
#!/bin/bash

# Carregar a biblioteca
source "libs/shell-utils.sh"

# Usar funcionalidades
print_header "Meu Script"
print_info "Iniciando processo..."

# Criar diretórios
create_directories "/tmp/meu-projeto" "src" "build" "docs"

# Obter confirmação do usuário
if get_user_confirmation "Deseja continuar?"; then
    print_success "Continuando..."
else
    print_alert "Operação cancelada"
    exit 1
fi
```

## Funcionalidades Disponíveis

### 🎨 Cores e Mensagens

Funções para exibir mensagens formatadas com cores:

```bash
print_info "Mensagem informativa"
print_success "Operação bem-sucedida"
print_alert "Atenção: algo importante"
print_error "Erro encontrado"
print_header "Título Principal"
print_header_info "Título Informativo"
print_yellow "Texto amarelo"
print_red "Texto vermelho"
print "Texto normal"
```

### 🔧 Ferramentas Bash

Utilitários para gerenciamento de arquivos e diretórios:

```bash
# Criar múltiplos diretórios
create_directories "/caminho/base" "dir1" "dir2" "dir3"

# Remover um diretório
remove_directory "/caminho/para/diretorio"

# Remover múltiplos diretórios
dirs_to_remove=("dir1" "dir2" "dir3")
remove_directories dirs_to_remove

# Obter confirmação do usuário
if get_user_confirmation "Deseja prosseguir?"; then
    echo "Usuário confirmou"
fi

# Limpar arquivos temporários
cleanup_temp_files "/tmp/meu-temp"
```

### 🖥️ Detecção de Sistema Operacional

Detecta automaticamente o sistema operacional:

```bash
# A detecção é feita automaticamente ao carregar a biblioteca
# Variáveis disponíveis:
echo "OS: $OS_NAME"
echo "Versão: $OS_VERSION"
echo "Codename: $OS_CODENAME"
echo "OS (alias): $os"

# Função manual (opcional)
detect_os
```

### 📋 Menus Interativos

Criar menus para interação com o usuário:

```bash
# Menu simples
display_menu
echo "Opções selecionadas: $MENU_CHOICES"

# Menu com dialog (se disponível)
display_dialog_menu
```

### 🚀 Execução de Scripts

Executar scripts com descrição e feedback:

```bash
execute_script "/caminho/para/script.sh" "Descrição do que o script faz"
```

### 📁 Gerenciamento de Repositórios Git

Funções para trabalhar com repositórios Git:

```bash
# Clonar um repositório
clone_repository "https://github.com/user/repo.git" "/caminho/destino"

# Atualizar um repositório existente
update_repository "/caminho/para/repo"

# Fazer merge de uma branch
merge_back_repository "/caminho/para/repo" "feature-branch"

# Gerenciar múltiplos repositórios
manage_repositories \
    "https://github.com/user/repo1.git" "/caminho/destino1" \
    "https://github.com/user/repo2.git" "/caminho/destino2"
```

### 🌐 Navegador

Abrir URLs no navegador padrão:

```bash
open_browser "https://github.com" "GitHub"
```

## Variáveis de Ambiente

A biblioteca exporta automaticamente:

- `OS_NAME`: Nome do sistema operacional
- `OS_VERSION`: Versão do sistema operacional  
- `OS_CODENAME`: Nome de código da versão
- `os`: Alias para OS_NAME
- `MENU_CHOICES`: Últimas opções selecionadas no menu

## Exemplos Práticos

### Script de Setup de Projeto

```bash
#!/bin/bash
source "libs/shell-utils.sh"

print_header "Setup do Projeto"

# Criar estrutura de diretórios
print_info "Criando estrutura de diretórios..."
create_directories "$(pwd)" "src" "tests" "docs" "build"

# Clonar dependências
print_info "Clonando dependências..."
manage_repositories \
    "https://github.com/user/dependency1.git" "./libs" \
    "https://github.com/user/dependency2.git" "./libs"

print_success "Setup concluído!"
```

### Script de Limpeza

```bash
#!/bin/bash
source "libs/shell-utils.sh"

print_header "Limpeza do Sistema"

if get_user_confirmation "Deseja limpar arquivos temporários?"; then
    cleanup_temp_files "/tmp/meu-app"
    
    # Remover diretórios de build
    dirs_to_clean=("build" "dist" "node_modules")
    remove_directories dirs_to_clean
    
    print_success "Limpeza concluída!"
else
    print_alert "Limpeza cancelada"
fi
```

### Script Multi-plataforma

```bash
#!/bin/bash
source "libs/shell-utils.sh"

print_header "Instalação Multi-plataforma"

case "$OS_NAME" in
    "macOS")
        print_info "Instalando no macOS..."
        brew install git
        ;;
    "Ubuntu"|"Debian")
        print_info "Instalando no $OS_NAME..."
        sudo apt-get update && sudo apt-get install git
        ;;
    "Windows")
        print_info "Instalando no Windows..."
        choco install git
        ;;
    *)
        print_error "Sistema não suportado: $OS_NAME"
        exit 1
        ;;
esac

print_success "Instalação concluída!"
```

## Informações da Biblioteca

Para ver informações sobre a biblioteca:

```bash
# Executar diretamente
bash libs/shell-utils.sh

# Ou chamar a função
shell_utils_info
```

## Estrutura da Biblioteca

A biblioteca está organizada nas seguintes seções:

1. **Configuração Inicial**: Configuração de variáveis e caminhos
2. **Cores e Mensagens**: Funções para output formatado
3. **Ferramentas Bash**: Utilitários para arquivos e diretórios
4. **Detecção de SO**: Identificação automática do sistema
5. **Menu e Interface**: Menus interativos
6. **Execução de Scripts**: Execução controlada de scripts
7. **Git**: Gerenciamento de repositórios
8. **Navegador**: Abertura de URLs
9. **Inicialização**: Setup automático

## Compatibilidade

- **macOS**: Totalmente suportado
- **Linux**: Totalmente suportado (Ubuntu, Debian, CentOS, etc.)
- **Windows**: Suportado via WSL, Git Bash, MSYS2

## Contribuição

Para contribuir com a biblioteca:

1. Mantenha o padrão de organização em seções
2. Adicione comentários descritivos
3. Teste em múltiplas plataformas
4. Atualize a documentação

## Instalação em Outros Projetos

### Método 1: Submodule Git (Recomendado)

```bash
# Adicionar como submodule
git submodule add https://github.com/seu-usuario/shell-utils.git libs/shell-utils
git submodule update --init --recursive

# Usar no script
source "libs/shell-utils/shell-utils.sh"
```

### Método 2: Instalação Automática

```bash
# Instalar localmente no projeto
curl -sL https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/install.sh | bash -s local

# Instalar globalmente no sistema
curl -sL https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/install.sh | sudo bash -s global

# Verificar instalação
curl -sL https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/install.sh | bash -s check
```

### Método 3: Download Direto

```bash
# Baixar diretamente
curl -sL https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh -o libs/shell-utils.sh
chmod +x libs/shell-utils.sh

# Ou com wget
wget https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/shell-utils.sh -O libs/shell-utils.sh
chmod +x libs/shell-utils.sh
```

### Método 4: Gerenciadores de Pacotes

#### Homebrew (macOS)

```bash
# Instalar via Homebrew
brew install seu-usuario/tap/shell-utils

# Usar
source "$(brew --prefix)/lib/shell-utils.sh"
```

#### APT (Ubuntu/Debian)

```bash
# Baixar e instalar pacote .deb
wget https://github.com/seu-usuario/shell-utils/releases/download/v1.0.0/shell-utils_1.0.0_all.deb
sudo dpkg -i shell-utils_1.0.0_all.deb

# Usar
source "/usr/local/lib/shell-utils.sh"
```

#### YUM/DNF (Red Hat/CentOS/Fedora)

```bash
# Baixar e instalar pacote .rpm
wget https://github.com/seu-usuario/shell-utils/releases/download/v1.0.0/shell-utils-1.0.0-1.noarch.rpm
sudo rpm -ivh shell-utils-1.0.0-1.noarch.rpm

# Usar
source "/usr/local/lib/shell-utils.sh"
```

## Empacotamento e Distribuição

### Usando o Makefile

```bash
# Instalar localmente
make install

# Criar pacote .deb
make deb

# Criar pacote .rpm
make rpm

# Preparar formula Homebrew
make homebrew

# Limpar arquivos temporários
make clean
```

### Usando o Script de Instalação

```bash
# Instalar localmente
bash install.sh local ./libs

# Instalar globalmente
sudo bash install.sh global

# Criar estrutura de empacotamento
bash install.sh package

# Desinstalar
sudo bash install.sh uninstall
```

### Estrutura de Empacotamento

```
libs/
├── shell-utils.sh      # Biblioteca principal
├── README.md           # Documentação
├── install.sh          # Script de instalação
├── Makefile           # Automação de build
├── package.json       # Metadados do pacote
└── test/              # Testes (opcional)
    └── test-runner.sh
```

## Distribuição

### 1. Repositório Git

```bash
# Criar repositório
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/seu-usuario/shell-utils.git
git push -u origin main

# Criar release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 2. Homebrew Tap (macOS)

```bash
# Criar tap repository
git clone https://github.com/seu-usuario/homebrew-tap.git
cd homebrew-tap
mkdir Formula
cp ../shell-utils/build/homebrew/shell-utils.rb Formula/
git add .
git commit -m "Add shell-utils formula"
git push origin main
```

### 3. Pacotes Debian/Ubuntu

```bash
# Criar pacote .deb
make deb

# Publicar no Launchpad PPA ou repositório próprio
# Upload para: https://launchpad.net/~seu-usuario/+archive/ubuntu/shell-utils
```

### 4. Pacotes Red Hat/CentOS

```bash
# Criar pacote .rpm
make rpm

# Publicar no COPR ou repositório próprio
# Upload para: https://copr.fedorainfracloud.org/
```

## Padrões de Empacotamento Shell

### 1. Estrutura Padrão

```
shell-utils/
├── lib/                # Bibliotecas principais
│   └── shell-utils.sh
├── bin/                # Scripts executáveis
│   └── shell-utils
├── etc/                # Configurações
├── doc/                # Documentação
│   └── README.md
├── test/               # Testes
│   └── test-runner.sh
├── Makefile            # Automação
├── configure           # Script de configuração
├── install.sh          # Instalador
└── package.json        # Metadados
```

### 2. Convenções de Nomenclatura

- **Bibliotecas**: `lib/nome-da-lib.sh`
- **Executáveis**: `bin/nome-do-comando`
- **Configurações**: `etc/nome-da-lib.conf`
- **Documentação**: `doc/README.md`, `man/nome.1`

### 3. Variáveis de Ambiente

```bash
# Definir no script principal
export SHELL_UTILS_HOME="/usr/local/lib/shell-utils"
export SHELL_UTILS_VERSION="1.0.0"
export PATH="$SHELL_UTILS_HOME/bin:$PATH"
```

### 4. Compatibilidade

```bash
# Verificar versão do bash
if [ "${BASH_VERSION%%.*}" -lt 4 ]; then
    echo "Erro: Bash 4.0+ necessário"
    exit 1
fi

# Verificar dependências
for cmd in git curl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Erro: $cmd não encontrado"
        exit 1
    fi
done
```

## Exemplo de Uso em Projeto

```bash
#!/bin/bash
# meu-projeto/setup.sh

# Instalar dependências shell
if [[ ! -f "libs/shell-utils.sh" ]]; then
    echo "Instalando shell-utils..."
    curl -sL https://raw.githubusercontent.com/seu-usuario/shell-utils/main/libs/install.sh | bash -s local libs
fi

# Carregar biblioteca
source "libs/shell-utils.sh"

# Usar funcionalidades
print_header "Setup do Projeto"
create_directories "$(pwd)" "src" "build" "dist"
print_success "Projeto configurado!"
```

## Licença

Esta biblioteca é de uso livre e pode ser modificada conforme necessário.