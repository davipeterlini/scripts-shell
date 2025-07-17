# Configurações do Karabiner-Elements

Este diretório contém configurações personalizadas para o Karabiner-Elements, uma ferramenta poderosa para remapear teclas no macOS.

## Configurações Disponíveis

Cada configuração está em um arquivo separado na pasta `configs/`:

1. **Left Command to Left Control**: Troca o Command esquerdo pelo Control esquerdo
2. **Right Command to Right Control**: Troca o Command direito pelo Control direito
3. **Left Control to Left Command**: Troca o Control esquerdo pelo Command esquerdo
4. **Right Control to Right Command**: Troca o Control direito pelo Command direito
5. **Fn key to switch input source**: Configura a tecla Fn para alternar entre idiomas de teclado (usando o atalho Control+Espaço)
6. **Shift + ~ to double quotes**: Muda a tecla Shift + ˜ (ao lado do botão 1) para escrever aspas duplas

## Como Instalar

### Pré-requisitos

1. Instale o Karabiner-Elements:
   - Baixe em: https://karabiner-elements.pqrs.org/
   - Ou instale via Homebrew: `brew install --cask karabiner-elements`

2. O script de instalação requer o utilitário `jq`:
   - Instale via Homebrew: `brew install jq`
   - O script tentará instalar automaticamente se não estiver presente

### Instalação

Execute o script de instalação:
```bash
./install_karabiner_config.sh
```

O script permitirá que você escolha quais configurações deseja instalar:
- Selecione configurações individuais digitando seus números (ex: `1 3 5`)
- Digite `a` para instalar todas as configurações
- Digite `q` para sair sem instalar

### Validação

Se você encontrar problemas durante a instalação, pode validar os arquivos de configuração usando:
```bash
./validate_configs.sh
```

Este script verificará se todos os arquivos de configuração estão no formato correto e possuem os campos necessários.

## Personalização

Você pode editar os arquivos JSON na pasta `configs/` para personalizar as configurações conforme suas necessidades.

Cada arquivo de configuração deve seguir este formato:
```json
{
  "title": "Nome da Configuração",
  "rules": [
    {
      "description": "Descrição da regra",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "tecla_origem"
          },
          "to": [
            {
              "key_code": "tecla_destino"
            }
          ]
        }
      ]
    }
  ]
}
```

## Observações

- Pode ser necessário conceder permissões de acessibilidade ao Karabiner-Elements nas Preferências do Sistema
- Pode ser necessário reiniciar o Karabiner-Elements após aplicar as configurações (através do ícone na barra de menu)