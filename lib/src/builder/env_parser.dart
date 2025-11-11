import 'dart:io';

/// Parses .env files
class EnvParser {
  /// Parse a single .env file
  static Map<String, EnvEntry> parseFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception('Environment file not found: $path');
    }

    final content = file.readAsStringSync();
    return parseContent(content);
  }

  /// Parse .env content
  static Map<String, EnvEntry> parseContent(String content) {
    final entries = <String, EnvEntry>{};
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }

      // Handle multiline values
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          var value = parts.sublist(1).join('=').trim();

          // Handle quoted values
          value = _unquote(value);

          // Check for multiline values
          if (value.startsWith('"""') || value.startsWith("'''")) {
            final quote = value.substring(0, 3);
            value = value.substring(3);

            // Continue reading until we find the closing quotes
            while (i + 1 < lines.length && !value.endsWith(quote)) {
              i++;
              value += '\n${lines[i]}';
            }

            if (value.endsWith(quote)) {
              value = value.substring(0, value.length - 3);
            }
          }

          entries[key] = EnvEntry(
            key: key,
            rawValue: value,
            type: _detectType(value),
          );
        }
      }
    }

    return entries;
  }

  /// Remove quotes from value
  static String _unquote(String value) {
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  /// Detect the type of a value
  static EnvType _detectType(String value) {
    // Boolean
    if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
      return EnvType.boolean;
    }

    // Integer
    if (int.tryParse(value) != null && !value.contains('.')) {
      return EnvType.integer;
    }

    // Double
    if (double.tryParse(value) != null) {
      return EnvType.double;
    }

    // List (comma-separated)
    if (value.contains(',') && !value.contains(' ')) {
      return EnvType.list;
    }

    // Default to string
    return EnvType.string;
  }

  /// Merge multiple environment maps
  static Map<String, EnvEntry> mergeEnvironments(
    List<Map<String, EnvEntry>> environments,
  ) {
    final merged = <String, EnvEntry>{};

    for (final env in environments) {
      merged.addAll(env);
    }

    return merged;
  }
}

/// Environment entry
class EnvEntry {
  final String key;
  final String rawValue;
  final EnvType type;

  EnvEntry({
    required this.key,
    required this.rawValue,
    required this.type,
  });

  /// Get the typed value
  String get typedValue {
    switch (type) {
      case EnvType.boolean:
        return rawValue.toLowerCase();
      case EnvType.integer:
      case EnvType.double:
        return rawValue;
      case EnvType.string:
        return "'$rawValue'";
      case EnvType.list:
        final items = rawValue.split(',').map((e) => "'${e.trim()}'").join(', ');
        return '[$items]';
    }
  }

  /// Get the Dart type name
  String get dartType {
    switch (type) {
      case EnvType.boolean:
        return 'bool';
      case EnvType.integer:
        return 'int';
      case EnvType.double:
        return 'double';
      case EnvType.string:
        return 'String';
      case EnvType.list:
        return 'List<String>';
    }
  }
}

/// Environment value types
enum EnvType {
  string,
  integer,
  double,
  boolean,
  list,
}