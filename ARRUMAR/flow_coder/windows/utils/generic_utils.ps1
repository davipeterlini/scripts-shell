# PowerShell script with generic utility functions

# Check if a command exists
function Command-Exists {
    param([string]$command)
    
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Clean up temporary files
function Cleanup-TempFiles {
    param([string]$tempDir)
    
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
}

# Wait for user confirmation
function Wait-ForUserConfirmation {
    param([string]$message)
    
    Write-Host $message
    Read-Host
}

# Download a file
function Download-File {
    param(
        [string]$url,
        [string]$outputFile
    )
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $outputFile)
        return $true
    }
    catch {
        Print-Error "Failed to download file: $_"
        return $false
    }
}

# Confirm an action
function Confirm-Action {
    param([string]$prompt)
    
    $choice = Read-Host "$prompt (y/n)"
    return $choice -match '^[Yy]'
}

# Export functions
Export-ModuleMember -Function Command-Exists, Cleanup-TempFiles, Wait-ForUserConfirmation, Download-File, Confirm-Action