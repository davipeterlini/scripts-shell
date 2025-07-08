# Ferramentas de IA - Script de Instalação

Este diretório contém um script para instalar e configurar ferramentas de IA para desenvolvimento:

- Claude Code (Anthropic)
- OpenAI Codex
- Google Gemini CLI

## Estrutura do Script

O script foi desenvolvido seguindo princípios de Clean Code:

- **Modularidade**: Funções pequenas com responsabilidades únicas
- **Legibilidade**: Nomes descritivos e comentários explicativos
- **Tratamento de erros**: Verificação de requisitos e resultados de instalação
- **Manutenibilidade**: Constantes para nomes de pacotes e estrutura lógica clara

## Requisitos

- Node.js e npm instalados
- Acesso à internet
- Chaves de API para os serviços (opcional durante a instalação, mas necessário para uso)
- Utilitário `colors_message.sh` do diretório utils (já incluído no script)

## Como usar

1. Torne o script executável (se ainda não estiver):
   ```bash
   chmod +x install_ai_tools.sh
   ```

2. Execute o script:
   ```bash
   ./install_ai_tools.sh
   ```

3. Siga as instruções na tela para fornecer suas chaves de API quando solicitado.

## Configuração manual das chaves de API

Se você preferir configurar as chaves de API manualmente:

- Para OpenAI Codex:
  ```bash
  export OPENAI_API_KEY="your-api-key-here"
  ```

- Para Google Gemini:
  ```bash
  export GEMINI_API_KEY="your-api-key-here"
  ```

Para tornar essas configurações permanentes, adicione essas linhas ao seu arquivo `~/.bashrc` ou `~/.zshrc`.

## Uso das ferramentas

Após a instalação, você pode usar as ferramentas com os seguintes comandos:

- Claude Code: `claude <comando>`
- OpenAI Codex: `codex <comando>`
- Google Gemini CLI: `gemini <comando>`

## Documentação oficial

Consulte a documentação oficial de cada ferramenta para obter instruções detalhadas:

- Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview
- OpenAI Codex: https://github.com/openai/codex
- Google Gemini CLI: https://github.com/google-gemini/gemini-cli