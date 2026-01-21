import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

/// Tests for basic comparison operators: eq, ne
///
/// These tests verify that the operators produce correct SQL output
/// by capturing the SQL via the logging callback.
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

  group('Basic Comparison Operators', () {
    test('eq produces WHERE "column" = value', () async {
      // Test with integer
      await Users.model.findAll(where: (user) => user.id.eq(1));
      expect(
        lastSql,
        contains('"id" = 1'),
        reason: 'SQL should contain "id" = 1',
      );

      clearCapturedSql();

      // Test with string
      await Users.model.findAll(
        where: (user) => user.email.eq('test@example.com'),
      );
      expect(
        lastSql,
        contains('"email" = \'test@example.com\''),
        reason: 'SQL should contain "email" = \'test@example.com\'',
      );
    });

    test('ne produces WHERE "column" != value', () async {
      // Test with integer
      await Users.model.findAll(where: (user) => user.id.ne(1));
      expect(
        lastSql,
        contains('"id" != 1'),
        reason: 'SQL should contain "id" != 1',
      );

      clearCapturedSql();

      // Test with string
      await Users.model.findAll(
        where: (user) => user.email.ne('test@example.com'),
      );
      expect(
        lastSql,
        contains('"email" != \'test@example.com\''),
        reason: 'SQL should contain "email" != \'test@example.com\'',
      );
    });

    test('eq and ne combined with AND', () async {
      await Users.model.findAll(
        where: (user) => and([
          user.id.ne(0),
          user.email.eq('admin@example.com'),
        ]),
      );

      expect(
        lastSql,
        contains('"id" != 0'),
        reason: 'SQL should contain "id" != 0',
      );
      expect(
        lastSql,
        contains('"email" = \'admin@example.com\''),
        reason: 'SQL should contain "email" = \'admin@example.com\'',
      );
      expect(lastSql, contains('AND'), reason: 'SQL should contain AND');
    });
  });
}
