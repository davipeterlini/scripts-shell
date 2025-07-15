# PowerShell script to grant permissions to scripts

function Print-Usage {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) [repo|scripts]"
    Write-Host "  repo    - Grant permissions to all PowerShell scripts in the entire repository"
    Write-Host "  scripts - Grant permissions to all PowerShell scripts in the scripts directory only (default)"
}

function Set-ScriptPermissions {
    param([string]$baseDir)
    
    $scripts = Get-ChildItem -Path $baseDir -Filter "*.ps1" -Recurse
    
    foreach ($script in $scripts) {
        Print-Message "Granting execute permission to: $($script.FullName)"
        Unblock-File -Path $script.FullName
    }
    
    Print-Message ""
    Print-Success "Permissions granted for all PowerShell scripts under the target directory: $baseDir"
    Print-Message ""
}

function Grant-Permissions {
    param([string]$targetDir = "repo")
    
    Print-Header "Granting permissions for all scripts..."
    
    $currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    
    if ($targetDir -eq "repo") {
        # Use the current directory as the base for the entire repository
        Print-Info "Granting execute permissions to PowerShell scripts in the entire repository: $currentDir"
        Print-Message ""
        Set-ScriptPermissions -baseDir $currentDir
    }
    elseif ($targetDir -eq "scripts") {
        # Use the scripts subdirectory
        $scriptsDir = Join-Path -Path $currentDir -ChildPath "scripts"
        if (Test-Path -Path $scriptsDir -PathType Container) {
            Print-Info "Granting execute permissions to PowerShell scripts in the scripts directory: $scriptsDir"
            Print-Message ""
            Set-ScriptPermissions -baseDir $scriptsDir
        }
        else {
            Print-Error "Scripts directory not found: $scriptsDir"
            return $false
        }
    }
    else {
        Print-Error "Invalid target directory value. Use 'repo' or 'scripts'."
        Print-Usage
        return $false
    }
    
    return $true
}

# Export functions
Export-ModuleMember -Function Grant-Permissions, Print-Usage, Set-ScriptPermissions