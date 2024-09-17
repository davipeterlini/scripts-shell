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
    if "%%a"=="Google Chrome" (
        :: Check for Chrome profile
        set profile_var=CHROME_PROFILE_WORK
        set profile=!%profile_var%!
        call open_chrome_profile.bat !profile!
    ) else if "%%a"=="Postman" (
        :: Check for Postman profile
        set profile_var=POSTMAN_PROFILE_WORK
        set profile=!%profile_var%!
        call open_postman_profile.bat !profile!
    ) else (
        call :open_app "%%a"
    )
)

:: Open terminal tabs
call open_terminal_tabs.bat %PROJECT_DIR_WORK%
endlocal