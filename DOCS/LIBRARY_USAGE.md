# Usando Scripts Shell como Biblioteca

Este documento descreve como utilizar este repositório de scripts como uma biblioteca reutilizável em outros projetos.

## Métodos de Distribuição

Existem três abordagens principais para utilizar estes scripts em outros repositórios:

### 1. Git Submodule (Recomendado)

O Git Submodule permite incluir este repositório como uma dependência de outro projeto Git, mantendo-o atualizado e separado.

#### Instalação:

```bash
# No seu repositório de destino
git submodule add https://github.com/seu-usuario/scripts-shell.git lib/scripts-shell
git submodule init
git submodule update
```

#### Atualização:

```bash
# Atualizar para a versão mais recente
git submodule update --remote lib/scripts-shell
```

#### Uso:

```bash
# Em seus scripts
source "$(dirname "$0")/../lib/scripts-shell/utils/bash_tools.sh"
```

### 2. Symlink para Instalação Local

Mantenha uma cópia local do repositório e crie symlinks para os projetos que precisam utilizá-lo.

#### Instalação:

```bash
# Clone o repositório em um diretório central
cd ~/projects
git clone https://github.com/seu-usuario/scripts-shell.git

# Crie um symlink no seu projeto
cd ~/projects/seu-outro-projeto
ln -s ~/projects/scripts-shell lib/scripts
```

#### Uso:

```bash
# Em seus scripts
source "$(dirname "$0")/lib/scripts/utils/bash_tools.sh"
```

### 3. NPM Package (Para Projetos NodeJS)

Se você trabalha principalmente com projetos Node.js, pode empacotar os scripts como um pacote NPM.

#### Criar package.json:

```json
{
  "name": "scripts-shell",
  "version": "1.0.0",
  "description": "Biblioteca de scripts shell reutilizáveis",
  "files": ["**/*.sh", "assets/*"],
  "scripts": {
    "postinstall": "chmod +x **/*.sh"
  }
}
```

#### Instalação:

```bash
npm install --save-dev git+https://github.com/seu-usuario/scripts-shell.git
```

#### Uso:

```bash
# Em seus scripts
source "$(dirname "$0")/node_modules/scripts-shell/utils/bash_tools.sh"
```

## Estrutura Recomendada para Uso como Biblioteca

Para facilitar o uso como biblioteca, recomendo reorganizar o repositório com a seguinte estrutura:

```
scripts-shell/
├── lib/
│   ├── core/
│   │   ├── colors.sh
│   │   ├── tools.sh 
│   │   └── env.sh
│   ├── git/
│   │   ├── github.sh
│   │   └── bitbucket.sh
│   ├── system/
│   │   ├── mac.sh
│   │   └── linux.sh
│   └── terminal/
│       └── setup.sh
├── bin/
│   ├── setup-github.sh
│   ├── setup-terminal.sh
│   └── other executables...
└── assets/
    └── templates and resources...
```

## Instruções de Uso

### 1. Importar Funções

Para importar funções em seus scripts:

```bash
#!/bin/bash

# Defina o caminho para a biblioteca
SCRIPTS_LIB_PATH="$(dirname "$0")/lib/scripts-shell"

# Importe as funções necessárias
source "${SCRIPTS_LIB_PATH}/lib/core/tools.sh"
source "${SCRIPTS_LIB_PATH}/lib/git/github.sh"

# Use as funções
find_project_root
setup_github_account "trabalho" "seu@email.com" "seu-usuario"
```

### 2. Verificar Compatibilidade

Antes de usar as funções, você pode verificar a compatibilidade da versão:

```bash
#!/bin/bash

SCRIPTS_LIB_PATH="$(dirname "$0")/lib/scripts-shell"
source "${SCRIPTS_LIB_PATH}/lib/core/tools.sh"

# Verificar versão da biblioteca
if ! check_lib_version "1.0.0"; then
  echo "Esta versão da biblioteca não é compatível."
  exit 1
fi

# Continue com o script...
```

## Mantenha Atualizado

Para manter a biblioteca atualizada:

### Com Git Submodule:

```bash
git submodule update --remote lib/scripts-shell
git commit -am "Atualizar biblioteca de scripts"
```

### Com NPM:

```bash
npm update scripts-shell
```

## Contribuição

Se você fizer melhorias nos scripts enquanto os usa em seu projeto, considere contribuir com essas melhorias de volta ao repositório principal através de pull requests.

---

## Função de Instalação Automática

Adicione esta função de instalação rápida ao seu projeto:

```bash
install_scripts_lib() {
  local target_dir="${1:-lib/scripts}"
  
  if [ -d "$target_dir" ]; then
    echo "Diretório $target_dir já existe. Deseja sobrescrever? (s/n)"
    read -r response
    if [[ ! "$response" =~ ^[Ss]$ ]]; then
      echo "Instalação cancelada."
      return 1
    fi
  fi
  
  mkdir -p "$target_dir"
  
  echo "Instalando biblioteca de scripts em $target_dir..."
  git clone https://github.com/seu-usuario/scripts-shell.git "$target_dir"
  
  # Remover diretório .git para evitar conflitos
  rm -rf "$target_dir/.git"
  
  echo "Biblioteca instalada com sucesso!"
  echo "Use: source \"\$(dirname \"\$0\")/$target_dir/utils/bash_tools.sh\""
}
```