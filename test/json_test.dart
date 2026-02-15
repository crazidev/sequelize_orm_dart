import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

/// Tests for JSON/JSONB column type customization.
///
/// Verifies that:
/// - `parseJsonList` and `parseJsonMap` handle all supported types
/// - JSON columns with custom Dart types round-trip through the database
/// - The bridge String to jsonDecode fallback works correctly
void main() {
  setUpAll(() async {
    await initTestEnvironment();
    await sequelize.sync(alter: true);
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  setUp(() {
    clearCapturedSql();
  });

  // ── Parser unit tests ──

  group('parseJsonList<T>', () {
    test('returns null for null input', () {
      expect(parseJsonList<String>(null), isNull);
      expect(parseJsonList<int>(null), isNull);
    });

    test('parses List<String> from List', () {
      final result = parseJsonList<String>(['a', 'b', 'c']);
      expect(result, isA<List<String>>());
      expect(result, equals(['a', 'b', 'c']));
    });

    test('parses List<int> from List', () {
      final result = parseJsonList<int>([1, 2, 3]);
      expect(result, isA<List<int>>());
      expect(result, equals([1, 2, 3]));
    });

    test('parses List<double> from List', () {
      final result = parseJsonList<double>([1.5, 2.5]);
      expect(result, isA<List<double>>());
      expect(result, equals([1.5, 2.5]));
    });

    test('parses List<bool> from List', () {
      final result = parseJsonList<bool>([true, false, true]);
      expect(result, isA<List<bool>>());
      expect(result, equals([true, false, true]));
    });

    test('parses List<dynamic> from List', () {
      final result = parseJsonList<dynamic>([1, 'two', true]);
      expect(result, isA<List<dynamic>>());
      expect(result, equals([1, 'two', true]));
    });

    test('parses List<Map<String, dynamic>> from List', () {
      final input = [
        {'name': 'Alice'},
        {'name': 'Bob'},
      ];
      final result = parseJsonList<Map<String, dynamic>>(input);
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result?.length, 2);
      expect(result?[0]['name'], 'Alice');
    });

    test('decodes JSON string to List<String>', () {
      final result = parseJsonList<String>('["a", "b", "c"]');
      expect(result, isA<List<String>>());
      expect(result, equals(['a', 'b', 'c']));
    });

    test('decodes JSON string to List<int>', () {
      final result = parseJsonList<int>('[1, 2, 3]');
      expect(result, isA<List<int>>());
      expect(result, equals([1, 2, 3]));
    });

    test('decodes JSON string to List<Map<String, dynamic>>', () {
      final result = parseJsonList<Map<String, dynamic>>(
        '[{"id": 1}, {"id": 2}]',
      );
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result?.length, 2);
    });

    test('throws on wrong type', () {
      expect(
        () => parseJsonList<String>(42),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles empty list', () {
      expect(parseJsonList<String>([]), equals([]));
      expect(parseJsonList<String>('[]'), equals([]));
    });
  });

  group('parseJsonMap<T>', () {
    test('returns null for null input', () {
      expect(parseJsonMap<dynamic>(null), isNull);
      expect(parseJsonMap<String>(null), isNull);
    });

    test('parses Map<String, dynamic> from Map', () {
      final result = parseJsonMap<dynamic>({'key': 'value', 'num': 42});
      expect(result, isA<Map<String, dynamic>>());
      expect(result?['key'], 'value');
      expect(result?['num'], 42);
    });

    test('parses Map<String, String> from Map', () {
      final result = parseJsonMap<String>({'a': 'hello', 'b': 'world'});
      expect(result, isA<Map<String, String>>());
      expect(result, equals({'a': 'hello', 'b': 'world'}));
    });

    test('parses Map<String, int> from Map', () {
      final result = parseJsonMap<int>({'x': 1, 'y': 2});
      expect(result, isA<Map<String, int>>());
      expect(result, equals({'x': 1, 'y': 2}));
    });

    test('decodes JSON string to Map<String, dynamic>', () {
      final result = parseJsonMap<dynamic>('{"key": "value", "num": 42}');
      expect(result, isA<Map<String, dynamic>>());
      expect(result?['key'], 'value');
      expect(result?['num'], 42);
    });

    test('decodes JSON string to Map<String, String>', () {
      final result = parseJsonMap<String>('{"a": "hello", "b": "world"}');
      expect(result, isA<Map<String, String>>());
      expect(result?['a'], 'hello');
    });

    test('throws on wrong type', () {
      expect(
        () => parseJsonMap<dynamic>([1, 2, 3]),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles empty map', () {
      expect(parseJsonMap<dynamic>({}), equals({}));
      expect(parseJsonMap<dynamic>('{}'), equals({}));
    });
  });

  group('parseMapValue (existing, with jsonDecode fallback)', () {
    test('decodes JSON string to Map', () {
      final result = parseMapValue('{"token": "abc123"}');
      expect(result, isA<Map<String, dynamic>>());
      expect(result?['token'], 'abc123');
    });

    test('passes through Map directly', () {
      final result = parseMapValue({'key': 'value'});
      expect(result?['key'], 'value');
    });

    test('returns null for null', () {
      expect(parseMapValue(null), isNull);
    });
  });

  group('parseField with JSON parsers', () {
    test('wraps JSON list error with context', () {
      expect(
        () => parseField<List<String>>(
          42,
          parseJsonList<String>,
          model: 'TestModel',
          key: 'tags',
          expectedType: 'List<String>',
          operation: 'findAll',
        ),
        throwsA(isA<ModelParseException>()),
      );
    });

    test('wraps JSON map error with context', () {
      expect(
        () => parseField<Map<String, dynamic>>(
          [1, 2, 3],
          parseJsonMap<dynamic>,
          model: 'TestModel',
          key: 'metadata',
          expectedType: 'Map<String, dynamic>',
          operation: 'findOne',
        ),
        throwsA(isA<ModelParseException>()),
      );
    });
  });

  // ── Database round-trip tests ──

  group('JSON columns - database round-trip', () {
    test('create with List<String> tags and read back', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tags = ['dart', 'flutter', 'sequelize'];

      final created = await Users.model.create(CreateUsers(
        email: 'json_tags_$timestamp@test.com',
        firstName: 'JSON',
        lastName: 'Tags',
        tags: tags,
      ));

      expect(created.tags, isNotNull);
      expect(created.tags, isA<List<String>>());
      expect(created.tags, equals(tags));

      // Read back
      final found = await Users.model.findOne(
        where: (u) => u.id.eq(created.id),
      );
      expect(found?.tags, isNotNull);
      expect(found?.tags, equals(tags));
    });

    test('create with List<int> scores and read back', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final scores = [100, 200, 300];

      final created = await Users.model.create(CreateUsers(
        email: 'json_scores_$timestamp@test.com',
        firstName: 'JSON',
        lastName: 'Scores',
        scores: scores,
      ));

      expect(created.scores, isNotNull);
      expect(created.scores, isA<List<int>>());
      expect(created.scores, equals(scores));

      // Read back
      final found = await Users.model.findOne(
        where: (u) => u.id.eq(created.id),
      );
      expect(found?.scores, isNotNull);
      expect(found?.scores, equals(scores));
    });

    test('create with Map<String, dynamic> metadata and read back', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final metadata = {'role': 'admin', 'level': 5, 'active': true};

      final created = await Users.model.create(CreateUsers(
        email: 'json_meta_$timestamp@test.com',
        firstName: 'JSON',
        lastName: 'Meta',
        metadata: metadata,
      ));

      expect(created.metadata, isNotNull);
      expect(created.metadata, isA<Map<String, dynamic>>());
      expect(created.metadata?['role'], 'admin');
      expect(created.metadata?['level'], 5);

      // Read back
      final found = await Users.model.findOne(
        where: (u) => u.id.eq(created.id),
      );
      expect(found?.metadata, isNotNull);
      expect(found?.metadata?['role'], 'admin');
    });

    test('null JSON columns work', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final created = await Users.model.create(CreateUsers(
        email: 'json_null_$timestamp@test.com',
        firstName: 'JSON',
        lastName: 'Null',
      ));

      expect(created.tags, isNull);
      expect(created.scores, isNull);
      expect(created.metadata, isNull);
    });

    test('empty JSON collections work', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final created = await Users.model.create(CreateUsers(
        email: 'json_empty_$timestamp@test.com',
        firstName: 'JSON',
        lastName: 'Empty',
        tags: [],
        scores: [],
        metadata: {},
      ));

      expect(created.tags, equals([]));
      expect(created.scores, equals([]));
      expect(created.metadata, equals({}));
    });

    test('toJson serializes JSON columns correctly', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final created = await Users.model.create(CreateUsers(
        email: 'json_tojson_$timestamp@test.com',
        firstName: 'JSON',
        lastName: 'ToJson',
        tags: ['a', 'b'],
        scores: [1, 2],
        metadata: {'key': 'value'},
      ));

      final json = created.toJson();
      expect(json['tags'], equals(['a', 'b']));
      expect(json['scores'], equals([1, 2]));
      expect(json['metadata'], equals({'key': 'value'}));
    });

    test('findAll returns correct JSON values', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await Users.model.create(CreateUsers(
        email: 'json_list_a_$timestamp@test.com',
        firstName: 'ListA',
        lastName: 'JSON',
        tags: ['x'],
        scores: [10],
      ));
      await Users.model.create(CreateUsers(
        email: 'json_list_b_$timestamp@test.com',
        firstName: 'ListB',
        lastName: 'JSON',
        tags: ['y', 'z'],
        scores: [20, 30],
      ));

      final users = await Users.model.findAll(
        where: (u) => u.lastName.eq('JSON'),
      );

      final jsonUsers =
          users.where((u) => u.lastName == 'JSON').toList();
      expect(jsonUsers.length, greaterThanOrEqualTo(2));

      for (final user in jsonUsers) {
        if (user.tags != null) {
          expect(user.tags, isA<List<String>>());
        }
        if (user.scores != null) {
          expect(user.scores, isA<List<int>>());
        }
      }
    });
  });

  // ── DataType tests ──

  group('JsonDataType', () {
    test('default JSON is Map<String, dynamic>', () {
      expect(DataType.JSON.typeName, equals('JSON'));
      expect(DataType.JSON.dartTypeValue, isNull);
    });

    test('default JSONB is Map<String, dynamic>', () {
      expect(DataType.JSONB.typeName, equals('JSONB'));
      expect(DataType.JSONB.dartTypeValue, isNull);
    });

    test('JSON with type: stores dart type hint', () {
      final jsonType = DataType.JSON(type: List<String>);
      expect(jsonType.typeName, equals('JSON'));
      expect(jsonType.dartTypeValue, isNotNull);
      expect(jsonType.dartTypeValue, contains('List'));
      expect(jsonType.dartTypeValue, contains('String'));
    });

    test('JSONB with type: stores dart type hint', () {
      final jsonbType = DataType.JSONB(type: List<int>);
      expect(jsonbType.typeName, equals('JSONB'));
      expect(jsonbType.dartTypeValue, isNotNull);
      expect(jsonbType.dartTypeValue, contains('List'));
      expect(jsonbType.dartTypeValue, contains('int'));
    });

    test('equality for same type', () {
      final a = DataType.JSON(type: List<String>);
      final b = DataType.JSON(type: List<String>);
      expect(a, equals(b));
    });

    test('inequality for different types', () {
      final a = DataType.JSON(type: List<String>);
      final b = DataType.JSON(type: List<int>);
      expect(a, isNot(equals(b)));
    });

    test('toString includes type hint', () {
      final jsonType = DataType.JSONB(type: List<String>);
      final str = jsonType.toString();
      expect(str, contains('JSONB'));
      expect(str, contains('type:'));
    });

    test('toJson includes SQL type', () {
      final jsonType = DataType.JSONB(type: List<String>);
      final json = jsonType.toJson();
      expect(json['type'], equals('JSONB'));
    });
  });
}
