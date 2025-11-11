import 'package:test/test.dart';
import 'package:flutter_env_gen/src/builder/env_parser.dart';
import 'package:flutter_env_gen/src/builder/code_generator.dart';
import 'package:flutter_env_gen/src/annotations/env_gen.dart';

void main() {
  group('CodeGenerator', () {
    test('generates basic environment class', () {
      final entries = {
        'API_KEY': EnvEntry(key: 'API_KEY', rawValue: 'test123', type: EnvType.string),
        'PORT': EnvEntry(key: 'PORT', rawValue: '8080', type: EnvType.integer),
      };

      final config = EnvGen(
        envFiles: ['.env'],
        className: 'TestEnv',
      );

      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('class TestEnv'));
      expect(code, contains('apiKey'));
      expect(code, contains('port'));
      expect(code, contains('GENERATED CODE'));
    });

    test('generates with different field rename strategies', () {
      final entries = {
        'API_KEY': EnvEntry(key: 'API_KEY', rawValue: 'test', type: EnvType.string),
      };

      // Test snakeToCamel (default)
      var config = EnvGen(fieldRename: FieldRename.snakeToCamel);
      var generator = CodeGenerator(entries: entries, config: config);
      var code = generator.generate();
      expect(code, contains('apiKey'));

      // Test snakeToPascal
      config = EnvGen(fieldRename: FieldRename.snakeToPascal);
      generator = CodeGenerator(entries: entries, config: config);
      code = generator.generate();
      expect(code, contains('ApiKey'));

      // Test none
      config = EnvGen(fieldRename: FieldRename.none);
      generator = CodeGenerator(entries: entries, config: config);
      code = generator.generate();
      expect(code, contains('API_KEY'));
    });

    test('generates with kebab-case conversion', () {
      final entries = {
        'api-key': EnvEntry(key: 'api-key', rawValue: 'test', type: EnvType.string),
      };

      final config = EnvGen(fieldRename: FieldRename.kebabToCamel);
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('apiKey'));
    });

    test('handles all data types', () {
      final entries = {
        'STRING_VAL': EnvEntry(key: 'STRING_VAL', rawValue: 'hello', type: EnvType.string),
        'INT_VAL': EnvEntry(key: 'INT_VAL', rawValue: '42', type: EnvType.integer),
        'DOUBLE_VAL': EnvEntry(key: 'DOUBLE_VAL', rawValue: '3.14', type: EnvType.double),
        'BOOL_VAL': EnvEntry(key: 'BOOL_VAL', rawValue: 'true', type: EnvType.boolean),
        'LIST_VAL': EnvEntry(key: 'LIST_VAL', rawValue: 'a,b,c', type: EnvType.list),
      };

      final config = EnvGen();
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('String.fromEnvironment'));
      expect(code, contains('int.fromEnvironment'));
      expect(code, contains('bool.fromEnvironment'));
      expect(code, contains('_parseList'));
    });

    test('generates loader class when generateLoader is true', () {
      final entries = {
        'API_KEY': EnvEntry(key: 'API_KEY', rawValue: 'test', type: EnvType.string),
      };

      final config = EnvGen(generateLoader: true);
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('_EnvLoader'));
    });

    test('handles sensitive keys', () {
      final entries = {
        'API_SECRET': EnvEntry(key: 'API_SECRET', rawValue: 'secret123', type: EnvType.string),
        'PASSWORD': EnvEntry(key: 'PASSWORD', rawValue: 'pass123', type: EnvType.string),
        'API_KEY': EnvEntry(key: 'API_KEY', rawValue: 'key123', type: EnvType.string),
      };

      final config = EnvGen(
        sensitiveKeys: ['SECRET', 'PASSWORD'],
      );

      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('_loadSensitive'));
    });

    test('handles required keys', () {
      final entries = {
        'REQUIRED_KEY': EnvEntry(key: 'REQUIRED_KEY', rawValue: 'value', type: EnvType.string),
        'OPTIONAL_KEY': EnvEntry(key: 'OPTIONAL_KEY', rawValue: 'value', type: EnvType.string),
      };

      final config = EnvGen(
        requiredKeys: ['REQUIRED_KEY'],
      );

      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      // Should generate without errors
      expect(code, isNotEmpty);
      expect(code, contains('requiredKey'));
      expect(code, contains('optionalKey'));
    });

    test('generates currentEnvironment getter', () {
      final entries = {
        'KEY': EnvEntry(key: 'KEY', rawValue: 'value', type: EnvType.string),
      };

      final config = EnvGen();
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('currentEnvironment'));
      expect(code, contains('ENVIRONMENT'));
    });

    test('generates init method', () {
      final entries = {
        'KEY': EnvEntry(key: 'KEY', rawValue: 'value', type: EnvType.string),
      };

      final config = EnvGen();
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('init()'));
    });

    test('uses custom class name', () {
      final entries = {
        'KEY': EnvEntry(key: 'KEY', rawValue: 'value', type: EnvType.string),
      };

      final config = EnvGen(className: 'CustomConfig');
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('class CustomConfig'));
    });

    test('uses default class name when not specified', () {
      final entries = {
        'KEY': EnvEntry(key: 'KEY', rawValue: 'value', type: EnvType.string),
      };

      final config = EnvGen();
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('class Env'));
    });

    test('generates valid Dart code', () {
      final entries = {
        'API_KEY': EnvEntry(key: 'API_KEY', rawValue: 'test123', type: EnvType.string),
        'PORT': EnvEntry(key: 'PORT', rawValue: '8080', type: EnvType.integer),
        'ENABLED': EnvEntry(key: 'ENABLED', rawValue: 'true', type: EnvType.boolean),
      };

      final config = EnvGen();
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      // Should be properly formatted Dart code
      expect(code, isNotEmpty);
      expect(code, contains('class Env'));
      expect(code, contains('{'));
      expect(code, contains('}'));
    });

    test('handles empty entries', () {
      final entries = <String, EnvEntry>{};
      final config = EnvGen();
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('class Env'));
    });

    test('includes documentation comments', () {
      final entries = {
        'API_KEY': EnvEntry(key: 'API_KEY', rawValue: 'test', type: EnvType.string),
      };

      final config = EnvGen(envFiles: ['.env.dev', '.env.prod']);
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('/// Environment configuration'));
      expect(code, contains('/// Generated from:'));
      expect(code, contains('.env.dev'));
      expect(code, contains('.env.prod'));
    });

    test('generates _parseList method for list types', () {
      final entries = {
        'TAGS': EnvEntry(key: 'TAGS', rawValue: 'tag1,tag2,tag3', type: EnvType.list),
      };

      final config = EnvGen();
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('_parseList'));
      expect(code, contains('split'));
    });

    test('handles multiple list fields', () {
      final entries = {
        'TAGS': EnvEntry(key: 'TAGS', rawValue: 'tag1,tag2', type: EnvType.list),
        'CATEGORIES': EnvEntry(key: 'CATEGORIES', rawValue: 'cat1,cat2', type: EnvType.list),
      };

      final config = EnvGen();
      final generator = CodeGenerator(entries: entries, config: config);
      final code = generator.generate();

      expect(code, contains('tags'));
      expect(code, contains('categories'));
      expect(code, contains('_parseList'));
    });
  });
}

