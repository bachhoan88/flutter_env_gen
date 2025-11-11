# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2025-11-11

### Added
- Comprehensive unit tests for `EnvParser` class covering all parsing scenarios
- Comprehensive unit tests for `CodeGenerator` class covering all code generation features
- Enhanced test coverage for `EnvGen` and `EnvField` annotations
- Test cases for all field rename strategies (snakeToCamel, snakeToPascal, kebabToCamel, none)
- Test cases for sensitive keys handling
- Test cases for all data types (string, int, double, bool, list)
- Test cases for multiline values and quoted values
- Test coverage script for easy coverage reporting

### Fixed
- Added missing import statements in `code_generator.dart` (code_builder, dart_style)
- Added missing import statement in `env_parser.dart` (dart:io)
- Fixed operator precedence in `env_parser.dart` for better code quality

### Improved
- Achieved >90% code coverage across the codebase
- Enhanced test documentation and organization
- Better error handling test coverage

## [1.0.2] - Previous Release

### Features
- Type-safe environment configuration generation
- Support for multiple environment files
- Automatic type detection (string, int, double, bool, list)
- Field naming conventions (snake_case, camelCase, PascalCase, kebab-case)
- Sensitive keys obfuscation support
- Required keys validation
- Custom class name configuration

## [1.0.1] - Initial Release

### Added
- Initial release of flutter_env_gen
- Basic .env file parsing
- Code generation with build_runner
- Support for compile-time constants

