/// Annotation for configuring environment generation
class EnvGen {
  /// Paths to environment files
  /// Example: ['.env.dev', '.env.staging', '.env.prod']
  final List<String> envFiles;

  /// Output path for generated file
  /// Default: 'lib/env/env.g.dart'
  final String? outputPath;

  /// Name of the generated class
  /// Default: 'Env'
  final String? className;

  /// Field naming convention
  final FieldRename fieldRename;

  /// Keys that should be obfuscated in the generated code
  final List<String> sensitiveKeys;

  /// Required keys that must exist in all env files
  final List<String> requiredKeys;

  /// Whether to generate a loader class for runtime loading
  final bool generateLoader;

  const EnvGen({
    this.envFiles = const ['.env'],
    this.outputPath,
    this.className,
    this.fieldRename = FieldRename.snakeToCamel,
    this.sensitiveKeys = const [],
    this.requiredKeys = const [],
    this.generateLoader = false,
  });
}

/// Field naming convention
enum FieldRename {
  /// Keep original naming
  none,

  /// Convert SNAKE_CASE to camelCase
  snakeToCamel,

  /// Convert SNAKE_CASE to PascalCase
  snakeToPascal,

  /// Convert kebab-case to camelCase
  kebabToCamel,
}

/// Annotation for individual field configuration
class EnvField {
  /// Custom name for the field
  final String? name;

  /// Default value if not found in env
  final dynamic defaultValue;

  /// Whether this field is required
  final bool required;

  /// Whether to obfuscate this field
  final bool obfuscate;

  const EnvField({
    this.name,
    this.defaultValue,
    this.required = false,
    this.obfuscate = false,
  });
}