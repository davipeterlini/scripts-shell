# Configurações do Karabiner-Elements

Este diretório contém configurações personalizadas para o Karabiner-Elements, uma ferramenta poderosa para remapear teclas no macOS.

## Configurações Disponíveis

Cada configuração está em um arquivo separado na pasta `configs/`:

1. **Left Command to Left Control**: Troca o Command esquerdo pelo Control esquerdo
2. **Right Command to Right Control**: Troca o Command direito pelo Control direito
3. **Left Control to Left Command**: Troca o Control esquerdo pelo Command esquerdo
4. **Right Control to Right Command**: Troca o Control direito pelo Command direito
5. **Right Option to Switch Input Source**: Configura a tecla Option direita para alternar entre idiomas de teclado
6. **Shift + ~ to double quotes**: Muda a tecla Shift + ˜ (ao lado do botão 1) para escrever aspas duplas
7. **Alt + Tab to Command + Tab**: Configura Alt+Tab para funcionar como Command+Tab (alternar entre aplicativos)

## Como Instalar

### Pré-requisitos

1. Instale o Karabiner-Elements:
   - Baixe em: https://karabiner-elements.pqrs.org/
   - Ou instale via Homebrew: `brew install --cask karabiner-elements`

2. O script de instalação requer o utilitário `jq`:
   - Instale via Homebrew: `brew install jq`
   - O script tentará instalar automaticamente se não estiver presente

### Instalação

#### Instalação Completa

Execute o script de instalação sem parâmetros:
```bash
./setup_karabiner.sh
```

O script oferecerá as seguintes opções:
1. Aplicar todas as configurações
2. Selecionar configurações específicas para aplicar
3. Pular a aplicação de configurações

#### Instalação de Configurações Específicas

Você pode aplicar uma configuração específica diretamente:

```bash
# Aplicar uma configuração específica pelo nome do arquivo (com ou sem extensão .json)
./setup_karabiner.sh left_command_to_left_control

# Ou usando a opção --apply ou -a
./setup_karabiner.sh --apply right_option_to_switch_input_source
```

#### Listar Configurações Disponíveis

Para ver todas as configurações disponíveis:

```bash
./setup_karabiner.sh --list
# ou
./setup_karabiner.sh -l
```

### Validação

Se você encontrar problemas durante a instalação, verifique:
1. Se o Karabiner-Elements está em execução
2. Se as permissões de acessibilidade foram concedidas nas Preferências do Sistema
3. Se os arquivos de configuração estão no formato JSON válido

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
- Pode ser necessário reiniciar o Karabiner-Elements após aplicar as configurações (o script tentará fazer isso automaticamente)
- Para mais informações sobre como criar configurações personalizadas, consulte a documentação oficial: https://karabiner-elements.pqrs.org/docs/