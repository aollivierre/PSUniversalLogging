# Simple test for enhanced log levels

# Import the module
Import-Module .\PSUniversalLogging\PSUniversalLogging.psm1 -Force

# Initialize logging
Initialize-Logging -BaseLogPath "C:\code\PSUniversalLogging\TestLogs2" -JobName "SimpleTest" -ParentScriptName "SimpleTest"

# Test with Mode parameter to ensure logging happens
Write-AppDeploymentLog -Message "Testing INFO level" -Level "INFO" -Mode "EnableDebug"
Write-AppDeploymentLog -Message "Testing CRITICAL level (maps to ERROR)" -Level "CRITICAL" -Mode "EnableDebug"
Write-AppDeploymentLog -Message "Testing VERBOSE level (maps to DEBUG)" -Level "VERBOSE" -Mode "EnableDebug"

Write-Host "`nTest complete - checking log file..." -ForegroundColor Green

# Find and display the log file
$logFile = Get-ChildItem "C:\code\PSUniversalLogging\TestLogs2" -Recurse -Filter "*.log" | Select-Object -First 1
if ($logFile) {
    Write-Host "`nLog file: $($logFile.FullName)" -ForegroundColor Yellow
    Write-Host "Contents:" -ForegroundColor Cyan
    Get-Content $logFile.FullName
}