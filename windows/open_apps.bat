@echo off

:: List of applications to open
set apps=(
    "Code"
    "Robo3T"
    "Postman"
    "Meld"
    "Rambox"
    "chrome"
    "Spotify"
    "Docker Desktop"
)

:: Function to open an application
:open_app
set app_name=%1
echo Opening %app_name%...
start "" "%app_name%"
exit /b

:: Loop through the list of applications and open each one
for %%a in %apps% do (
    call :open_app "%%a"
)