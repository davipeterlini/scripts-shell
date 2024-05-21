# backend-nestjs-example

## Organization Project
backend-nestjs-example/
│
├── other_struture/     # Contains struture of code
│   src/
    |-- entities/
    |   `-- veiculo.entity.ts
    |-- services/
    |   `-- veiculos.service.ts
    |-- controllers/
    |   `-- veiculos.controller.ts
    `-- modules/
        `-- veiculos.module.ts
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

1. Install node
```shell script
# Install brew for MAC
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install node
# or
apt-get install node
node -v
npm -v
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

3. Install NestCLI
```shell script
npm i -g @nestjs/cli
```

### Create project
```shell script 
# Choose NPM
nest new .
```

### First, run the development server:
```shell script
npm run start
```

### Dependencies 
1. Install
```shell script 
# Postgres
npm install --save @nestjs/typeorm typeorm pg
# Env
npm install --save @nestjs/config
# Rest
npm install --save @nestjs/common
```

2. Update
```shell script 
# Rest
npm update @nestjs/common
npm update @nestjs/typeorm
npm update @nestjs/config
npm install @nestjs/common@latest

```


## Execute APP

1. Docker Up
```shell
docker-compose up -d
```

4. Exec APP
```shell
npm run build
npm run start:dev
npm run start:prod
```

5. Run tests
```shell
chmod +x curl_test.sh
./scripts/curl_test.sh
```

6. Database Validation
```shell
# Open Dbeaver --> Create a New Connection --> Choose Database type --> Open Editor and exec query: 
SELECT * FROM vehicles;
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
npm install -g pkg
```

2. Generate Bynary
```shell
nest build backend-nestjs-example
npm run build
npm install -g pkg
# Specified Arc + Inside Bin folder
pkg . --targets node14-linux-x64 --out-path=bin
# ou
npx pkg . --targets node14-linux-x64 --out-path=bin
npx pkg . --targets node14-macos-x64 --out-path=bin
npx pkg . --targets node21-win-x64 --out-path=bin
```

3. Exec Bynary
```shell
chmod +x ./bin/backend-nestjs-example]
./bin/backend-nestjs-example
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









<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="200" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://coveralls.io/github/nestjs/nest?branch=master" target="_blank"><img src="https://coveralls.io/repos/github/nestjs/nest/badge.svg?branch=master#9" alt="Coverage" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

## Description

[Nest](https://github.com/nestjs/nest) framework TypeScript starter repository.

## Installation

```bash
$ npm install
```

## Running the app

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Test

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://kamilmysliwiec.com)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](LICENSE).
