@echo off

:: Load environment variables from .env file
for /f "tokens=1,* delims==" %%a in ('type .env') do set %%a=%%b

:: Function to check if an application is running
:is_app_running
set app_name=%1
tasklist /FI "IMAGENAME eq %app_name%.exe" 2>NUL | find /I /N "%app_name%.exe">NUL
if "%ERRORLEVEL%"=="0" (
    exit /b 0
) else (
    exit /b 1
)

:: Function to open Google Chrome with a specific profile
:open_chrome_with_profile
set profile=%1

call :is_app_running "chrome"
if "%ERRORLEVEL%"=="0" (
    echo Google Chrome is already running.
) else (
    echo Opening Google Chrome with profile %profile%...
    start "" "chrome.exe" --profile-directory="%profile%"
)
exit /b

:: Main function to open Google Chrome with the specified profile
set project_dir=%1

if "%project_dir%"=="" (
    echo No project directory specified. Exiting...
    exit /b 1
)

:: Extract the Chrome profile from the project-specific variable
set profile_var=CHROME_PROFILE_%project_dir%
set profile=!%profile_var%!

if "%profile%"=="" (
    echo No profile found for project %project_dir%. Exiting...
    exit /b 1
)

call :open_chrome_with_profile "%profile%"

:: Execute the main function if the script is run directly
if "%~0"=="%~f0" (
    call :main %*
)