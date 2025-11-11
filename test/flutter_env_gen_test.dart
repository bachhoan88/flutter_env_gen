import 'package:test/test.dart';
import 'package:flutter_env_gen/flutter_env_gen.dart';

void main() {
  group('EnvGen Annotation', () {
    test('creates with default values', () {
      const config = EnvGen();
      expect(config.className, isNull);
      expect(config.fieldRename, equals(FieldRename.snakeToCamel));
    });

    test('creates with custom values', () {
      const config = EnvGen(
        envFiles: ['.env', '.env.prod'],
        className: 'AppConfig',
        fieldRename: FieldRename.none,
        requiredKeys: ['API_KEY'],
        sensitiveKeys: ['SECRET'],
      );

      expect(config.envFiles, equals(['.env', '.env.prod']));
      expect(config.className, equals('AppConfig'));
      expect(config.fieldRename, equals(FieldRename.none));
      expect(config.requiredKeys, equals(['API_KEY']));
      expect(config.sensitiveKeys, equals(['SECRET']));
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
  });
}