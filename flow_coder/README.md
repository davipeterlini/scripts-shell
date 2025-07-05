# Flow Coder - Scripts de Desenvolvimento

Este diretório contém scripts para instalação e configuração de ambientes de desenvolvimento para o Flow Coder em diferentes sistemas operacionais.

## Estrutura do Diretório

- **`linux/`**: Scripts específicos para sistemas Linux ([Ver detalhes](linux/README.md))
- **`windows/`**: Scripts específicos para sistemas Windows ([Ver detalhes](windows/README.md))

## Scripts Principais

Este diretório contém os seguintes scripts principais que funcionam em conjunto com os scripts específicos de cada sistema operacional:

### 1. `create_script_zips.sh`
Script para criar arquivos ZIP dos scripts de instalação e configuração para facilitar a distribuição:
- Compacta scripts específicos para cada sistema operacional
- Organiza os arquivos em uma estrutura padronizada
- Facilita a transferência para máquinas virtuais ou outros sistemas

### 2. `run_scripts.sh`
Script unificado para executar outros scripts com base em parâmetros:
- Detecta o sistema operacional automaticamente
- Executa o script apropriado com base nos argumentos fornecidos
- Facilita a automação de tarefas em diferentes ambientes

### 3. `transfer_to_vm.sh`
Script para transferir os scripts para máquinas virtuais:
- Suporta transferência via SSH
- Configura permissões adequadas nos arquivos transferidos
- Facilita a configuração de ambientes virtualizados

### 4. `upload_zips_to_gcs.sh`
Script para fazer upload dos arquivos ZIP para o Google Cloud Storage:
- Automatiza o processo de publicação dos scripts
- Configura permissões e metadados adequados
- Facilita a distribuição dos scripts através da nuvem

## Como Usar

```bash
# Tornar os scripts executáveis
chmod +x create_script_zips.sh
chmod +x run_scripts.sh
chmod +x transfer_to_vm.sh
chmod +x upload_zips_to_gcs.sh

# Criar arquivos ZIP dos scripts
./create_script_zips.sh

# Executar scripts específicos
./run_scripts.sh [nome_do_script] [argumentos]

# Transferir scripts para uma VM
./transfer_to_vm.sh [endereço_ip] [usuário] [caminho_destino]

# Fazer upload dos ZIPs para o Google Cloud Storage
./upload_zips_to_gcs.sh [nome_do_bucket]
```

## Configurando VMs para execução dos scripts

Para configurar corretamente as máquinas virtuais e permitir a execução dos scripts, siga este passo a passo:

### 1. Criação da VM
1. Abra seu software de virtualização (UTM, VirtualBox, VMware, etc.)
2. Crie uma nova máquina virtual com o sistema operacional desejado
3. Configure os recursos da VM:
   - **CPU**: Recomendado pelo menos 2 núcleos
   - **Memória**: Mínimo 4GB (4096MB) recomendado
   - **Armazenamento**: Mínimo 20GB recomendado

### 2. Configuração de Rede
1. Nas configurações da VM, configure a rede para permitir conexões SSH
2. Adicione regras de encaminhamento de porta se necessário:
   - **Protocolo**: TCP
   - **Porta do Host**: 2222 (ou outra porta de sua escolha)
   - **Porta do Convidado**: 22
   - **Descrição**: SSH

### 3. Configuração de Compartilhamento de Arquivos
1. Configure o compartilhamento de diretórios entre o host e a VM
2. Adicione a pasta que contém os scripts como diretório compartilhado
3. Defina o ponto de montagem apropriado na VM

### 4. Transferência e Execução dos Scripts
1. Use o script `transfer_to_vm.sh` para transferir os scripts para a VM
2. Conecte-se à VM via SSH
3. Execute os scripts apropriados para o sistema operacional da VM

## Notas

- Os scripts verificam dependências e instalam componentes necessários automaticamente
- Para detalhes sobre scripts específicos de cada sistema operacional, consulte os READMEs nas pastas `linux/` e `windows/`
- Os scripts de criação de ZIP e upload para GCS requerem ferramentas específicas que serão instaladas automaticamente se necessário