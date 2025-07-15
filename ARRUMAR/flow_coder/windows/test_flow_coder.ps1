# PowerShell script to test Flow Coder installation

# Import utility modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\utils\colors_message.ps1"
. "$scriptPath\utils\generic_utils.ps1"

# Constants
$FLOW_CODER_VSCODE_EXTENSION = "flowcoder.flow-coder"
$VSCODE_EXTENSIONS_DIR = "$env:USERPROFILE\.vscode\extensions"
$JETBRAINS_DIRS = "$env:APPDATA\JetBrains"

function Test-VSCode-Extension {
    Print-Header "Testing Flow Coder in VSCode"
    
    if (Command-Exists "code") {
        $extensions = & code --list-extensions
        
        if ($extensions -contains $FLOW_CODER_VSCODE_EXTENSION) {
            Print-Success "Flow Coder extension is installed in VSCode."
            return $true
        }
        else {
            Print-Error "Flow Coder extension is NOT installed in VSCode."
            return $false
        }
    }
    else {
        Print-Alert "VSCode is not installed or not in PATH."
        
        # Try to check manually
        $extensionPath = Get-ChildItem -Path $VSCODE_EXTENSIONS_DIR -Filter "flowcoder.flow-coder*" -Directory -ErrorAction SilentlyContinue
        
        if ($extensionPath) {
            Print-Success "Flow Coder extension found at: $($extensionPath.FullName)"
            return $true
        }
        else {
            Print-Error "Flow Coder extension not found in VSCode extensions directory."
            return $false
        }
    }
}

function Test-JetBrains-Plugin {
    Print-Header "Testing Flow Coder in JetBrains IDEs"
    
    if (Test-Path $JETBRAINS_DIRS) {
        $pluginFound = $false
        $ideDirs = Get-ChildItem -Path $JETBRAINS_DIRS -Filter "*20*" -Directory
        
        foreach ($ideDir in $ideDirs) {
            $pluginDir = Join-Path -Path $ideDir.FullName -ChildPath "plugins\flow-coder"
            
            if (Test-Path $pluginDir) {
                Print-Success "Flow Coder plugin found in: $($ideDir.Name)"
                $pluginFound = $true
            }
        }
        
        if (-not $pluginFound) {
            Print-Error "Flow Coder plugin not found in any JetBrains IDE."
            return $false
        }
        
        return $true
    }
    else {
        Print-Alert "No JetBrains installation found."
        return $false
    }
}

function Main {
    Print-Header "Flow Coder Installation Test"
    
    $vscodeResult = Test-VSCode-Extension
    $jetbrainsResult = Test-JetBrains-Plugin
    
    Print-Header "Test Results"
    
    if ($vscodeResult) {
        Print-Success "VSCode: Flow Coder is properly installed."
    }
    else {
        Print-Error "VSCode: Flow Coder is NOT properly installed."
    }
    
    if ($jetbrainsResult) {
        Print-Success "JetBrains: Flow Coder is properly installed."
    }
    else {
        Print-Error "JetBrains: Flow Coder is NOT properly installed."
    }
    
    if ($vscodeResult -and $jetbrainsResult) {
        Print-Success "All tests passed! Flow Coder is properly installed."
    }
    else {
        Print-Alert "Some tests failed. Flow Coder may not be properly installed."
    }
    
    Wait-ForUserConfirmation "Press Enter to continue..."
}

# Execute main function
Main