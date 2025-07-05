# Flow Coder Linux Scripts

Este diretório contém scripts para instalação e configuração do Flow Coder e IDEs em sistemas Linux.

## Scripts Disponíveis

### 1. `install_flow_coder.sh`
Script para instalar a extensão Flow Coder em sistemas Linux:
- **VSCode**: Instala a extensão Flow Coder via linha de comando ou manualmente
- **IDEs JetBrains**: Detecta instalações JetBrains (Ultimate e Community Edition) e prepara para instalação do plugin

### 2. `install_ides.sh`
Script para instalar IDEs em sistemas Linux:
- **Visual Studio Code**
- **JetBrains Toolbox** (gerenciador de produtos JetBrains)
- **IntelliJ IDEA Ultimate**
- **IntelliJ IDEA Community Edition**

### 3. `open_ides.sh`
Script para abrir IDEs em sistemas Linux:
- **Visual Studio Code**
- **JetBrains IntelliJ IDEA Ultimate**
- **JetBrains IntelliJ IDEA Community Edition**

### 4. `setup.sh`
Script de configuração principal que orquestra a instalação e configuração do ambiente de desenvolvimento em sistemas Linux.

### 5. `test_flow_coder.sh`
Script para testar a instalação e funcionalidade do Flow Coder em sistemas Linux.

## Utilitários

O diretório `utils/` contém scripts auxiliares:

- **`colors_message.sh`**: Funções para exibir mensagens coloridas no terminal
- **`detect_os.sh`**: Funções para detectar o sistema operacional e suas características
- **`generic_utils.sh`**: Funções utilitárias genéricas
- **`grant_permissions.sh`**: Funções para gerenciar permissões de arquivos e diretórios

## Como Executar os Scripts

### Preparação Inicial

Antes de executar qualquer script, torne-os executáveis:

```bash
# Tornar todos os scripts executáveis
chmod +x *.sh
chmod +x utils/*.sh
```

### Execução Individual dos Scripts

#### 1. Instalar Flow Coder

```bash
./install_flow_coder.sh
```

Este script:
- Verifica se o VSCode está instalado e instala a extensão Flow Coder
- Detecta instalações JetBrains e prepara para instalação do plugin
- Oferece instruções para instalação manual quando necessário

#### 2. Instalar IDEs

```bash
./install_ides.sh
```

Este script:
- Oferece um menu interativo para escolher quais IDEs instalar
- Instala o VSCode usando o gerenciador de pacotes apropriado para sua distribuição
- Instala o JetBrains Toolbox e/ou IDEs específicas da JetBrains
- Configura as IDEs com configurações básicas recomendadas

#### 3. Abrir IDEs

```bash
# Abrir VSCode
./open_ides.sh vscode

# Abrir JetBrains Ultimate com um projeto específico
./open_ides.sh ultimate /caminho/para/meu/projeto

# Abrir JetBrains Community Edition
./open_ides.sh community
```

#### 4. Testar Flow Coder

```bash
./test_flow_coder.sh
```

Este script:
- Verifica se o Flow Coder está instalado corretamente
- Testa a funcionalidade básica do Flow Coder
- Fornece feedback sobre o status da instalação

### Execução via Script Setup

O script `setup.sh` é o ponto de entrada principal que orquestra todo o processo de instalação e configuração:

```bash
./setup.sh
```

Este script:
1. Verifica os requisitos do sistema
2. Instala as IDEs necessárias (chamando `install_ides.sh`)
3. Instala o Flow Coder (chamando `install_flow_coder.sh`)
4. Executa testes para verificar a instalação (chamando `test_flow_coder.sh`)
5. Fornece instruções finais para o usuário

#### Opções do Script Setup

```bash
# Instalação completa (padrão)
./setup.sh

# Instalação apenas das IDEs
./setup.sh --ides-only

# Instalação apenas do Flow Coder (assume que as IDEs já estão instaladas)
./setup.sh --flow-coder-only

# Modo silencioso (sem prompts interativos)
./setup.sh --silent

# Ajuda
./setup.sh --help
```

## Solução de Problemas Comuns

### Problema: Permissões negadas ao executar scripts
**Solução**: Verifique se os scripts têm permissão de execução:
```bash
chmod +x *.sh
chmod +x utils/*.sh
```

### Problema: Dependências faltando
**Solução**: Os scripts tentarão instalar dependências automaticamente, mas podem requerer privilégios de administrador:
```bash
sudo ./setup.sh
```

### Problema: IDEs não são encontradas após instalação
**Solução**: Verifique se as IDEs foram instaladas corretamente e estão no PATH:
```bash
which code
which idea
```

### Problema: Flow Coder não aparece nas IDEs
**Solução**: Reinstale o Flow Coder manualmente:
```bash
./install_flow_coder.sh --force
```

## Notas

- Todos os scripts verificam dependências e instalam componentes necessários automaticamente
- Os scripts de IDE oferecem um menu interativo para escolher quais aplicativos instalar
- Para produtos JetBrains, é recomendado instalar o JetBrains Toolbox para gerenciar facilmente as IDEs e suas atualizações
- Os scripts de instalação do Flow Coder detectam automaticamente o sistema operacional e as instalações de IDE existentes
- Os scripts `open_ides` verificam a disponibilidade das IDEs no sistema e fornecem mensagens de erro apropriadas se não forem encontradas