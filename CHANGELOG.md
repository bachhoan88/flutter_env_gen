# Changelog

## 1.0.0 - 2024-11-11

### Initial Release

- **Type-safe code generation** from `.env` files
- **Automatic type detection** for String, int, double, bool, and List types
- **Multiple environment support** (dev, staging, production)
- **Compile-time constants** for better performance
- **Sensitive data obfuscation** for keys containing SECRET, KEY, TOKEN, PASSWORD
- **Customizable field naming** with snake_case to camelCase conversion
- **Required keys validation** at build time
- **Build_runner integration** for seamless code generation
- **Full IDE support** with autocomplete and type checking
- **No runtime parsing** - all values are compile-time constants
- **Secure by design** - .env files are not included in final APK/IPA

### Features

- Generate strongly-typed Dart classes from environment files
- Support for `String.fromEnvironment`, `int.fromEnvironment`, `bool.fromEnvironment`
- List parsing from comma-separated values
- Custom output path configuration
- Configurable class name and field renaming
- Build-time validation of required keys
- Example project with complete usage demonstration

### Documentation

- Comprehensive README with usage examples
- Comparison with flutter_dotenv
- Migration guide from runtime to compile-time configuration
- Complete API documentation