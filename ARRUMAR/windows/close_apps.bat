@echo off

:: Load environment variables from .env file
for /f "tokens=1,* delims==" %%a in ('type .env') do set %%a=%%b

:: Function to close an application gracefully
:close_app
set app_name=%1

echo Closing %app_name%...
taskkill /IM "%app_name%.exe" /F
exit /b

:: List of applications to close
setlocal enabledelayedexpansion
set apps=%APPS_TO_CLOSE_WORK%

for %%a in (!apps!) do (
    call :close_app "%%a"
)
endlocal