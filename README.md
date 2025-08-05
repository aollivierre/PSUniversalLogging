# PSUniversalLogging

A universal, reusable PowerShell logging module with advanced features including line number tracking, call stack analysis, and SYSTEM context support.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-3.0.0-orange.svg)

## 🚀 Features

- **Universal Design**: Works with any PowerShell project without modification
- **Line Number Tracking**: Automatic detection of source line numbers
- **Call Stack Analysis**: Intelligent detection of calling functions
- **SYSTEM Context Support**: Full functionality when running as SYSTEM
- **Multiple Output Formats**: Console, CSV, and transcript logging
- **Configurable Verbosity**: Silent, normal, and debug modes
- **Error Handling**: Comprehensive error capture and reporting
- **Network Path Support**: Optional network logging capabilities
- **Performance Optimized**: Minimal overhead with lazy initialization

## 📦 Installation

### Install from PowerShell Gallery

```powershell
Install-Module -Name PSUniversalLogging -Repository PSGallery -Scope CurrentUser
```

### Install from GitHub

```powershell
# Clone the repository
git clone https://github.com/aollivierre/PSUniversalLogging.git

# Import the module
Import-Module .\PSUniversalLogging\PSUniversalLogging\PSUniversalLogging.psd1
```

## 🎯 Quick Start

### Basic Usage

```powershell
# Import the module
Import-Module PSUniversalLogging

# Initialize logging with default settings
Initialize-Logging -BaseLogPath "C:\Logs\MyApp" -JobName "MyJob"

# Write log messages
Write-AppDeploymentLog -Message "Application started" -Level "INFO"
Write-AppDeploymentLog -Message "Processing data" -Level "DEBUG"
Write-AppDeploymentLog -Message "Warning condition detected" -Level "WARNING"
Write-AppDeploymentLog -Message "Error occurred" -Level "ERROR"
```

### Advanced Usage with Custom Wrapper

```powershell
# Create a custom wrapper function for your application
function Write-MyAppLog {
    param(
        [string]$Message,
        [string]$Level = 'INFO'
    )
    
    Write-AppDeploymentLog -Message $Message -Level $Level -Mode 'EnableDebug'
}

# Use your wrapper
Write-MyAppLog -Message "Custom logging initialized"
```

## 🔧 Initialization Requirements

When using this module in your scripts, you need to:

1. **Initialize Script Variables** (if using advanced features):
```powershell
# Optional: Control file logging
$script:DisableFileLogging = $false

# Optional: Set logging mode
$script:LoggingMode = 'EnableDebug'  # or 'SilentMode' or 'Off'
```

2. **Initialize the Logging System**:
```powershell
# Basic initialization
Initialize-Logging -BaseLogPath "C:\ProgramData\YourApp\Logs" `
                  -JobName "YourJobName" `
                  -ParentScriptName "YourScriptName"

# Advanced initialization with network logging
Initialize-Logging -BaseLogPath "C:\ProgramData\YourApp\Logs" `
                  -JobName "YourJobName" `
                  -ParentScriptName "YourScriptName" `
                  -NetworkLogPath "\\server\share\logs"
```

## 📚 API Reference

### Core Functions

#### Initialize-Logging
Initializes the logging system with configuration parameters.

```powershell
Initialize-Logging [-BaseLogPath] <string> 
                  [-JobName] <string> 
                  [-ParentScriptName] <string> 
                  [[-CustomLogPath] <string>] 
                  [[-NetworkLogPath] <string>]
```

#### Write-AppDeploymentLog
Writes a log message with specified level and mode.

```powershell
Write-AppDeploymentLog [-Message] <string> 
                      [[-Level] <string>] 
                      [[-Mode] <string>]
```

**Parameters:**
- `Message`: The log message to write
- `Level`: INFO, WARNING, ERROR, DEBUG, SUCCESS
- `Mode`: EnableDebug, SilentMode, Off

### Utility Functions

- `Start-UniversalTranscript`: Starts PowerShell transcript logging
- `Stop-UniversalTranscript`: Stops PowerShell transcript logging
- `Handle-Error`: Comprehensive error handling with context
- `Get-CallingScriptName`: Gets the name of the calling script
- `Get-UserContext`: Determines current user context (SYSTEM vs User)

## 🎨 Usage Patterns

### Pattern 1: Module Import (Development)

```powershell
# Import the module
$LoggingModulePath = Join-Path $PSScriptRoot "PSUniversalLogging.psm1"
Import-Module $LoggingModulePath -Force

# Initialize
Initialize-Logging -BaseLogPath "C:\Logs" -JobName "DevJob"

# Use throughout your script
Write-AppDeploymentLog -Message "Development logging active"
```

### Pattern 2: Embedded Logging (Production)

For production deployments where you need a single file:

```powershell
# Embed the entire module content at the top of your script
#region Embedded Logging Module
# [Paste PSUniversalLogging.psm1 content here]
#endregion

# Initialize and use as normal
Initialize-Logging -BaseLogPath "C:\Logs" -JobName "ProdJob"
```

### Pattern 3: Conditional Logging

```powershell
# Enable debug logging based on parameter
param([switch]$EnableDebug)

$script:LoggingMode = if ($EnableDebug) { 'EnableDebug' } else { 'SilentMode' }

Initialize-Logging -BaseLogPath "C:\Logs" -JobName "ConditionalJob"
```

## 🏗️ Architecture

### Module Structure
```
PSUniversalLogging/
├── PSUniversalLogging.psd1    # Module manifest
├── PSUniversalLogging.psm1    # Main module file
├── docs/                       # Documentation
├── examples/                   # Example scripts
└── tests/                      # Pester tests
```

### Key Components

1. **Logging Configuration** (`$script:LogConfig`)
   - Stores base paths, job names, and initialization state
   - Provides centralized configuration management

2. **Context Detection**
   - Automatically detects SYSTEM vs User context
   - Adjusts paths and permissions accordingly

3. **Output Handlers**
   - Console output with color coding
   - CSV file logging with rotation
   - PowerShell transcript support

## 🔍 Troubleshooting

### Common Issues

1. **Module Not Loading**
   ```powershell
   # Check execution policy
   Get-ExecutionPolicy
   
   # Set if needed
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Permission Errors in SYSTEM Context**
   ```powershell
   # Ensure proper paths for SYSTEM context
   Initialize-Logging -BaseLogPath "$env:ProgramData\YourApp\Logs"
   ```

3. **Line Numbers Not Showing**
   - Ensure you're not using compiled scripts
   - Check that call stack is accessible

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Setup

```powershell
# Clone the repo
git clone https://github.com/aollivierre/PSUniversalLogging.git
cd PSUniversalLogging

# Install development dependencies
Install-Module Pester -Force -SkipPublisherCheck
Install-Module PSScriptAnalyzer -Force

# Run tests
Invoke-Pester ./tests

# Run linter
Invoke-ScriptAnalyzer -Path . -Recurse
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- PowerShell community for best practices and patterns
- Contributors who provided feedback and testing
- Enterprise IT professionals who inspired the requirements

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/aollivierre/PSUniversalLogging/issues)
- **Discussions**: [GitHub Discussions](https://github.com/aollivierre/PSUniversalLogging/discussions)
- **Wiki**: [Documentation Wiki](https://github.com/aollivierre/PSUniversalLogging/wiki)

## 🗺️ Roadmap

- [ ] PowerShell 7+ optimizations
- [ ] Structured logging support (JSON)
- [ ] Log shipping integrations
- [ ] Performance profiling capabilities
- [ ] Async logging options

---

Made with ❤️ by the PowerShell community
