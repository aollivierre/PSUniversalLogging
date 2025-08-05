# Changelog

All notable changes to PSUniversalLogging will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial public release preparation
- Comprehensive documentation

## [3.0.0] - 2025-08-05

### Added
- Line number tracking with automatic detection from call stack
- Intelligent call stack analysis for accurate source detection
- SYSTEM context support with automatic path adjustment
- Network logging capabilities with fallback options
- Configurable logging modes (EnableDebug, SilentMode, Off)
- CSV logging with automatic rotation and organization
- PowerShell transcript support with error handling
- Comprehensive error handling with context preservation

### Changed
- Complete rewrite of core logging engine
- Improved performance with lazy initialization
- Enhanced wrapper function detection
- Better handling of edge cases in call stack analysis

### Fixed
- Line number detection in complex call scenarios
- SYSTEM context path resolution
- Transcript handling in restricted environments
- Memory leaks in long-running processes

## [2.0.0] - 2024-11-15

### Added
- Basic call stack analysis
- Multiple output format support
- Configuration persistence

### Changed
- Refactored module structure
- Improved error handling

### Deprecated
- Legacy logging functions

## [1.0.0] - 2024-09-01

### Added
- Initial release
- Basic logging functionality
- Console and file output
- Error handling

[Unreleased]: https://github.com/aollivierre/PSUniversalLogging/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/aollivierre/PSUniversalLogging/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/aollivierre/PSUniversalLogging/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/aollivierre/PSUniversalLogging/releases/tag/v1.0.0