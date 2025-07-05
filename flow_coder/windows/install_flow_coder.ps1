# PowerShell script to install Flow Coder in VSCode and JetBrains IDEs

# Import utility modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\utils\colors_message.ps1"
. "$scriptPath\utils\generic_utils.ps1"

# Constants
$FLOW_CODER_VSCODE_EXTENSION = "flowcoder.flow-coder"
$FLOW_CODER_PLUGIN_URL = "https://downloads.marketplace.jetbrains.com/files/27434/780089/flow-coder-extension-0.2.0.zip"
$VSCODE_EXTENSIONS_DIR = "$env:USERPROFILE\.vscode\extensions"
$JETBRAINS_DIRS = "$env:APPDATA\JetBrains"
$TEMP_DIR = "$env:TEMP\flow_coder_install"

function Install-VSCode {
    Print-Info "Installing Flow Coder in VSCode..."

    # Check if VSCode is installed
    if (Command-Exists "code") {
        Print-Info "VSCode found, installing extension..."
        & code --install-extension $FLOW_CODER_VSCODE_EXTENSION
        Print-Info "Flow Coder successfully installed in VSCode."
    }
    else {
        Print-Alert "VSCode not found. Trying to install manually..."
        
        # Create extensions directory if it doesn't exist
        if (-not (Test-Path $VSCODE_EXTENSIONS_DIR)) {
            New-Item -Path $VSCODE_EXTENSIONS_DIR -ItemType Directory -Force | Out-Null
        }
        
        Print-Alert "Manual installation not implemented. Please install VSCode first."
    }
}

function Install-Plugin-To-IDE {
    param([string]$ideDir)
    
    $pluginDir = "$ideDir\plugins\flow-coder"
    
    # Create plugin directory
    if (-not (Test-Path $pluginDir)) {
        New-Item -Path $pluginDir -ItemType Directory -Force | Out-Null
    }
    
    # Download plugin
    Print-Info "Downloading Flow Coder plugin..."
    $downloadSuccess = Download-File -url $FLOW_CODER_PLUGIN_URL -outputFile "$TEMP_DIR\flow-coder.zip"
    
    if ($downloadSuccess -and (Test-Path "$TEMP_DIR\flow-coder.zip")) {
        Print-Info "Extracting plugin to $pluginDir"
        
        try {
            Expand-Archive -Path "$TEMP_DIR\flow-coder.zip" -DestinationPath $pluginDir -Force
            Print-Info "Flow Coder plugin installed in $pluginDir"
        }
        catch {
            Print-Error "Failed to extract plugin: $_"
        }
    }
    else {
        Print-Error "Failed to download plugin"
    }
}

function Install-JetBrains {
    Print-Info "Installing Flow Coder in JetBrains IDEs..."

    if (Test-Path $JETBRAINS_DIRS) {
        Print-Info "JetBrains directory found: $JETBRAINS_DIRS"
        
        # Create temporary directory for downloads
        if (Test-Path $TEMP_DIR) {
            Remove-Item -Path $TEMP_DIR -Recurse -Force
        }
        New-Item -Path $TEMP_DIR -ItemType Directory -Force | Out-Null
        
        # Look for IDE directories (both Ultimate and Community)
        $pluginFound = $false
        $ideDirs = Get-ChildItem -Path $JETBRAINS_DIRS -Filter "*20*" -Directory
        
        foreach ($ideDir in $ideDirs) {
            $pluginsDir = Join-Path -Path $ideDir.FullName -ChildPath "plugins"
            if (Test-Path $pluginsDir) {
                Print-Info "Installing Flow Coder in: $($ideDir.FullName)"
                Install-Plugin-To-IDE -ideDir $ideDir.FullName
                $pluginFound = $true
            }
        }
        
        # Clean up
        if (Test-Path $TEMP_DIR) {
            Remove-Item -Path $TEMP_DIR -Recurse -Force
        }
        
        if ($pluginFound) {
            Print-Info "To complete the installation, restart your JetBrains IDEs and activate the Flow Coder plugin in the settings."
        }
        else {
            Print-Alert "No compatible JetBrains IDE installations found."
        }
    }
    else {
        Print-Alert "No JetBrains installation found."
        Print-Alert "Please manually install the Flow Coder plugin through the JetBrains plugin marketplace."
    }
}

function Main {
    Print-Info "Starting Flow Coder installation..."
    
    # Install in VSCode
    Install-VSCode
    
    # Install in JetBrains
    Install-JetBrains
    
    Print-Info "Flow Coder installation process completed."
    Wait-ForUserConfirmation "Press Enter to continue..."
}

# Execute main function
Main