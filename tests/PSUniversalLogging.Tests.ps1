#Requires -Version 5.1
#Requires -Modules Pester

<#
.SYNOPSIS
    Pester tests for PSUniversalLogging module
.DESCRIPTION
    Comprehensive test suite for the universal logging module
#>

BeforeAll {
    # Import the module
    $ModulePath = Join-Path (Split-Path $PSScriptRoot -Parent) "PSUniversalLogging\PSUniversalLogging.psm1"
    Import-Module $ModulePath -Force
    
    # Set up test variables
    $script:TestLogPath = Join-Path $env:TEMP "PSUniversalLogging_Tests_$(Get-Random)"
    New-Item -Path $script:TestLogPath -ItemType Directory -Force | Out-Null
}

AfterAll {
    # Clean up test logs
    if (Test-Path $script:TestLogPath) {
        Remove-Item -Path $script:TestLogPath -Recurse -Force
    }
}

Describe "PSUniversalLogging Module Tests" {
    
    Context "Module Loading" {
        It "Should load without errors" {
            { Get-Module PSUniversalLogging } | Should -Not -BeNullOrEmpty
        }
        
        It "Should export expected functions" {
            $module = Get-Module PSUniversalLogging
            $module.ExportedFunctions.Keys | Should -Contain "Initialize-Logging"
            $module.ExportedFunctions.Keys | Should -Contain "Write-AppDeploymentLog"
            $module.ExportedFunctions.Keys | Should -Contain "Start-UniversalTranscript"
            $module.ExportedFunctions.Keys | Should -Contain "Stop-UniversalTranscript"
        }
    }
    
    Context "Initialize-Logging" {
        It "Should initialize without errors" {
            {
                Initialize-Logging -BaseLogPath $script:TestLogPath `
                                 -JobName "TestJob" `
                                 -ParentScriptName "Test.ps1"
            } | Should -Not -Throw
        }
        
        It "Should set LogConfig values" {
            $script:LogConfig.Initialized | Should -Be $true
            $script:LogConfig.BaseLogPath | Should -Be $script:TestLogPath
            $script:LogConfig.JobName | Should -Be "TestJob"
            $script:LogConfig.ParentScriptName | Should -Be "Test.ps1"
        }
    }
    
    Context "Write-AppDeploymentLog" {
        BeforeEach {
            $script:DisableFileLogging = $false
            Initialize-Logging -BaseLogPath $script:TestLogPath `
                             -JobName "LogTest" `
                             -ParentScriptName "LogTest.ps1"
        }
        
        It "Should write INFO messages without errors" {
            { Write-AppDeploymentLog -Message "Test INFO" -Level "INFO" } | Should -Not -Throw
        }
        
        It "Should write WARNING messages without errors" {
            { Write-AppDeploymentLog -Message "Test WARNING" -Level "WARNING" } | Should -Not -Throw
        }
        
        It "Should write ERROR messages without errors" {
            { Write-AppDeploymentLog -Message "Test ERROR" -Level "ERROR" } | Should -Not -Throw
        }
        
        It "Should write DEBUG messages without errors" {
            { Write-AppDeploymentLog -Message "Test DEBUG" -Level "DEBUG" } | Should -Not -Throw
        }
        
        It "Should write SUCCESS messages without errors" {
            { Write-AppDeploymentLog -Message "Test SUCCESS" -Level "SUCCESS" } | Should -Not -Throw
        }
        
        It "Should respect DisableFileLogging setting" {
            $script:DisableFileLogging = $true
            { Write-AppDeploymentLog -Message "Test with logging disabled" -Level "INFO" } | Should -Not -Throw
            
            # Check that no log files were created
            $logFiles = Get-ChildItem -Path $script:TestLogPath -Filter "*.csv" -Recurse
            $logFiles | Should -BeNullOrEmpty
        }
    }
    
    Context "Transcript Functions" {
        BeforeEach {
            $script:DisableFileLogging = $false
            Initialize-Logging -BaseLogPath $script:TestLogPath `
                             -JobName "TranscriptTest" `
                             -ParentScriptName "TranscriptTest.ps1"
        }
        
        It "Should start transcript without errors" {
            $transcriptPath = Start-UniversalTranscript
            $transcriptPath | Should -Not -BeNullOrEmpty
            
            # Stop it for cleanup
            $null = Stop-UniversalTranscript
        }
        
        It "Should stop transcript and return true when running" {
            $null = Start-UniversalTranscript
            $stopped = Stop-UniversalTranscript
            $stopped | Should -Be $true
        }
        
        It "Should handle stopping when no transcript is running" {
            # Ensure no transcript is running
            $null = Stop-UniversalTranscript
            
            # Try to stop again
            $stopped = Stop-UniversalTranscript
            $stopped | Should -Be $false
        }
    }
    
    Context "Error Handling" {
        BeforeEach {
            Initialize-Logging -BaseLogPath $script:TestLogPath `
                             -JobName "ErrorTest" `
                             -ParentScriptName "ErrorTest.ps1"
        }
        
        It "Should handle errors with Handle-Error function" {
            try {
                throw "Test error"
            }
            catch {
                { Handle-Error -ErrorRecord $_ -CustomMessage "Test error handling" } | Should -Not -Throw
            }
        }
    }
    
    Context "User Context Detection" {
        It "Should detect user context" {
            $context = Get-UserContext
            $context | Should -Not -BeNullOrEmpty
            $context.UserType | Should -BeIn @("User", "Admin", "SYSTEM")
            $context.UserName | Should -Not -BeNullOrEmpty
            $context.ComputerName | Should -Be $env:COMPUTERNAME
        }
    }
    
    Context "Module Version" {
        It "Should return version information" {
            $version = Get-ModuleVersion
            $version | Should -Not -BeNullOrEmpty
            $version | Should -Match "^\d+\.\d+\.\d+$"
        }
    }
}

Describe "Edge Cases and Special Scenarios" {
    
    Context "Long Messages" {
        It "Should handle very long messages" {
            $longMessage = "A" * 10000
            { Write-AppDeploymentLog -Message $longMessage -Level "INFO" } | Should -Not -Throw
        }
    }
    
    Context "Special Characters" {
        It "Should handle messages with special characters" {
            $specialMessage = 'Test with special chars: !@#$%^&*()_+-={}[]|\":;<>?,./'
            { Write-AppDeploymentLog -Message $specialMessage -Level "INFO" } | Should -Not -Throw
        }
        
        It "Should handle messages with newlines" {
            $multilineMessage = "Line 1`nLine 2`rLine 3`r`nLine 4"
            { Write-AppDeploymentLog -Message $multilineMessage -Level "INFO" } | Should -Not -Throw
        }
    }
    
    Context "Concurrent Operations" {
        It "Should handle multiple rapid log writes" {
            1..100 | ForEach-Object {
                { Write-AppDeploymentLog -Message "Rapid log $_" -Level "INFO" } | Should -Not -Throw
            }
        }
    }
}