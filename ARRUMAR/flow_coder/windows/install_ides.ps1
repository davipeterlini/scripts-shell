# PowerShell script to install IDEs on Windows

# Import utility modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\utils\colors_message.ps1"
. "$scriptPath\utils\generic_utils.ps1"
. "$scriptPath\utils\detect_os.ps1"

# Constants
$VSCODE_URL = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
$JETBRAINS_ULTIMATE_URL = "https://download.jetbrains.com/idea/ideaIU-2023.1.4.exe"
$JETBRAINS_COMMUNITY_URL = "https://download.jetbrains.com/idea/ideaIC-2023.1.4.exe"
$TEMP_DIR = "$env:TEMP\ide_installers"

function Install-VSCode {
    Print-Header "Installing Visual Studio Code"
    
    if (Command-Exists "code") {
        Print-Success "Visual Studio Code is already installed."
        return
    }
    
    Print-Info "Downloading Visual Studio Code..."
    $installerPath = "$TEMP_DIR\vscode_installer.exe"
    
    if (Download-File -url $VSCODE_URL -outputFile $installerPath) {
        Print-Info "Installing Visual Studio Code..."
        Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -Wait
        
        if (Command-Exists "code") {
            Print-Success "Visual Studio Code installed successfully."
        }
        else {
            Print-Error "Failed to install Visual Studio Code."
        }
    }
}

function Install-JetBrains-Ultimate {
    Print-Header "Installing JetBrains IntelliJ IDEA Ultimate"
    
    if (Test-Path "$env:PROGRAMFILES\JetBrains\IntelliJ IDEA*") {
        Print-Success "JetBrains IntelliJ IDEA Ultimate is already installed."
        return
    }
    
    Print-Info "Downloading JetBrains IntelliJ IDEA Ultimate..."
    $installerPath = "$TEMP_DIR\intellij_ultimate_installer.exe"
    
    if (Download-File -url $JETBRAINS_ULTIMATE_URL -outputFile $installerPath) {
        Print-Info "Installing JetBrains IntelliJ IDEA Ultimate..."
        Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
        
        if (Test-Path "$env:PROGRAMFILES\JetBrains\IntelliJ IDEA*") {
            Print-Success "JetBrains IntelliJ IDEA Ultimate installed successfully."
        }
        else {
            Print-Error "Failed to install JetBrains IntelliJ IDEA Ultimate."
        }
    }
}

function Install-JetBrains-Community {
    Print-Header "Installing JetBrains IntelliJ IDEA Community Edition"
    
    if (Test-Path "$env:PROGRAMFILES\JetBrains\IntelliJ IDEA Community Edition*") {
        Print-Success "JetBrains IntelliJ IDEA Community Edition is already installed."
        return
    }
    
    Print-Info "Downloading JetBrains IntelliJ IDEA Community Edition..."
    $installerPath = "$TEMP_DIR\intellij_community_installer.exe"
    
    if (Download-File -url $JETBRAINS_COMMUNITY_URL -outputFile $installerPath) {
        Print-Info "Installing JetBrains IntelliJ IDEA Community Edition..."
        Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
        
        if (Test-Path "$env:PROGRAMFILES\JetBrains\IntelliJ IDEA Community Edition*") {
            Print-Success "JetBrains IntelliJ IDEA Community Edition installed successfully."
        }
        else {
            Print-Error "Failed to install JetBrains IntelliJ IDEA Community Edition."
        }
    }
}

function Main {
    Print-Header "IDE Installation Script for Windows"
    
    # Detect OS
    $osInfo = Detect-OS
    
    # Create temp directory
    if (-not (Test-Path $TEMP_DIR)) {
        New-Item -Path $TEMP_DIR -ItemType Directory -Force | Out-Null
    }
    
    # Ask user which IDEs to install
    Print-Info "Which IDEs would you like to install?"
    Print-Info "1. Visual Studio Code"
    Print-Info "2. JetBrains IntelliJ IDEA Ultimate"
    Print-Info "3. JetBrains IntelliJ IDEA Community Edition"
    Print-Info "4. All of the above"
    
    $choice = Read-Host "Enter your choice (1-4)"
    
    switch ($choice) {
        "1" { Install-VSCode }
        "2" { Install-JetBrains-Ultimate }
        "3" { Install-JetBrains-Community }
        "4" {
            Install-VSCode
            Install-JetBrains-Ultimate
            Install-JetBrains-Community
        }
        default { Print-Error "Invalid choice. Exiting." }
    }
    
    # Clean up
    if (Test-Path $TEMP_DIR) {
        Remove-Item -Path $TEMP_DIR -Recurse -Force
    }
    
    Print-Success "IDE installation completed."
}

# Execute main function
Main