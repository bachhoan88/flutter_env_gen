# Flutter Env Gen

[![pub package](https://img.shields.io/pub/v/flutter_env_gen.svg)](https://pub.dev/packages/flutter_env_gen)
[![CI/CD](https://github.com/bachhoan88/flutter_env_gen/actions/workflows/publish.yml/badge.svg)](https://github.com/bachhoan88/flutter_env_gen/actions/workflows/publish.yml)
[![codecov](https://codecov.io/gh/bachhoan88/flutter_env_gen/branch/main/graph/badge.svg)](https://codecov.io/gh/bachhoan88/flutter_env_gen)

A type-safe environment configuration generator for Flutter. Generate strongly-typed Dart code from `.env` files.

## Features

- **Type-safe** - Automatically detects types (String, int, double, bool, List)
- **Compile-time constants** - Better performance than runtime parsing
- **Multiple environments** - Support for dev, staging, production configs
- **Sensitive data protection** - Obfuscate secrets in generated code
- **Customizable** - Configure field naming, validation, and more
- **IDE support** - Full autocomplete and type checking

## Comparison with flutter_dotenv

| Feature | flutter_dotenv | flutter_env_gen |
|---------|---------------|-----------------|
| **Loading** | Runtime | Compile-time |
| **Type Safety** | String only | Auto-detect types |
| **Performance** | Parse at runtime | Const values |
| **Code Completion** | No | Full IDE support |
| **Validation** | Runtime errors | Build-time errors |
| **File in APK/IPA** | Yes (security risk) | No (compiled) |

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner: ^2.4.8
  flutter_env_gen: ^1.0.0
```

## Quick Start

### 1. Create your `.env` files

`.env.dev`:
```bash
API_BASE_URL=https://dev-api.example.com
ENABLE_LOGS=true
CACHE_TIMEOUT=3600
MAX_RETRY_ATTEMPTS=3
SUPPORTED_LOCALES=en,vi,zh
```

`.env.production`:
```bash
API_BASE_URL=https://api.example.com
ENABLE_LOGS=false
CACHE_TIMEOUT=86400
MAX_RETRY_ATTEMPTS=3
SUPPORTED_LOCALES=en,vi,zh,ja,ko,fr,de
```

### 2. Configure (Optional)

Create `build.yaml` in your project root:

```yaml
targets:
  $default:
    builders:
      flutter_env_gen:env_generator:
        options:
          env_files:
            - ".env.dev"
            - ".env.staging"
            - ".env.production"

          output_path: "lib/config/env.g.dart"
          class_name: "AppConfig"
          field_rename: snake_to_camel

          sensitive_keys:
            - "KEY"
            - "SECRET"
            - "TOKEN"

          required_keys:
            - "API_BASE_URL"
```

### 3. Generate code

```bash
# Generate once
dart run build_runner build

# Watch for changes
dart run build_runner watch -d

# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### 4. Use in your code

```dart
import 'config/env.g.dart';

void main() {
  // Access type-safe config
  print(AppConfig.apiBaseUrl);      // String
  print(AppConfig.enableLogs);      // bool
  print(AppConfig.cacheTimeout);    // int
  print(AppConfig.supportedLocales); // List<String>

  // Get current environment
  print(AppConfig.currentEnvironment); // 'dev', 'staging', or 'production'

  runApp(MyApp());
}
```

## Configuration Options

### Field Naming

Control how environment variable names are transformed:

| Option | Example Input | Example Output |
|--------|--------------|----------------|
| `none` | `API_BASE_URL` | `API_BASE_URL` |
| `snake_to_camel` | `API_BASE_URL` | `apiBaseUrl` |
| `snake_to_pascal` | `API_BASE_URL` | `ApiBaseUrl` |
| `kebab_to_camel` | `api-base-url` | `apiBaseUrl` |

### Sensitive Keys

Keys containing these strings will be obfuscated in the generated code:

```yaml
sensitive_keys:
  - "KEY"
  - "SECRET"
  - "TOKEN"
  - "PASSWORD"
```

### Required Keys

Build will fail if these keys are missing from your `.env` files:

```yaml
required_keys:
  - "API_BASE_URL"
  - "APP_NAME"
```

## Type Detection

The generator automatically detects types based on values:

```bash
# String
APP_NAME=MyApp

# Boolean (true/false, yes/no, 1/0)
ENABLE_LOGS=true

# Integer
CACHE_TIMEOUT=3600

# Double
APP_VERSION=1.0.5

# List (comma-separated)
SUPPORTED_LOCALES=en,vi,zh
```

## Multi-Environment Setup

### Using with Flutter flavors

```bash
# Development
flutter run --flavor dev --dart-define=ENVIRONMENT=dev

# Staging
flutter run --flavor staging --dart-define=ENVIRONMENT=staging

# Production
flutter run --flavor prod --dart-define=ENVIRONMENT=production
```

### Generated code uses compile-time environment

```dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev-api.example.com',
  );

  static const bool enableLogs = bool.fromEnvironment(
    'ENABLE_LOGS',
    defaultValue: true,
  );

  static String get currentEnvironment =>
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
}
```

## Advanced Usage

### Using Annotations

```dart
import 'package:flutter_env_gen/flutter_env_gen.dart';

@EnvGen(
  envFiles: ['.env.dev', '.env.prod'],
  className: 'Config',
  fieldRename: FieldRename.snakeToCamel,
  sensitiveKeys: ['API_KEY', 'SECRET'],
  requiredKeys: ['API_URL'],
)
class EnvConfig {}
```

### Custom Output Path

```yaml
# build.yaml
targets:
  $default:
    builders:
      flutter_env_gen:env_generator:
        options:
          output_path: "lib/core/config/environment.g.dart"
```

### Validation

The generator validates:
- Required keys exist in all env files
- Type consistency across environments
- File format and syntax

## Troubleshooting

### Generated file not updating

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Can't find .env files

Ensure your `.env` files are in the project root (same level as `pubspec.yaml`).

### Type conflicts

If the same key has different types across env files, it defaults to `String`.

## Best Practices

1. **Never commit sensitive .env files** - Add to `.gitignore`
2. **Use different files for environments** - `.env.dev`, `.env.staging`, `.env.prod`
3. **Keep production secrets secure** - Use CI/CD secret management
4. **Validate required keys** - Catch missing config at build time
5. **Use descriptive key names** - `API_BASE_URL` instead of `URL`

## Example Project

See the [example](example/) directory for a complete Flutter application demonstrating:
- Multiple environment files
- Custom configuration
- Type-safe access
- Sensitive data handling

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Migration from flutter_dotenv

If you're currently using `flutter_dotenv`, here's how to migrate:

### Before (flutter_dotenv)
```dart
// main.dart
await dotenv.load(fileName: ".env");
String apiUrl = dotenv.env['API_URL'] ?? '';
bool enableAds = dotenv.env['ENABLE_ADS'] == 'true';
```

### After (flutter_env_gen)
```dart
// main.dart
import 'config/env.g.dart';

String apiUrl = AppConfig.apiBaseUrl;  // Strongly typed!
bool enableAds = AppConfig.enableAds;   // Already a boolean!
```

## Platform Support

This package generates pure Dart code and works with:
- Flutter (iOS, Android, Web, Desktop)
- Dart (Server, CLI applications)

## Performance Comparison

| Metric | flutter_dotenv | flutter_env_gen |
|--------|---------------|-----------------|
| Startup time | ~50-100ms (parsing) | 0ms (compile-time) |
| Memory usage | Higher (stores all values) | Lower (const values) |
| Type safety | Manual parsing | Automatic |
| Error detection | Runtime | Build-time |

## Security Best Practices

1. **Never commit sensitive .env files** to version control
2. **Use .gitignore** to exclude .env files
3. **Store production secrets** in CI/CD secret management
4. **Use different values** for each environment
5. **Enable obfuscation** for sensitive keys

## Author

Created by Bach Ngoc Hoai

## Support

If you find this package useful, please give it a star on [GitHub](https://github.com/bachhoan88/flutter_env_gen)!