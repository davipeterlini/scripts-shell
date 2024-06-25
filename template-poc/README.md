# {{REPO_NAME}}

## Organization Project
{{REPO_NAME}}/
│
├── other_struture/     # Contains struture of code
│   ├── files
├── scripts             # Configurações do aplicativo
│   ├── setup.sh        # Script use for Setup to poc
├── .gitignore          # Ignore Files on git
├── Dockerfile
├── docker-compose.yml  # Docker compose 
├── .env                # Enviroment Variables
└── README.md           # Doc

## Getting Started - Setup

### Pre-recs
- Docker and Docker Compose
- 
- 

### Initial Setup

1. Install $FRAMEWORK
```shell script
# Install brew for MAC
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install $FRAMEWORK
# or
apt-get install $FRAMEWORK
# Check version 
```

2. Create Repo (Optional)
```shell script
git clone https://github.com/davipeterlini/script-shell-example.git
cd script-shell-example
./grant_permissions.sh
# set tokens in tokens file
# Example: export GITHUB_TOKEN="seu_token"
./poc-setup.sh
```

### Create project
```shell script

```

### First, run the development server:
```shell script

```
## Execute APP

1. Create o Virtual Enviroment
```shell

```

2. Install dependencies
```shell

```

3. Docker Up
```shell
docker-compose up -d
```

4. Exec APP
```shell

```

5. Run tests
```shell
curl http://localhost:XXXX

```

6. Database Validation
```shell
# Open Dbeaver --> Create a New Connection --> Choose Database type --> Open Editor and exec query: 
SELECT * FROM TABLE_NAME;
```

## Execute APP Test

1. Adding Dependencies for test
```shell

```

2. Update virtual enviroment
```shell

```

3. Exec APP Tests
```shell

```

4. Coverage Test
```shell

```

## Create Binary Packge

1. Adding Dependencies for Create Binary
```shell

```

2. Run Binary
```shell
chmod +x $BINARY_FILE
```

## Generatge Image with Docker

1. Create Image
```shell
docker build -t app_image .
docker build -t app_image:latest .
docker build --no-cache -t app_image:latest .
```

2. Run image with docker
```shell
docker run -p 5000:5000 app_image:latest
docker run -d -p 5000:5000 app_image:latest
```

3. Run tests
```shell
curl http://localhost:5000/
curl -d '{"chave":"valor"}' -H "Content-Type: application/json" -X POST http://localhost:5000/caminho_do_recurso
```


# Docker compose to build 
docker-compose up --build



















## Execute APP


## Setup Inicial

### Requisitos

- Python 3.8+
- Docker e Docker Compose
- Homebrew (para usuários MAC)

### Install



2. Install Python
```shell
brew install python
brew link --overwrite python@3.12
# brew reinstall python@3.12
python3 --version
pip3 --version
```

3. Clone o repositório:
```shell
git clone git@github.com:davipeterlini/backend-python-example.git
```

4. Create Struture
```shell
cd scripts  
python3 create_struture.py
```

## Execute APP

1. Create o Virtual Enviroment
```shell
python3 -m venv virtual_enviroment
source virtual_enviroment/bin/activate
# Stop virtual enviroment
deactivate
```

2. Install dependencies
```shell
pip3 install -r requirements.txt
pip install Flask-SQLAlchemy
```

3. Docker Up
```shell
docker-compose up -d
```

4. Exec APP
```shell
python run.py
```

5. Run tests
```shell
curl http://localhost:5000/
# POST
curl -X POST http://localhost:5000/vehicles \
     -H 'Content-Type: application/json' \
     -d '{"modelo": "Modelo Exemplo", "marca": "Marca Exemplo", "ano": 2020, "preco": 35000}'
# GET
curl http://localhost:5000/vehicles
# UPDATE
curl -X PUT http://localhost:5000/vehicles/1 \
-H 'Content-Type: application/json' \
-d '{"modelo": "Modelo Atualizado", "marca": "Marca Atualizada", "ano": 2021, "preco": 50000}'
# DELETE
curl -X DELETE http://localhost:5000/vehicles/1
```

6. Database Validation
```shell
# Open Dbeaver --> Create a New Connection --> Create a SQLite with instance/vehicles.db --> Open Editor and exec query: 
SELECT * FROM vehicles;
```

## Execute APP Test

1. Adding Dependencies in requirements.txt
```shell
pytest
pytest-flask
Flask-Testing
coverage
```

2. Update virtual enviroment
```shell
source virtual_enviroment/bin/activate
pip install -r requirements.txt
```

3. Exec APP Tests
```shell
pytest tests/
```

4. Coverage Test
```shell
coverage run -m pytest tests/
coverage report
```


## Create Binary Packge

1. Dependencies
```shell
source virtual_enviroment/bin/activate
pip install pyinstaller
```

2. Install pyinstaller
```shell
cd scripts
chmod +x generate_bynary.sh
./generate_bynary.sh
```

3. Run Binary
```shell
chmod +x dist/app_vehicles
./dist/app_vehicles
```

## Generatge Image

1. Create Image
```shell
docker build -t app_image .
docker build -t app_image:latest .
docker build --no-cache -t app_image:latest .
```

2. Run image with docker
```shell
docker run -p 5000:5000 app_image:latest
docker run -d -p 5000:5000 app_image:latest
```

3. Run tests
```shell
curl http://localhost:5000/
curl -d '{"chave":"valor"}' -H "Content-Type: application/json" -X POST http://localhost:5000/caminho_do_recurso
```


# Docker compose to build 
docker-compose up --build



# Utils
Clean All Images 
```shell
docker rmi -f $(docker images -a -q)
```

Change Lib
```shell
sed -i '' '/"@ci-t-hyperx\/flow-user":/d' package.json && yarn add /Users/davi.peterlini/projects-cit/flow/core/flow-core-lib-commons/packages/flow-user && yarn install && yarn de
```
