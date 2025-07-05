# Flow Coder Windows Scripts

Este diretório contém scripts para instalação e configuração do Flow Coder e IDEs em sistemas Windows.

## Scripts Disponíveis

### Scripts Batch (.bat)

1. **`install_flow_coder.bat`**
   - Script batch para instalar a extensão Flow Coder no Windows
   - Suporta VSCode e IDEs JetBrains

2. **`install_ides.bat`**
   - Script batch para instalar IDEs no Windows
   - Instala Visual Studio Code e produtos JetBrains

3. **`install_powershell.bat`**
   - Script batch para instalar/atualizar o PowerShell no Windows

4. **`open_ides.bat`**
   - Script batch para abrir IDEs no Windows
   - Suporta VSCode, IntelliJ IDEA Ultimate e Community Edition

5. **`setup.bat`**
   - Script batch principal para configuração do ambiente de desenvolvimento no Windows

6. **`test_flow_coder.bat`**
   - Script batch para testar a instalação e funcionalidade do Flow Coder no Windows

### Scripts PowerShell (.ps1)

1. **`install_flow_coder.ps1`**
   - Script PowerShell para instalar a extensão Flow Coder no Windows
   - Oferece opções avançadas de instalação e configuração

2. **`install_ides.ps1`**
   - Script PowerShell para instalar IDEs no Windows
   - Suporta Visual Studio Code, JetBrains Toolbox, IntelliJ IDEA Ultimate e Community Edition

3. **`open_ides.ps1`**
   - Script PowerShell para abrir IDEs no Windows
   - Suporta VSCode, IntelliJ IDEA Ultimate e Community Edition

4. **`setup.ps1`**
   - Script PowerShell principal para configuração do ambiente de desenvolvimento no Windows

5. **`test_flow_coder.ps1`**
   - Script PowerShell para testar a instalação e funcionalidade do Flow Coder no Windows

## Utilitários

O diretório `utils/` contém scripts auxiliares PowerShell:

- **`colors_message.ps1`**: Funções para exibir mensagens coloridas no console
- **`detect_os.ps1`**: Funções para detectar a versão do Windows e suas características
- **`generic_utils.ps1`**: Funções utilitárias genéricas
- **`grant_permissions.ps1`**: Funções para gerenciar permissões de arquivos e diretórios

## Como Executar os Scripts

### Execução Individual dos Scripts

#### Usando Scripts Batch (.bat)

1. **Instalar PowerShell (recomendado primeiro)**
   ```cmd
   install_powershell.bat
   ```
   Este script:
   - Verifica a versão atual do PowerShell
   - Instala/atualiza para a versão mais recente do PowerShell
   - Configura as permissões de execução necessárias

2. **Instalar IDEs**
   ```cmd
   install_ides.bat
   ```
   Este script:
   - Oferece um menu para selecionar quais IDEs instalar
   - Instala o Visual Studio Code
   - Instala o JetBrains Toolbox e/ou IDEs específicas da JetBrains

3. **Instalar Flow Coder**
   ```cmd
   install_flow_coder.bat
   ```
   Este script:
   - Verifica se as IDEs necessárias estão instaladas
   - Instala a extensão Flow Coder no VSCode
   - Prepara a instalação do plugin Flow Coder para IDEs JetBrains

4. **Abrir IDEs**
   ```cmd
   :: Abrir VSCode
   open_ides.bat vscode

   :: Abrir JetBrains Ultimate com um projeto específico
   open_ides.bat ultimate C:\caminho\para\meu\projeto

   :: Abrir JetBrains Community Edition
   open_ides.bat community
   ```

5. **Testar Flow Coder**
   ```cmd
   test_flow_coder.bat
   ```
   Este script:
   - Verifica se o Flow Coder está instalado corretamente
   - Testa a funcionalidade básica do Flow Coder
   - Fornece feedback sobre o status da instalação

#### Usando Scripts PowerShell (.ps1)

Para executar scripts PowerShell, primeiro abra o PowerShell como Administrador e configure a política de execução:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

1. **Instalar IDEs**
   ```powershell
   ./install_ides.ps1
   ```
   Este script:
   - Oferece opções avançadas para instalação de IDEs
   - Instala o Visual Studio Code com configurações personalizáveis
   - Instala o JetBrains Toolbox e/ou IDEs específicas com opções avançadas

2. **Instalar Flow Coder**
   ```powershell
   ./install_flow_coder.ps1
   ```
   Este script:
   - Oferece opções avançadas para instalação do Flow Coder
   - Suporta instalação silenciosa e personalizada
   - Configura integrações avançadas com as IDEs

3. **Abrir IDEs**
   ```powershell
   # Abrir VSCode
   ./open_ides.ps1 vscode

   # Abrir JetBrains Ultimate com um projeto específico
   ./open_ides.ps1 ultimate C:\caminho\para\meu\projeto

   # Abrir JetBrains Community Edition
   ./open_ides.ps1 community
   ```

4. **Testar Flow Coder**
   ```powershell
   ./test_flow_coder.ps1
   ```
   Este script:
   - Realiza testes avançados do Flow Coder
   - Fornece diagnósticos detalhados
   - Oferece opções para resolver problemas automaticamente

### Execução via Script Setup

#### Usando Script Batch

```cmd
setup.bat
```

Este script:
1. Verifica se o PowerShell está atualizado (chamando `install_powershell.bat`)
2. Instala as IDEs necessárias (chamando `install_ides.bat`)
3. Instala o Flow Coder (chamando `install_flow_coder.bat`)
4. Executa testes para verificar a instalação (chamando `test_flow_coder.bat`)
5. Fornece instruções finais para o usuário

#### Opções do Script Setup Batch

```cmd
:: Instalação completa (padrão)
setup.bat

:: Instalação apenas das IDEs
setup.bat --ides-only

:: Instalação apenas do Flow Coder (assume que as IDEs já estão instaladas)
setup.bat --flow-coder-only

:: Modo silencioso (sem prompts interativos)
setup.bat --silent

:: Ajuda
setup.bat --help
```

#### Usando Script PowerShell

```powershell
# Abrir PowerShell como Administrador primeiro
Set-ExecutionPolicy Bypass -Scope Process -Force
./setup.ps1
```

Este script:
1. Verifica os requisitos do sistema
2. Instala as IDEs necessárias (chamando `install_ides.ps1`)
3. Instala o Flow Coder (chamando `install_flow_coder.ps1`)
4. Executa testes para verificar a instalação (chamando `test_flow_coder.ps1`)
5. Configura integrações avançadas e otimizações
6. Fornece instruções detalhadas para o usuário

#### Opções do Script Setup PowerShell

```powershell
# Instalação completa (padrão)
./setup.ps1

# Instalação apenas das IDEs
./setup.ps1 -IdesOnly

# Instalação apenas do Flow Coder (assume que as IDEs já estão instaladas)
./setup.ps1 -FlowCoderOnly

# Modo silencioso (sem prompts interativos)
./setup.ps1 -Silent

# Instalação com configurações personalizadas
./setup.ps1 -CustomConfig "caminho\para\config.json"

# Ajuda
./setup.ps1 -Help
```

## Solução de Problemas Comuns

### Problema: Erro de política de execução do PowerShell
**Solução**: Execute o PowerShell como Administrador e configure a política de execução:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Problema: Falha na instalação das IDEs
**Solução**: Execute o script de instalação com privilégios de administrador:
- Clique com o botão direito no arquivo .bat e selecione "Executar como administrador"
- Ou para PowerShell, abra o PowerShell como administrador e execute o script

### Problema: Flow Coder não aparece nas IDEs
**Solução**: Reinstale o Flow Coder com opções de força:
```cmd
install_flow_coder.bat --force
```
Ou para PowerShell:
```powershell
./install_flow_coder.ps1 -Force
```

### Problema: Erro "O sistema não pode encontrar o caminho especificado"
**Solução**: Verifique se você está executando os scripts no diretório correto:
```cmd
cd caminho\para\flow_coder\windows
```

## Notas

- Os scripts PowerShell oferecem funcionalidades mais avançadas que os scripts batch
- Para executar scripts PowerShell, pode ser necessário alterar a política de execução
- Todos os scripts verificam dependências e instalam componentes necessários automaticamente
- Os scripts de IDE oferecem um menu interativo para escolher quais aplicativos instalar
- Para produtos JetBrains, é recomendado instalar o JetBrains Toolbox para gerenciar facilmente as IDEs e suas atualizações