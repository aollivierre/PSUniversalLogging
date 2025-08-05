#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Example of using PSUniversalLogging in SYSTEM context
.DESCRIPTION
    This example demonstrates how the logging module handles SYSTEM context
    execution, which is common in RMM deployments
.EXAMPLE
    # Run as administrator
    .\03-SystemContextExample.ps1
    
    # Or run as SYSTEM using PsExec
    PsExec.exe -s -i powershell.exe -File ".\03-SystemContextExample.ps1"
#>

# Import the module
$ModulePath = Join-Path (Split-Path $PSScriptRoot -Parent) "PSUniversalLogging\PSUniversalLogging.psm1"
Import-Module $ModulePath -Force

# Initialize variables
$script:DisableFileLogging = $false
$script:LoggingMode = 'EnableDebug'

# Detect execution context
$context = Get-UserContext
Write-Host "Execution Context:" -ForegroundColor Cyan
Write-Host "  User Type: $($context.UserType)" -ForegroundColor Gray
Write-Host "  User Name: $($context.UserName)" -ForegroundColor Gray
Write-Host "  Computer: $($context.ComputerName)" -ForegroundColor Gray

# Set paths based on context
if ($context.UserType -eq "SYSTEM") {
    $logPath = "$env:ProgramData\PSUniversalLogging\SystemExample"
    Write-Host "  Running as SYSTEM - using ProgramData for logs" -ForegroundColor Yellow
} else {
    $logPath = "$env:TEMP\PSUniversalLogging\SystemExample"
    Write-Host "  Running as User - using TEMP for logs" -ForegroundColor Green
}

# Initialize logging
Initialize-Logging -BaseLogPath $logPath `
                  -JobName "SystemContextExample" `
                  -ParentScriptName "03-SystemContextExample.ps1"

# Log context information
Write-AppDeploymentLog -Message "Script started in $($context.UserType) context" -Level "INFO"
Write-AppDeploymentLog -Message "User: $($context.UserName)" -Level "DEBUG"
Write-AppDeploymentLog -Message "Computer: $($context.ComputerName)" -Level "DEBUG"

# Demonstrate logged-in user detection (useful in SYSTEM context)
if ($context.UserType -eq "SYSTEM") {
    Write-AppDeploymentLog -Message "Running as SYSTEM - attempting to detect logged-in user" -Level "INFO"
    
    # This would be handled internally by the module
    # Just demonstrating the capability
    $loggedInUser = $env:USERNAME
    Write-AppDeploymentLog -Message "Detected user context: $loggedInUser" -Level "INFO"
}

# Perform some operations
Write-AppDeploymentLog -Message "Checking system information" -Level "INFO"
$os = Get-CimInstance Win32_OperatingSystem
Write-AppDeploymentLog -Message "OS: $($os.Caption) Build $($os.BuildNumber)" -Level "INFO"

Write-AppDeploymentLog -Message "System context example completed" -Level "SUCCESS"

# Show log location
Write-Host "`nLog files created in: $logPath" -ForegroundColor Green