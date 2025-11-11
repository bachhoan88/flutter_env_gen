import 'package:test/test.dart';
import 'package:flutter_env_gen/flutter_env_gen.dart';

void main() {
  group('EnvGen Annotation', () {
    test('creates with default values', () {
      const config = EnvGen();
      expect(config.className, isNull);
      expect(config.fieldRename, equals(FieldRename.snakeToCamel));
      expect(config.envFiles, equals(['.env']));
      expect(config.outputPath, isNull);
      expect(config.sensitiveKeys, isEmpty);
      expect(config.requiredKeys, isEmpty);
      expect(config.generateLoader, isFalse);
    });

    test('creates with custom values', () {
      const config = EnvGen(
        envFiles: ['.env', '.env.prod'],
        className: 'AppConfig',
        fieldRename: FieldRename.none,
        requiredKeys: ['API_KEY'],
        sensitiveKeys: ['SECRET'],
        outputPath: 'lib/config/env.g.dart',
        generateLoader: true,
      );

      expect(config.envFiles, equals(['.env', '.env.prod']));
      expect(config.className, equals('AppConfig'));
      expect(config.fieldRename, equals(FieldRename.none));
      expect(config.requiredKeys, equals(['API_KEY']));
      expect(config.sensitiveKeys, equals(['SECRET']));
      expect(config.outputPath, equals('lib/config/env.g.dart'));
      expect(config.generateLoader, isTrue);
    });

    test('creates with empty lists', () {
      const config = EnvGen(
        envFiles: [],
        requiredKeys: [],
        sensitiveKeys: [],
      );

      expect(config.envFiles, isEmpty);
      expect(config.requiredKeys, isEmpty);
      expect(config.sensitiveKeys, isEmpty);
    });

    test('creates with multiple sensitive keys', () {
      const config = EnvGen(
        sensitiveKeys: ['SECRET', 'PASSWORD', 'TOKEN', 'KEY'],
      );

      expect(config.sensitiveKeys.length, equals(4));
      expect(config.sensitiveKeys, containsAll(['SECRET', 'PASSWORD', 'TOKEN', 'KEY']));
    });
  });

  group('FieldRename', () {
    test('has correct enum values', () {
      expect(FieldRename.values.length, equals(4));
      expect(FieldRename.values, contains(FieldRename.none));
      expect(FieldRename.values, contains(FieldRename.snakeToCamel));
      expect(FieldRename.values, contains(FieldRename.snakeToPascal));
      expect(FieldRename.values, contains(FieldRename.kebabToCamel));
    });

    test('enum values have correct names', () {
      expect(FieldRename.none.name, equals('none'));
      expect(FieldRename.snakeToCamel.name, equals('snakeToCamel'));
      expect(FieldRename.snakeToPascal.name, equals('snakeToPascal'));
      expect(FieldRename.kebabToCamel.name, equals('kebabToCamel'));
    });

    test('can compare enum values', () {
      expect(FieldRename.none == FieldRename.none, isTrue);
      expect(FieldRename.none == FieldRename.snakeToCamel, isFalse);
    });
  });

  group('EnvField Annotation', () {
    test('creates with default values', () {
      const field = EnvField();
      expect(field.name, isNull);
      expect(field.defaultValue, isNull);
      expect(field.required, isFalse);
      expect(field.obfuscate, isFalse);
    });

    test('creates with custom values', () {
      const field = EnvField(
        name: 'customName',
        defaultValue: 'defaultVal',
        required: true,
        obfuscate: true,
      );

      expect(field.name, equals('customName'));
      expect(field.defaultValue, equals('defaultVal'));
      expect(field.required, isTrue);
      expect(field.obfuscate, isTrue);
    });

    test('supports different default value types', () {
      const stringField = EnvField(defaultValue: 'string');
      const intField = EnvField(defaultValue: 42);
      const boolField = EnvField(defaultValue: true);
      const doubleField = EnvField(defaultValue: 3.14);

      expect(stringField.defaultValue, equals('string'));
      expect(intField.defaultValue, equals(42));
      expect(boolField.defaultValue, equals(true));
      expect(doubleField.defaultValue, equals(3.14));
    });

    test('creates with only name', () {
      const field = EnvField(name: 'myField');
      expect(field.name, equals('myField'));
      expect(field.defaultValue, isNull);
      expect(field.required, isFalse);
    });

    test('creates with only required flag', () {
      const field = EnvField(required: true);
      expect(field.required, isTrue);
      expect(field.name, isNull);
      expect(field.obfuscate, isFalse);
    });
  });
}