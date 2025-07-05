# PowerShell script for colored messages

# Function to display information messages
function Print-Info {
    param([string]$message)
    Write-Host "`nℹ️  $message" -ForegroundColor Cyan
}

# Function to display success messages
function Print-Success {
    param([string]$message)
    Write-Host "✅ $message" -ForegroundColor Green
}

# Function to display alert messages
function Print-Alert {
    param([string]$message)
    Write-Host "`n⚠️  $message" -ForegroundColor Yellow
}

# Function to display error messages
function Print-Error {
    param([string]$message)
    Write-Host "❌ Error: $message" -ForegroundColor Red
}

# Function to display plain messages
function Print-Message {
    param([string]$message)
    Write-Host "$message" -ForegroundColor White
}

# Function to display formatted messages
function Print-Header {
    param([string]$message)
    Write-Host "`n==========================================================================" -ForegroundColor Yellow
    Write-Host "$message" -ForegroundColor Green
    Write-Host "==========================================================================" -ForegroundColor Yellow
}

function Print-HeaderInfo {
    param([string]$message)
    Write-Host "`n=======================================================" -ForegroundColor Cyan
    Write-Host "$message" -ForegroundColor Yellow
    Write-Host "=======================================================" -ForegroundColor Cyan
}

# Function to display yellow messages
function Print-Yellow {
    param([string]$message)
    Write-Host "$message" -ForegroundColor Yellow
}

# Function to display red messages
function Print-Red {
    param([string]$message)
    Write-Host "$message" -ForegroundColor Red
}

# Export functions
Export-ModuleMember -Function Print-Info, Print-Success, Print-Alert, Print-Error, Print-Message, Print-Header, Print-HeaderInfo, Print-Yellow, Print-Red