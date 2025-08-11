# Test script for enhanced log levels in Write-AppDeploymentLog

# Import the module
Import-Module .\PSUniversalLogging\PSUniversalLogging.psm1 -Force

# Initialize logging
Initialize-Logging -BaseLogPath "C:\code\PSUniversalLogging\TestLogs" -JobName "LevelTest" -ParentScriptName "TestEnhancedLevels"

# Enable debug mode to see console output
$global:EnableDebug = $true

Write-Host "`n=== Testing All Log Levels ===" -ForegroundColor Cyan

# Test original levels
Write-AppDeploymentLog -Message "Testing INFO level" -Level "INFO"
Write-AppDeploymentLog -Message "Testing WARNING level" -Level "WARNING"
Write-AppDeploymentLog -Message "Testing ERROR level" -Level "ERROR"
Write-AppDeploymentLog -Message "Testing DEBUG level" -Level "DEBUG"
Write-AppDeploymentLog -Message "Testing SUCCESS level" -Level "SUCCESS"

Write-Host "`n=== Testing New Enhanced Levels ===" -ForegroundColor Cyan

# Test new enhanced levels
Write-AppDeploymentLog -Message "Testing INFORMATION level (maps to INFO)" -Level "INFORMATION"
Write-AppDeploymentLog -Message "Testing CRITICAL level (maps to ERROR)" -Level "CRITICAL"
Write-AppDeploymentLog -Message "Testing NOTICE level (maps to INFO)" -Level "NOTICE"
Write-AppDeploymentLog -Message "Testing VERBOSE level (maps to DEBUG)" -Level "VERBOSE"

Write-Host "`n=== Testing Complete ===" -ForegroundColor Green
Write-Host "Check the log file at: $($script:SessionLogFilePath)" -ForegroundColor Yellow