@echo off

:: Load environment variables from .env file
for /f "tokens=1,* delims==" %%a in ('type .env') do set %%a=%%b

:: Function to open an application
:open_app
set app_name=%1
echo Opening %app_name%...
start "" "%app_name%"
exit /b

:: List of applications to open
setlocal enabledelayedexpansion
set apps=%APPS_TO_OPEN_WORK%

for %%a in (!apps!) do (
    call :open_app "%%a"
)
endlocal