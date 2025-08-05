#Requires -Version 5.1
<#
.SYNOPSIS
    Basic example of using PSUniversalLogging module
.DESCRIPTION
    This example demonstrates the simplest usage of the logging module
.EXAMPLE
    .\01-BasicExample.ps1
#>

# Import the module (adjust path as needed)
$ModulePath = Join-Path (Split-Path $PSScriptRoot -Parent) "PSUniversalLogging\PSUniversalLogging.psm1"
Import-Module $ModulePath -Force

# Initialize required variables
$script:DisableFileLogging = $false

# Initialize logging
Initialize-Logging -BaseLogPath "C:\Temp\PSUniversalLogging\Examples" `
                  -JobName "BasicExample" `
                  -ParentScriptName "01-BasicExample.ps1"

# Write some log messages
Write-AppDeploymentLog -Message "This is an informational message" -Level "INFO"
Write-AppDeploymentLog -Message "This is a warning message" -Level "WARNING"
Write-AppDeploymentLog -Message "This is an error message" -Level "ERROR"
Write-AppDeploymentLog -Message "This is a debug message" -Level "DEBUG"
Write-AppDeploymentLog -Message "This is a success message" -Level "SUCCESS"

Write-Host "`nLog files created in: C:\Temp\PSUniversalLogging\Examples" -ForegroundColor Green