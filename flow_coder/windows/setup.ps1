# PowerShell script to set up Flow Coder environment

# Import utility modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\utils\colors_message.ps1"
. "$scriptPath\utils\generic_utils.ps1"
. "$scriptPath\utils\detect_os.ps1"

function Check-PowerShell-Version {
    $psVersion = $PSVersionTable.PSVersion
    
    Print-Info "PowerShell Version: $($psVersion.Major).$($psVersion.Minor).$($psVersion.Patch)"
    
    if ($psVersion.Major -lt 5) {
        Print-Error "PowerShell 5.0 or higher is required."
        return $false
    }
    
    return $true
}

function Check-ExecutionPolicy {
    $policy = Get-ExecutionPolicy
    
    Print-Info "Current PowerShell Execution Policy: $policy"
    
    if ($policy -eq "Restricted") {
        Print-Alert "PowerShell execution policy is set to Restricted."
        Print-Info "Attempting to set execution policy to RemoteSigned for current user..."
        
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            $newPolicy = Get-ExecutionPolicy
            Print-Success "Execution policy changed to: $newPolicy"
        }
        catch {
            Print-Error "Failed to change execution policy: $_"
            Print-Alert "You may need to run PowerShell as Administrator to change the execution policy."
            return $false
        }
    }
    
    return $true
}

function Main {
    Print-Header "Flow Coder Setup Script"
    
    # Detect OS
    $osInfo = Detect-OS
    
    # Check PowerShell version
    if (-not (Check-PowerShell-Version)) {
        Print-Error "PowerShell version check failed. Please upgrade PowerShell."
        return
    }
    
    # Check execution policy
    if (-not (Check-ExecutionPolicy)) {
        Print-Error "Execution policy check failed. Please set execution policy to RemoteSigned or less restrictive."
        return
    }
    
    # Setup options
    Print-Header "Setup Options"
    Print-Info "1. Install IDEs (VSCode, JetBrains)"
    Print-Info "2. Install Flow Coder"
    Print-Info "3. Test Flow Coder installation"
    Print-Info "4. All of the above"
    Print-Info "5. Exit"
    
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" {
            & "$scriptPath\install_ides.ps1"
        }
        "2" {
            & "$scriptPath\install_flow_coder.ps1"
        }
        "3" {
            & "$scriptPath\test_flow_coder.ps1"
        }
        "4" {
            & "$scriptPath\install_ides.ps1"
            & "$scriptPath\install_flow_coder.ps1"
            & "$scriptPath\test_flow_coder.ps1"
        }
        "5" {
            Print-Info "Exiting setup."
            return
        }
        default {
            Print-Error "Invalid choice. Exiting."
            return
        }
    }
    
    Print-Success "Setup completed."
}

# Execute main function
Main