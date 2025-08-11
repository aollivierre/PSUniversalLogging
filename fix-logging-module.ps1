# Script to uncomment Write-AppDeploymentLog function in PSUniversalLogging module
# The function was commented out but is still being called throughout the module

$modulePath = "C:\code\PSUniversalLogging\PSUniversalLogging\PSUniversalLogging.psm1"

# Read the module content
$content = Get-Content $modulePath -Raw

# Find and uncomment the Write-AppDeploymentLog function
# The function is commented from line 219 to 613
# We need to remove the <# at line 219 and #> at line 613

# Remove the comment block markers for Write-AppDeploymentLog
$content = $content -replace '# DEPRECATED: Functionality merged into Write-EnhancedLog\r?\n<#\s*\r?\nfunction Write-AppDeploymentLog', 'function Write-AppDeploymentLog'
$content = $content -replace '}\r?\n\s*#endregion Console Output\r?\n}\r?\n#>', "`}`n    #endregion Console Output`n}"

# Save the fixed module
$content | Set-Content $modulePath -Encoding UTF8

Write-Host "Successfully uncommented Write-AppDeploymentLog function" -ForegroundColor Green
Write-Host "The function is now available for use by all internal module functions" -ForegroundColor Cyan