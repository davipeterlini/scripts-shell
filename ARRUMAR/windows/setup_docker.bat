@echo off

:: Check if Docker Desktop is installed
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo Docker Desktop is not installed. Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    exit /b 1
)

:: Start Docker Desktop
echo Starting Docker Desktop...
start "" "Docker Desktop"

:: Wait until Docker daemon is up and running
:wait_for_docker
docker system info >nul 2>nul
if %errorlevel% neq 0 (
    echo Waiting for Docker to initialize...
    timeout /t 5 >nul
    goto wait_for_docker
)

echo Docker is running successfully.