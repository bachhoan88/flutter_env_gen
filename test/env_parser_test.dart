import 'dart:io';
import 'package:test/test.dart';
import 'package:flutter_env_gen/src/builder/env_parser.dart';

void main() {
  group('EnvParser', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('env_parser_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('parseContent', () {
      test('parses simple key-value pairs', () {
        const content = '''
API_KEY=abc123
DATABASE_URL=postgres://localhost:5432
''';
        final result = EnvParser.parseContent(content);

        expect(result['API_KEY']?.rawValue, equals('abc123'));
        expect(result['API_KEY']?.type, equals(EnvType.string));
        expect(result['DATABASE_URL']?.rawValue, equals('postgres://localhost:5432'));
      });

      test('parses different types correctly', () {
        const content = '''
STRING_VAL=hello
INT_VAL=42
DOUBLE_VAL=3.14
BOOL_TRUE=true
BOOL_FALSE=false
LIST_VAL=item1,item2,item3
''';
        final result = EnvParser.parseContent(content);

        expect(result['STRING_VAL']?.type, equals(EnvType.string));
        expect(result['INT_VAL']?.type, equals(EnvType.integer));
        expect(result['INT_VAL']?.rawValue, equals('42'));
        expect(result['DOUBLE_VAL']?.type, equals(EnvType.double));
        expect(result['DOUBLE_VAL']?.rawValue, equals('3.14'));
        expect(result['BOOL_TRUE']?.type, equals(EnvType.boolean));
        expect(result['BOOL_TRUE']?.rawValue, equals('true'));
        expect(result['BOOL_FALSE']?.type, equals(EnvType.boolean));
        expect(result['LIST_VAL']?.type, equals(EnvType.list));
      });

      test('handles quoted values', () {
        const content = '''
SINGLE_QUOTED='hello world'
DOUBLE_QUOTED="hello world"
UNQUOTED=hello
''';
        final result = EnvParser.parseContent(content);

        expect(result['SINGLE_QUOTED']?.rawValue, equals('hello world'));
        expect(result['DOUBLE_QUOTED']?.rawValue, equals('hello world'));
        expect(result['UNQUOTED']?.rawValue, equals('hello'));
      });

      test('skips empty lines and comments', () {
        const content = '''
# This is a comment
API_KEY=abc123

# Another comment
DATABASE_URL=postgres://localhost:5432
''';
        final result = EnvParser.parseContent(content);

        expect(result.length, equals(2));
        expect(result['API_KEY']?.rawValue, equals('abc123'));
        expect(result['DATABASE_URL']?.rawValue, equals('postgres://localhost:5432'));
      });

      test('handles values with equals signs', () {
        const content = 'URL=https://example.com?key=value&foo=bar';
        final result = EnvParser.parseContent(content);

        expect(result['URL']?.rawValue, equals('https://example.com?key=value&foo=bar'));
      });

      test('handles multiline values with triple quotes', () {
        const content = '''
MULTILINE="""line1
line2
line3"""
''';
        final result = EnvParser.parseContent(content);

        expect(result['MULTILINE']?.rawValue, contains('line1'));
        expect(result['MULTILINE']?.rawValue, contains('line2'));
        expect(result['MULTILINE']?.rawValue, contains('line3'));
      });

      test('handles empty content', () {
        const content = '';
        final result = EnvParser.parseContent(content);

        expect(result, isEmpty);
      });
    });

    group('parseFile', () {
      test('parses existing file successfully', () {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('API_KEY=test123\nPORT=8080');

        final result = EnvParser.parseFile(file.path);

        expect(result['API_KEY']?.rawValue, equals('test123'));
        expect(result['PORT']?.rawValue, equals('8080'));
        expect(result['PORT']?.type, equals(EnvType.integer));
      });

      test('throws exception for non-existent file', () {
        expect(
          () => EnvParser.parseFile('${tempDir.path}/nonexistent.env'),
          throwsException,
        );
      });
    });

    group('mergeEnvironments', () {
      test('merges multiple environment maps', () {
        final env1 = {
          'KEY1': EnvEntry(key: 'KEY1', rawValue: 'value1', type: EnvType.string),
          'KEY2': EnvEntry(key: 'KEY2', rawValue: 'value2', type: EnvType.string),
        };

        final env2 = {
          'KEY2': EnvEntry(key: 'KEY2', rawValue: 'overridden', type: EnvType.string),
          'KEY3': EnvEntry(key: 'KEY3', rawValue: 'value3', type: EnvType.string),
        };

        final result = EnvParser.mergeEnvironments([env1, env2]);

        expect(result['KEY1']?.rawValue, equals('value1'));
        expect(result['KEY2']?.rawValue, equals('overridden'));
        expect(result['KEY3']?.rawValue, equals('value3'));
        expect(result.length, equals(3));
      });

      test('handles empty list', () {
        final result = EnvParser.mergeEnvironments([]);
        expect(result, isEmpty);
      });
    });
  });

  group('EnvEntry', () {
    test('generates correct typed value for string', () {
      final entry = EnvEntry(key: 'KEY', rawValue: 'hello', type: EnvType.string);
      expect(entry.typedValue, equals("'hello'"));
      expect(entry.dartType, equals('String'));
    });

    test('generates correct typed value for integer', () {
      final entry = EnvEntry(key: 'KEY', rawValue: '42', type: EnvType.integer);
      expect(entry.typedValue, equals('42'));
      expect(entry.dartType, equals('int'));
    });

    test('generates correct typed value for double', () {
      final entry = EnvEntry(key: 'KEY', rawValue: '3.14', type: EnvType.double);
      expect(entry.typedValue, equals('3.14'));
      expect(entry.dartType, equals('double'));
    });

    test('generates correct typed value for boolean', () {
      final entry = EnvEntry(key: 'KEY', rawValue: 'TRUE', type: EnvType.boolean);
      expect(entry.typedValue, equals('true'));
      expect(entry.dartType, equals('bool'));
    });

    test('generates correct typed value for list', () {
      final entry = EnvEntry(key: 'KEY', rawValue: 'a,b,c', type: EnvType.list);
      expect(entry.typedValue, equals("['a', 'b', 'c']"));
      expect(entry.dartType, equals('List<String>'));
    });
  });

  group('EnvType', () {
    test('has all expected enum values', () {
      expect(EnvType.values.length, equals(5));
      expect(EnvType.values, contains(EnvType.string));
      expect(EnvType.values, contains(EnvType.integer));
      expect(EnvType.values, contains(EnvType.double));
      expect(EnvType.values, contains(EnvType.boolean));
      expect(EnvType.values, contains(EnvType.list));
    });
  });
}

