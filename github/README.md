# GitHub Scripts

Este diretório contém scripts relacionados à automação e configuração de repositórios GitHub. Abaixo está uma descrição detalhada de cada script presente nesta pasta.

## Scripts

### 1. `configure_two_ssh_github_keys.sh`
**Descrição:** Este script configura duas chaves SSH distintas para serem usadas com diferentes contas do GitHub. Ele permite que você gerencie múltiplas contas GitHub no mesmo ambiente local.

**Uso:**
```bash
./configure_two_ssh_github_keys.sh
```

---

### 2. `connect_git_ssh_account.sh`
**Descrição:** Este script conecta uma conta GitHub ao seu ambiente local usando uma chave SSH previamente configurada. Ele atualiza o arquivo de configuração SSH para associar a chave à conta GitHub.

**Uso:**
```bash
./connect_git_ssh_account.sh
```

---

### 3. `generate-classic-token-gh-local.sh`
**Descrição:** Este script gera um token clássico de acesso pessoal (Personal Access Token - PAT) para o GitHub e o armazena localmente para ser usado em operações autenticadas, como push e pull.

**Uso:**
```bash
./generate-classic-token-gh-local.sh
```

---

## Sequência de Execução dos Scripts

Para configurar corretamente o ambiente GitHub, siga a sequência abaixo:

1. **Configure as chaves SSH para múltiplas contas:**
   Execute o script `configure_two_ssh_github_keys.sh` para criar e configurar as chaves SSH necessárias.

   ```bash
   ./configure_two_ssh_github_keys.sh
   ```

2. **Conecte uma conta GitHub usando SSH:**
   Use o script `connect_git_ssh_account.sh` para associar uma chave SSH a uma conta GitHub específica.

   ```bash
   ./connect_git_ssh_account.sh
   ```

3. **Gere um token clássico de acesso pessoal:**
   Por fim, execute o script `generate-classic-token-gh-local.sh` para criar e armazenar um token de acesso pessoal.

   ```bash
   ./generate-classic-token-gh-local.sh
   ```

Seguindo esta ordem, você garantirá que o ambiente esteja configurado corretamente para trabalhar com múltiplas contas GitHub e autenticação segura.

---

## Como Executar os Scripts

1. Certifique-se de que os scripts possuem permissões de execução:
   ```bash
   chmod +x script_name.sh
   ```

2. Execute o script desejado:
   ```bash
   ./script_name.sh
   ```

---

## Contribuição

Se você deseja adicionar ou modificar scripts nesta pasta, siga as diretrizes abaixo:
1. Certifique-se de que o script está bem documentado.
2. Teste o script antes de enviá-lo.
3. Envie um pull request com uma descrição clara das alterações.

---