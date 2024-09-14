@echo off

:: Create a scheduled task to start Docker Desktop at login
echo Creating a scheduled task to start Docker Desktop at login...
schtasks /create /sc onlogon /tn "Start Docker Desktop" /tr "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo Scheduled task created successfully.