import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;

import '../annotations/env_gen.dart';
import 'code_generator.dart';
import 'env_parser.dart';

/// Builder for generating environment configuration
class EnvGeneratorBuilder implements Builder {
  final BuilderOptions options;

  EnvGeneratorBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions => {
        'pubspec.yaml': ['lib/config/env.g.dart'],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      // Get configuration
      final config = await _getConfiguration(buildStep);

      // Find and parse all env files
      final entries = await _parseEnvFiles(config);

      // Validate required keys
      _validateRequiredKeys(entries, config);

      // Generate code
      final generator = CodeGenerator(
        entries: entries,
        config: config,
      );
      final code = generator.generate();

      // Write output - use the configured output path
      final outputPath = config.outputPath ?? 'lib/config/env.g.dart';
      final outputId = AssetId(buildStep.inputId.package, outputPath);

      await buildStep.writeAsString(outputId, code);

      log.info('Generated $outputPath with ${entries.length} environment variables');
    } catch (e, stack) {
      log.severe('Failed to generate environment configuration', e, stack);
      rethrow;
    }
  }

  /// Get configuration from build.yaml or defaults
  Future<EnvGen> _getConfiguration(BuildStep buildStep) async {
    final configMap = options.config;

    // Parse env files configuration
    final envFiles = _parseEnvFilesList(configMap['env_files']);

    // Parse other options
    return EnvGen(
      envFiles: envFiles,
      outputPath: configMap['output_path'] as String?,
      className: configMap['class_name'] as String?,
      fieldRename: _parseFieldRename(configMap['field_rename'] as String?),
      sensitiveKeys: List<String>.from(configMap['sensitive_keys'] ?? []),
      requiredKeys: List<String>.from(configMap['required_keys'] ?? []),
      generateLoader: configMap['generate_loader'] as bool? ?? false,
    );
  }

  /// Parse env files list from configuration
  List<String> _parseEnvFilesList(dynamic value) {
    if (value == null) {
      // Default: try to find all .env* files
      return _findDefaultEnvFiles();
    }

    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    if (value is String) {
      return [value];
    }

    return ['.env'];
  }

  /// Find default .env files in project root
  List<String> _findDefaultEnvFiles() {
    final files = <String>[];
    final directory = Directory.current;

    for (final entity in directory.listSync()) {
      if (entity is File) {
        final name = path.basename(entity.path);
        if (name.startsWith('.env')) {
          files.add(name);
        }
      }
    }

    if (files.isEmpty) {
      log.warning('No .env files found, creating default configuration');
      return ['.env'];
    }

    log.info('Found env files: ${files.join(', ')}');
    return files;
  }

  /// Parse field rename option
  FieldRename _parseFieldRename(String? value) {
    switch (value) {
      case 'none':
        return FieldRename.none;
      case 'snake_to_pascal':
        return FieldRename.snakeToPascal;
      case 'kebab_to_camel':
        return FieldRename.kebabToCamel;
      case 'snake_to_camel':
      default:
        return FieldRename.snakeToCamel;
    }
  }

  /// Parse all environment files
  Future<Map<String, EnvEntry>> _parseEnvFiles(EnvGen config) async {
    final allEntries = <String, EnvEntry>{};

    for (final envFile in config.envFiles) {
      final file = File(envFile);

      if (!file.existsSync()) {
        log.warning('Environment file not found: $envFile (skipping)');
        continue;
      }

      try {
        final entries = EnvParser.parseFile(envFile);
        allEntries.addAll(entries);
        log.info('Parsed ${entries.length} entries from $envFile');
      } catch (e) {
        log.severe('Failed to parse $envFile: $e');
        rethrow;
      }
    }

    if (allEntries.isEmpty) {
      throw StateError(
        'No environment variables found. Please check your .env files.',
      );
    }

    return allEntries;
  }

  /// Validate that all required keys exist
  void _validateRequiredKeys(
    Map<String, EnvEntry> entries,
    EnvGen config,
  ) {
    final missingKeys = <String>[];

    for (final key in config.requiredKeys) {
      if (!entries.containsKey(key)) {
        missingKeys.add(key);
      }
    }

    if (missingKeys.isNotEmpty) {
      throw StateError(
        'Required environment variables are missing: ${missingKeys.join(', ')}\n'
        'Please add them to your .env file.',
      );
    }
  }
}