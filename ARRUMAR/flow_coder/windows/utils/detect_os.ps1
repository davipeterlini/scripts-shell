# PowerShell script to detect OS information

function Detect-OS {
    $osInfo = @{}
    
    # Get OS information
    $os = Get-CimInstance Win32_OperatingSystem
    
    # Set OS name, version and codename
    $osInfo.Name = "Windows"
    $osInfo.Version = $os.Version
    $osInfo.Codename = $os.Caption
    
    # Print OS information
    Print-Success "Operating System Detected: $($osInfo.Name) $($osInfo.Version) $($osInfo.Codename)"
    
    # Return OS information
    return $osInfo
}

# Export functions
Export-ModuleMember -Function Detect-OS