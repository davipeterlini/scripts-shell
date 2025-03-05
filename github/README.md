# GitHub Scripts

Este diretório contém scripts úteis para configurar e gerenciar contas do GitHub, incluindo geração de chaves SSH, configuração de tokens e gerenciamento de múltiplas contas.

## Scripts Disponíveis

### 1. `generate-classic-token-gh-local.sh`
- **Descrição**: Gera um token clássico do GitHub para autenticação local.
- **Uso**:
  ```bash
  ./github/generate-classic-token-gh-local.sh
  ```

### 2. `configure_two_ssh_github_keys.sh`
- **Descrição**: Configura duas chaves SSH para diferentes contas do GitHub.
- **Uso**:
  ```bash
  ./github/configure_two_ssh_github_keys.sh
  ```

### 3. `connect_git_ssh_account.sh`
- **Descrição**: Conecta uma conta do GitHub usando uma chave SSH específica.
- **Uso**:
  ```bash
  ./github/connect_git_ssh_account.sh
  ```

### 4. `setup_multiple_bitbucket_accounts.sh`
- **Descrição**: Configura múltiplas contas do GitHub para uso simultâneo.
- **Uso**:
  ```bash
  ./github/setup_multiple_bitbucket_accounts.sh
  ```

### 5. `ssh_multiple_bitbucket_accounts.sh`
- **Descrição**: Gerencia conexões SSH para múltiplas contas do GitHub.
- **Uso**:
  ```bash
  ./github/ssh_multiple_bitbucket_accounts.sh
  ```

## Notas
- Certifique-se de conceder permissões de execução aos scripts antes de usá-los:
  ```bash
  chmod +x ./github/*.sh
  ```
- Execute os scripts no terminal e siga as instruções interativas, se aplicável.
- Verifique se você possui as dependências necessárias instaladas, como `ssh` e `git`.

## Requisitos
- **Sistema Operacional**: Compatível com macOS, Linux e Windows (via WSL).
- **Dependências**: `ssh`, `git`, e outras ferramentas relacionadas ao gerenciamento de chaves e autenticação.

## Dicas
- Para verificar se as chaves SSH estão configuradas corretamente, use:
  ```bash
  ssh -T git@github.com
  ```
- Para gerenciar múltiplas contas, configure o arquivo `~/.ssh/config` adequadamente.