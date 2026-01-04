import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

/// Tests for utility methods: count, max, min, sum
///
/// These tests verify that the utility methods produce correct SQL output
/// and return the expected results.
void main() {
  setUpAll(() async {
    await initTestEnvironment();
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  setUp(() {
    clearCapturedSql();
  });

  group('Utility Methods - count()', () {
    test('count() with where clause produces correct SQL', () async {
      final result = await Users.instance.count(
        where: (user) => user.id.gt(10),
      );

      expect(
        result,
        isA<int>(),
        reason: 'count() should return an integer',
      );
      expect(
        lastSql,
        contains('count(*)'),
        reason: 'SQL should contain count(*)',
      );
      expect(
        lastSql,
        contains('WHERE'),
        reason: 'SQL should contain WHERE clause',
      );
    });
  });

  group('Utility Methods - max()', () {
    test('max() with where clause filters results', () async {
      clearCapturedSql();

      final result = await Users.instance.max(
        (user) => user.id,
        where: (user) => user.id.lt(50),
      );

      expect(
        result,
        isA<num?>(),
        reason: 'max() should return a number or null',
      );
      expect(
        lastSql,
        contains('max('),
        reason: 'SQL should contain max() function',
      );
      expect(
        lastSql,
        contains('WHERE'),
        reason: 'SQL should contain WHERE clause',
      );
    });
  });

  group('Utility Methods - min()', () {
    test('min() with where clause filters results', () async {
      clearCapturedSql();

      final result = await Users.instance.min(
        (user) => user.id,
        where: (user) => user.id.gte(10),
      );

      expect(
        result,
        isA<num?>(),
        reason: 'min() should return a number or null',
      );
      expect(
        lastSql,
        contains('min('),
        reason: 'SQL should contain min() function',
      );
      expect(
        lastSql,
        contains('WHERE'),
        reason: 'SQL should contain WHERE clause',
      );
    });
  });

  group('Utility Methods - sum()', () {
    test('sum() with where clause filters results', () async {
      clearCapturedSql();

      final result = await Users.instance.sum(
        (user) => user.id,
        where: (user) => user.id.lte(20),
      );

      expect(
        result,
        isA<num?>(),
        reason: 'sum() should return a number or null',
      );
      expect(
        lastSql,
        contains('sum('),
        reason: 'SQL should contain sum() function',
      );
      expect(
        lastSql,
        contains('WHERE'),
        reason: 'SQL should contain WHERE clause',
      );
    });
  });

  group('Utility Methods - Combined', () {
    test('all utility methods work together', () async {
      final count = await Users.instance.count(
        where: (user) => user.id.gt(0),
      );

      final max = await Users.instance.max(
        (user) => user.id,
        where: (user) => user.id.gt(0),
      );

      final min = await Users.instance.min(
        (user) => user.id,
        where: (user) => user.id.gt(0),
      );

      final sum = await Users.instance.sum(
        (user) => user.id,
        where: (user) => user.id.gt(0),
      );

      expect(count, isA<int>());
      expect(max, isA<num?>());
      expect(min, isA<num?>());
      expect(sum, isA<num?>());
    });
  });
}
