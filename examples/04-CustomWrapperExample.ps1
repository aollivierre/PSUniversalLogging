#Requires -Version 5.1
<#
.SYNOPSIS
    Example of creating custom wrapper functions
.DESCRIPTION
    This example shows how to create application-specific logging wrappers
    around the PSUniversalLogging module functions
.EXAMPLE
    .\04-CustomWrapperExample.ps1
#>

# Import the module
$ModulePath = Join-Path (Split-Path $PSScriptRoot -Parent) "PSUniversalLogging\PSUniversalLogging.psm1"
Import-Module $ModulePath -Force

# Initialize variables
$script:DisableFileLogging = $false
$script:LoggingMode = 'EnableDebug'
$script:ApplicationName = "MyApplication"
$script:ApplicationVersion = "1.0.0"

# Initialize logging
Initialize-Logging -BaseLogPath "C:\Temp\PSUniversalLogging\Examples" `
                  -JobName "CustomWrapperExample" `
                  -ParentScriptName "04-CustomWrapperExample.ps1"

#region Custom Wrapper Functions

function Write-ApplicationLog {
    <#
    .SYNOPSIS
        Application-specific logging wrapper
    .PARAMETER Message
        The message to log
    .PARAMETER Level
        Log level (Info, Warning, Error, Debug, Success)
    .PARAMETER Component
        Application component generating the log
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet('Info', 'Warning', 'Error', 'Debug', 'Success')]
        [string]$Level = 'Info',
        
        [string]$Component = 'General'
    )
    
    # Format message with application context
    $formattedMessage = "[$script:ApplicationName v$script:ApplicationVersion] [$Component] $Message"
    
    # Convert level to uppercase for the base function
    Write-AppDeploymentLog -Message $formattedMessage -Level $Level.ToUpper()
}

function Write-PerformanceLog {
    <#
    .SYNOPSIS
        Log performance metrics
    #>
    param(
        [string]$Operation,
        [timespan]$Duration,
        [string]$Details = ""
    )
    
    $message = "Performance: $Operation completed in $($Duration.TotalMilliseconds)ms"
    if ($Details) {
        $message += " - $Details"
    }
    
    Write-ApplicationLog -Message $message -Level 'Debug' -Component 'Performance'
}

function Write-ErrorLog {
    <#
    .SYNOPSIS
        Enhanced error logging with stack trace
    #>
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        
        [string]$Component = 'General',
        [string]$AdditionalInfo = ""
    )
    
    $message = "ERROR: $($ErrorRecord.Exception.Message)"
    if ($AdditionalInfo) {
        $message += " | Additional Info: $AdditionalInfo"
    }
    
    Write-ApplicationLog -Message $message -Level 'Error' -Component $Component
    
    # Log stack trace as debug
    if ($ErrorRecord.ScriptStackTrace) {
        Write-ApplicationLog -Message "Stack Trace: $($ErrorRecord.ScriptStackTrace)" `
                           -Level 'Debug' `
                           -Component $Component
    }
}

function Start-LoggedOperation {
    <#
    .SYNOPSIS
        Start a logged operation with timing
    #>
    param(
        [string]$OperationName,
        [string]$Component = 'General'
    )
    
    Write-ApplicationLog -Message "Starting: $OperationName" -Level 'Info' -Component $Component
    
    # Return a custom object to track the operation
    [PSCustomObject]@{
        Name = $OperationName
        Component = $Component
        StartTime = Get-Date
    }
}

function Complete-LoggedOperation {
    <#
    .SYNOPSIS
        Complete a logged operation and log duration
    #>
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Operation,
        
        [switch]$Failed,
        [string]$Details = ""
    )
    
    $duration = (Get-Date) - $Operation.StartTime
    
    if ($Failed) {
        Write-ApplicationLog -Message "Failed: $($Operation.Name)" `
                           -Level 'Error' `
                           -Component $Operation.Component
    } else {
        Write-ApplicationLog -Message "Completed: $($Operation.Name)" `
                           -Level 'Success' `
                           -Component $Operation.Component
    }
    
    Write-PerformanceLog -Operation $Operation.Name -Duration $duration -Details $Details
}

#endregion

#region Demonstration

Write-Host "Custom Wrapper Example - Demonstrating application-specific logging" -ForegroundColor Cyan
Write-Host ""

# Basic logging with custom wrapper
Write-ApplicationLog -Message "Application started" -Component "Main"
Write-ApplicationLog -Message "Loading configuration" -Component "Config"
Write-ApplicationLog -Message "Configuration missing" -Level 'Warning' -Component "Config"

# Performance logging example
$operation = Start-LoggedOperation -OperationName "Database Connection" -Component "Database"
Start-Sleep -Milliseconds 1234  # Simulate work
Complete-LoggedOperation -Operation $operation -Details "Connected to SQL Server"

# Error handling example
try {
    $operation2 = Start-LoggedOperation -OperationName "File Processing" -Component "FileSystem"
    
    # Simulate an error
    throw "File not found: C:\temp\missing.txt"
}
catch {
    Complete-LoggedOperation -Operation $operation2 -Failed
    Write-ErrorLog -ErrorRecord $_ -Component "FileSystem" -AdditionalInfo "Processing batch job #1234"
}

# Debug logging
Write-ApplicationLog -Message "Debug information: Memory usage = $([Math]::Round((Get-Process -Id $PID).WorkingSet64 / 1MB, 2)) MB" `
                   -Level 'Debug' `
                   -Component "Performance"

Write-ApplicationLog -Message "Application completed successfully" -Level 'Success' -Component "Main"

#endregion

Write-Host "`nLog files created in: C:\Temp\PSUniversalLogging\Examples" -ForegroundColor Green
Write-Host "This example demonstrated custom wrapper functions for application-specific logging" -ForegroundColor Gray