#Requires -Version 5.1
<#
.SYNOPSIS
    Advanced example of using PSUniversalLogging module
.DESCRIPTION
    This example demonstrates advanced features including transcript logging,
    error handling, and conditional debug mode
.PARAMETER EnableDebug
    Enable debug logging mode
.EXAMPLE
    .\02-AdvancedExample.ps1
.EXAMPLE
    .\02-AdvancedExample.ps1 -EnableDebug
#>

param(
    [switch]$EnableDebug
)

# Import the module
$ModulePath = Join-Path (Split-Path $PSScriptRoot -Parent) "PSUniversalLogging\PSUniversalLogging.psm1"
Import-Module $ModulePath -Force

# Initialize variables
$script:DisableFileLogging = $false
$script:LoggingMode = if ($EnableDebug) { 'EnableDebug' } else { 'SilentMode' }
$script:LoggingEnabled = $true

# Initialize logging with all options
Initialize-Logging -BaseLogPath "C:\Temp\PSUniversalLogging\Examples" `
                  -JobName "AdvancedExample" `
                  -ParentScriptName "02-AdvancedExample.ps1" `
                  -CustomLogPath "C:\Temp\PSUniversalLogging\CustomLogs"

# Start transcript
Write-Host "Starting transcript logging..." -ForegroundColor Cyan
$transcriptPath = Start-UniversalTranscript

try {
    Write-AppDeploymentLog -Message "Advanced example started" -Level "INFO"
    Write-AppDeploymentLog -Message "Debug mode: $EnableDebug" -Level "DEBUG"
    
    # Simulate some work
    Write-AppDeploymentLog -Message "Performing task 1" -Level "INFO"
    Start-Sleep -Milliseconds 500
    
    Write-AppDeploymentLog -Message "Performing task 2" -Level "INFO"
    Start-Sleep -Milliseconds 500
    
    # Simulate a warning condition
    Write-AppDeploymentLog -Message "Low disk space detected" -Level "WARNING"
    
    # Simulate an error (but handle it)
    try {
        Write-AppDeploymentLog -Message "Attempting risky operation" -Level "INFO"
        throw "Simulated error for demonstration"
    }
    catch {
        Handle-Error -ErrorRecord $_ -CustomMessage "Handled the simulated error gracefully"
    }
    
    Write-AppDeploymentLog -Message "All tasks completed successfully" -Level "SUCCESS"
}
finally {
    # Always stop transcript
    Write-Host "Stopping transcript..." -ForegroundColor Cyan
    $stopped = Stop-UniversalTranscript
    
    if ($stopped) {
        Write-Host "Transcript saved to: $transcriptPath" -ForegroundColor Green
    }
}

# Show where logs were created
Write-Host "`nLog files created in:" -ForegroundColor Green
Write-Host "  - Base logs: C:\Temp\PSUniversalLogging\Examples" -ForegroundColor Gray
Write-Host "  - Custom logs: C:\Temp\PSUniversalLogging\CustomLogs" -ForegroundColor Gray
if ($transcriptPath) {
    Write-Host "  - Transcript: $transcriptPath" -ForegroundColor Gray
}