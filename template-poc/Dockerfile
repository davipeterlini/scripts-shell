# Use uma imagem oficial do Python como imagem base.
FROM python:3.8-slim as builder

# Define o diretório de trabalho dentro do container.
WORKDIR /app

# Copia os arquivos de requisitos primeiro para aproveitar o cache do Docker.
COPY requirements.txt .

# Instala as dependências.
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install pyinstaller

# Copia o restante dos arquivos da aplicação para o container.
COPY . .

# Gera o binário da aplicação utilizando PyInstaller ou sua ferramenta de escolha.
# Isso assume que você tem um script de build ou um comando direto do PyInstaller.
# Exemplo: pyinstaller --onefile app/main.py
RUN pyinstaller --onefile run.py -n app_vehicles

# Use uma nova etapa de build para manter a imagem final enxuta.
FROM python:3.8-slim

WORKDIR /app

# Copia apenas o binário gerado para a nova imagem, descartando o restante.
COPY --from=builder /dist/app_vehicles .

# Define o comando para executar o binário.
CMD ["./app/app_vehicles"]
