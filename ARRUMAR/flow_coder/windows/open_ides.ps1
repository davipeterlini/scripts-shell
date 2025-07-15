# PowerShell script to open different IDEs

# Import utility modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\utils\colors_message.ps1"

# Constants
$SCRIPT_VERSION = "1.0.0"

function Print-Usage {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) [vscode|ultimate|community] [path]"
    Write-Host "  vscode    - Open VSCode"
    Write-Host "  ultimate  - Open JetBrains Ultimate Edition"
    Write-Host "  community - Open JetBrains Community Edition"
    Write-Host "  path      - Optional path to open in the IDE"
}

function Open-VSCode {
    param([string]$path = "")
    
    if (Get-Command "code" -ErrorAction SilentlyContinue) {
        if ($path) {
            & code $path
        }
        else {
            & code
        }
    }
    else {
        Print-Error "VSCode not found. Please install it or check your PATH."
    }
}

function Open-JetBrains-Ultimate {
    param([string]$path = "")
    
    $ideExe = $null
    
    if (Test-Path "$env:PROGRAMFILES\JetBrains\IntelliJ IDEA\bin\idea64.exe") {
        $ideExe = "$env:PROGRAMFILES\JetBrains\IntelliJ IDEA\bin\idea64.exe"
    }
    elseif (Test-Path "${env:PROGRAMFILES(x86)}\JetBrains\IntelliJ IDEA\bin\idea.exe") {
        $ideExe = "${env:PROGRAMFILES(x86)}\JetBrains\IntelliJ IDEA\bin\idea.exe"
    }
    
    if ($ideExe) {
        if ($path) {
            Start-Process -FilePath $ideExe -ArgumentList $path
        }
        else {
            Start-Process -FilePath $ideExe
        }
    }
    else {
        Print-Error "JetBrains Ultimate not found. Please install it."
    }
}

function Open-JetBrains-Community {
    param([string]$path = "")
    
    $ideExe = $null
    
    if (Test-Path "$env:PROGRAMFILES\JetBrains\IntelliJ IDEA Community Edition\bin\idea64.exe") {
        $ideExe = "$env:PROGRAMFILES\JetBrains\IntelliJ IDEA Community Edition\bin\idea64.exe"
    }
    elseif (Test-Path "${env:PROGRAMFILES(x86)}\JetBrains\IntelliJ IDEA Community Edition\bin\idea.exe") {
        $ideExe = "${env:PROGRAMFILES(x86)}\JetBrains\IntelliJ IDEA Community Edition\bin\idea.exe"
    }
    
    if ($ideExe) {
        if ($path) {
            Start-Process -FilePath $ideExe -ArgumentList $path
        }
        else {
            Start-Process -FilePath $ideExe
        }
    }
    else {
        Print-Error "JetBrains Community Edition not found. Please install it."
    }
}

function Main {
    param(
        [Parameter(Position=0)]
        [string]$ide,
        
        [Parameter(Position=1)]
        [string]$path = ""
    )
    
    if (-not $ide) {
        Print-Usage
        return
    }
    
    switch ($ide.ToLower()) {
        "vscode" { Open-VSCode -path $path }
        "ultimate" { Open-JetBrains-Ultimate -path $path }
        "community" { Open-JetBrains-Community -path $path }
        default {
            Print-Error "Unknown IDE: $ide"
            Print-Info "Supported IDEs: vscode, ultimate, community"
        }
    }
}

# Execute main function with all arguments
Main @args