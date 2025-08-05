# PSUniversalLogging Initialization Guide

This guide provides detailed instructions on how to properly initialize and use the PSUniversalLogging module in your PowerShell scripts.

## Table of Contents

1. [Required Variables](#required-variables)
2. [Basic Initialization](#basic-initialization)
3. [Advanced Initialization](#advanced-initialization)
4. [Usage Patterns](#usage-patterns)
5. [Best Practices](#best-practices)

## Required Variables

When using PSUniversalLogging, certain script-scoped variables need to be initialized:

### Essential Variables

```powershell
# Control whether file logging is enabled (default: false)
$script:DisableFileLogging = $false

# Set the logging configuration
$script:LogConfig = @{
    BaseLogPath = "C:\ProgramData\YourApp\Logs"
    JobName = "YourJobName"
    ParentScriptName = "YourScriptName"
    Initialized = $false
}
```

### Optional Variables

```powershell
# Control logging verbosity
$script:LoggingMode = 'EnableDebug'  # Options: 'EnableDebug', 'SilentMode', 'Off'

# Enable/disable logging globally
$script:LoggingEnabled = $true
```

## Basic Initialization

### Step 1: Import the Module

```powershell
# Option 1: From installed module
Import-Module PSUniversalLogging

# Option 2: From file path
$ModulePath = Join-Path $PSScriptRoot "PSUniversalLogging.psm1"
Import-Module $ModulePath -Force
```

### Step 2: Initialize Logging

```powershell
# Basic initialization
Initialize-Logging -BaseLogPath "C:\ProgramData\MyApp\Logs" `
                  -JobName "MyJob" `
                  -ParentScriptName "MyScript.ps1"
```

### Step 3: Start Using

```powershell
# Write logs
Write-AppDeploymentLog -Message "Script started" -Level "INFO"
Write-AppDeploymentLog -Message "Processing data" -Level "DEBUG"
```

## Advanced Initialization

### With All Options

```powershell
# Set up variables
$script:DisableFileLogging = $false
$script:LoggingMode = if ($DebugMode) { 'EnableDebug' } else { 'SilentMode' }

# Initialize with all options
Initialize-Logging -BaseLogPath "C:\ProgramData\MyApp\Logs" `
                  -JobName "AdvancedJob" `
                  -ParentScriptName "AdvancedScript.ps1" `
                  -CustomLogPath "C:\CustomLogs" `
                  -NetworkLogPath "\\server\share\logs"

# Start transcript
$transcriptPath = Start-UniversalTranscript -LogDirectory "C:\ProgramData\MyApp\Logs"

try {
    # Your script logic here
    Write-AppDeploymentLog -Message "Performing advanced operations" -Level "INFO"
}
finally {
    # Always stop transcript
    $null = Stop-UniversalTranscript
}
```

### SYSTEM Context Initialization

```powershell
# Detect context and adjust paths
$userContext = Get-UserContext
if ($userContext.UserType -eq "SYSTEM") {
    $basePath = "$env:ProgramData\MyApp\Logs"
} else {
    $basePath = "$env:TEMP\MyApp\Logs"
}

# Initialize with context-aware path
Initialize-Logging -BaseLogPath $basePath `
                  -JobName "ContextAwareJob" `
                  -ParentScriptName "ContextAware.ps1"
```

## Usage Patterns

### Pattern 1: RMM Script with Embedded Logging

```powershell
param(
    [switch]$EnableDebug
)

#region Embedded Logging Module
# [Paste entire PSUniversalLogging.psm1 content here]
#endregion

# Initialize variables
$script:DisableFileLogging = $false
$script:LoggingMode = if ($EnableDebug) { 'EnableDebug' } else { 'SilentMode' }

# Initialize logging
Initialize-Logging -BaseLogPath "C:\ProgramData\RMMScript\Logs" `
                  -JobName "RMMJob" `
                  -ParentScriptName "RMMScript.ps1"

# Script logic
Write-AppDeploymentLog -Message "RMM script started" -Level "INFO"
```

### Pattern 2: Development Script with Module Import

```powershell
#Requires -Version 5.1

# Import module
Import-Module PSUniversalLogging -Force

# Initialize based on environment
$isDevelopment = $env:COMPUTERNAME -match "DEV"
$script:LoggingMode = if ($isDevelopment) { 'EnableDebug' } else { 'SilentMode' }

Initialize-Logging -BaseLogPath "C:\Logs\DevScript" `
                  -JobName "Development" `
                  -ParentScriptName $MyInvocation.MyCommand.Name
```

### Pattern 3: Script with Custom Wrapper Functions

```powershell
# Import and initialize
Import-Module PSUniversalLogging
Initialize-Logging -BaseLogPath "C:\Logs" -JobName "CustomJob"

# Create application-specific wrappers
function Write-ApplicationLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    Write-AppDeploymentLog -Message "[APP] $Message" -Level $Level.ToUpper()
}

function Write-DebugLog {
    param([string]$Message)
    
    if ($script:LoggingMode -eq 'EnableDebug') {
        Write-AppDeploymentLog -Message "[DEBUG] $Message" -Level "DEBUG"
    }
}

# Use custom wrappers
Write-ApplicationLog -Message "Application initialized"
Write-DebugLog -Message "Debug information"
```

## Best Practices

### 1. Always Initialize Variables

```powershell
# At the top of your script
$script:DisableFileLogging = $false
$script:LoggingEnabled = $true
$script:LoggingMode = 'SilentMode'
```

### 2. Use Try-Finally for Cleanup

```powershell
$transcriptPath = Start-UniversalTranscript

try {
    # Your script logic
    Write-AppDeploymentLog -Message "Processing" -Level "INFO"
}
catch {
    Handle-Error -ErrorRecord $_
    throw
}
finally {
    $null = Stop-UniversalTranscript
}
```

### 3. Create Script-Specific Wrappers

```powershell
function Write-ScriptLog {
    param(
        [string]$Message,
        [string]$Level = 'INFO'
    )
    
    # Add script-specific prefix
    $prefixedMessage = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-AppDeploymentLog -Message $prefixedMessage -Level $Level
}
```

### 4. Handle Different Contexts

```powershell
# Detect and handle different execution contexts
$context = Get-UserContext
$logPath = switch ($context.UserType) {
    "SYSTEM" { "$env:ProgramData\AppLogs" }
    "Admin"  { "$env:ProgramData\AppLogs" }
    default  { "$env:LOCALAPPDATA\AppLogs" }
}

Initialize-Logging -BaseLogPath $logPath -JobName "ContextAware"
```

### 5. Conditional Debug Logging

```powershell
param(
    [switch]$Debug,
    [switch]$Verbose
)

# Set logging mode based on parameters
$script:LoggingMode = if ($Debug) { 
    'EnableDebug' 
} elseif ($Verbose) { 
    'SilentMode' 
} else { 
    'Off' 
}
```

## Common Pitfalls to Avoid

1. **Not initializing required variables**
   ```powershell
   # Wrong - will cause errors
   Import-Module PSUniversalLogging
   Write-AppDeploymentLog -Message "Test"  # Error: variables not initialized
   
   # Correct
   $script:DisableFileLogging = $false
   Initialize-Logging -BaseLogPath "C:\Logs" -JobName "Test"
   Write-AppDeploymentLog -Message "Test"
   ```

2. **Using relative paths in SYSTEM context**
   ```powershell
   # Wrong - may fail in SYSTEM context
   Initialize-Logging -BaseLogPath ".\Logs"
   
   # Correct
   Initialize-Logging -BaseLogPath "$env:ProgramData\AppLogs"
   ```

3. **Not handling transcript errors**
   ```powershell
   # Wrong - may leave transcript running
   Start-UniversalTranscript
   # Script logic...
   
   # Correct
   $transcript = Start-UniversalTranscript
   try {
       # Script logic...
   }
   finally {
       $null = Stop-UniversalTranscript
   }
   ```

## Summary

Proper initialization of PSUniversalLogging involves:

1. Setting required script variables
2. Importing the module
3. Calling Initialize-Logging with appropriate parameters
4. Using the logging functions throughout your script
5. Cleaning up resources (especially transcripts) when done

Following these patterns ensures reliable, consistent logging across all your PowerShell scripts.