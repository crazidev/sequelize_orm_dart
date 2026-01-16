import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

/// Tests for increment and decrement methods
///
/// These tests verify that increment and decrement methods produce correct SQL output
/// and return expected results.
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

  group('Increment/Decrement Methods - increment()', () {
    test('increment() with single field produces correct SQL', () async {
      final result = await Post.instance.increment(
        views: 5,
        where: (post) => post.id.eq(1),
      );

      expect(
        result,
        isA<List<PostValues>>(),
        reason: 'increment() should return a list of updated records',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
      expect(
        lastSql,
        contains('views'),
        reason: 'SQL should contain the views field',
      );
      expect(
        lastSql,
        contains('WHERE'),
        reason: 'SQL should contain WHERE clause',
      );
    });

    test('increment() with multiple fields produces correct SQL', () async {
      // Note: This test assumes there are multiple numeric fields
      // Currently only 'views' is available in Post model
      final result = await Post.instance.increment(
        views: 10,
        where: (post) => post.id.lt(5),
      );

      expect(
        result,
        isA<List<PostValues>>(),
        reason: 'increment() should return a list of updated records',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
      expect(
        lastSql,
        contains('views'),
        reason: 'SQL should contain the views field',
      );
    });

    test('increment() without where clause throws error', () async {
      expect(
        () => Post.instance.increment(views: 5),
        throwsA(isA<ArgumentError>()),
        reason: 'increment() without where clause should throw ArgumentError',
      );
    });

    test('increment() with no fields throws error', () async {
      expect(
        () => Post.instance.increment(where: (post) => post.id.eq(1)),
        throwsA(isA<ArgumentError>()),
        reason: 'increment() without fields should throw ArgumentError',
      );
    });
  });

  group('Increment/Decrement Methods - decrement()', () {
    test('decrement() with single field produces correct SQL', () async {
      final result = await Post.instance.decrement(
        views: 3,
        where: (post) => post.id.eq(2),
      );

      expect(
        result,
        isA<List<PostValues>>(),
        reason: 'decrement() should return a list of updated records',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
      expect(
        lastSql,
        contains('views'),
        reason: 'SQL should contain the views field',
      );
      expect(
        lastSql,
        contains('WHERE'),
        reason: 'SQL should contain WHERE clause',
      );
    });

    test('decrement() with complex where clause', () async {
      final result = await Post.instance.decrement(
        views: 2,
        where: (post) => and([
          post.id.gt(1),
          post.id.lt(10),
          post.views.gte(0),
        ]),
      );

      expect(
        result,
        isA<List<PostValues>>(),
        reason: 'decrement() should return a list of updated records',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
      expect(
        lastSql,
        contains('AND'),
        reason: 'SQL should contain AND operator for complex conditions',
      );
    });

    test('decrement() without where clause throws error', () async {
      expect(
        () => Post.instance.decrement(views: 5),
        throwsA(isA<ArgumentError>()),
        reason: 'decrement() without where clause should throw ArgumentError',
      );
    });

    test('decrement() with no fields throws error', () async {
      expect(
        () => Post.instance.decrement(where: (post) => post.id.eq(1)),
        throwsA(isA<ArgumentError>()),
        reason: 'decrement() without fields should throw ArgumentError',
      );
    });
  });

  group('Increment/Decrement Methods - Combined Operations', () {
    test('increment and decrement work together', () async {
      // First increment
      final incrementResult = await Post.instance.increment(
        views: 10,
        where: (post) => post.id.eq(1),
      );

      expect(
        incrementResult,
        isA<List<PostValues>>(),
        reason: 'increment() should return a list of updated records',
      );

      clearCapturedSql();

      // Then decrement
      final decrementResult = await Post.instance.decrement(
        views: 5,
        where: (post) => post.id.eq(1),
      );

      expect(
        decrementResult,
        isA<List<PostValues>>(),
        reason: 'decrement() should return a list of updated records',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
    });

    test('bulk increment and decrement operations', () async {
      // Bulk increment
      final bulkIncrement = await Post.instance.increment(
        views: 15,
        where: (post) => post.id.in_([1, 2, 3]),
      );

      expect(
        bulkIncrement,
        isA<List<PostValues>>(),
        reason: 'bulk increment() should return a list of updated records',
      );

      clearCapturedSql();

      // Bulk decrement
      final bulkDecrement = await Post.instance.decrement(
        views: 7,
        where: (post) => post.id.in_([1, 2, 3]),
      );

      expect(
        bulkDecrement,
        isA<List<PostValues>>(),
        reason: 'bulk decrement() should return a list of updated records',
      );
      expect(
        lastSql,
        contains('IN'),
        reason: 'SQL should contain IN operator for bulk operations',
      );
    });
  });

  group('Increment/Decrement Methods - Edge Cases', () {
    test('increment() with zero value', () async {
      final result = await Post.instance.increment(
        views: 0,
        where: (post) => post.id.eq(1),
      );

      expect(
        result,
        isA<List<PostValues>>(),
        reason: 'increment() with zero should still execute',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement even with zero increment',
      );
    });

    test('decrement() with zero value', () async {
      final result = await Post.instance.decrement(
        views: 0,
        where: (post) => post.id.eq(1),
      );

      expect(
        result,
        isA<List<PostValues>>(),
        reason: 'decrement() with zero should still execute',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement even with zero decrement',
      );
    });

    test('increment() with negative value', () async {
      final result = await Post.instance.increment(
        views: -5,
        where: (post) => post.id.eq(1),
      );

      expect(
        result,
        isA<List<PostValues>>(),
        reason: 'increment() with negative value should work',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
    });

    test('decrement() with negative value', () async {
      final result = await Post.instance.decrement(
        views: -3,
        where: (post) => post.id.eq(1),
      );

      expect(
        result,
        isA<List<PostValues>>(),
        reason: 'decrement() with negative value should work',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
    });
  });
}
