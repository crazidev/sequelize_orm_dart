import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:test/test.dart';

import '../../lib/models/users.model.dart';
import '../test_helper.dart';

/// Tests for logical operators: and, or, not
///
/// These tests verify that logical operators produce correct SQL output
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

  group('Logical Operators', () {
    test('AND combines conditions with AND', () async {
      await Users.instance.findAll(
        (u) => Query(
          where: and([
            u.id.eq(1),
            u.email.eq('test@example.com'),
          ]),
        ),
      );

      expect(
        lastSql,
        contains('"id" = 1'),
        reason: 'SQL should contain "id" = 1',
      );
      expect(
        lastSql,
        contains('"email" = \'test@example.com\''),
        reason: 'SQL should contain "email" = \'test@example.com\'',
      );
      expect(
        lastSql,
        contains('AND'),
        reason: 'SQL should contain AND',
      );
    });

    test('OR combines conditions with OR', () async {
      await Users.instance.findAll(
        (u) => Query(
          where: or([
            u.id.eq(1),
            u.id.eq(2),
          ]),
        ),
      );

      expect(
        lastSql,
        contains('"id" = 1'),
        reason: 'SQL should contain "id" = 1',
      );
      expect(
        lastSql,
        contains('"id" = 2'),
        reason: 'SQL should contain "id" = 2',
      );
      expect(
        lastSql,
        contains('OR'),
        reason: 'SQL should contain OR',
      );
    });

    test('NOT negates a condition', () async {
      await Users.instance.findAll(
        (u) => Query(
          where: not([
            u.id.eq(1),
          ]),
        ),
      );

      expect(
        lastSql,
        contains('NOT'),
        reason: 'SQL should contain NOT',
      );
    });

    test('Nested AND inside OR', () async {
      await Users.instance.findAll(
        (u) => Query(
          where: or([
            and([
              u.id.eq(1),
              u.email.eq('admin@example.com'),
            ]),
            and([
              u.id.eq(2),
              u.email.eq('user@example.com'),
            ]),
          ]),
        ),
      );

      expect(
        lastSql,
        contains('OR'),
        reason: 'SQL should contain OR',
      );
      expect(
        lastSql,
        contains('AND'),
        reason: 'SQL should contain AND',
      );
    });

    test('Nested OR inside AND', () async {
      await Users.instance.findAll(
        (u) => Query(
          where: and([
            or([
              u.id.eq(1),
              u.id.eq(2),
            ]),
            u.email.eq('test@example.com'),
          ]),
        ),
      );

      expect(
        lastSql,
        contains('AND'),
        reason: 'SQL should contain AND',
      );
      expect(
        lastSql,
        contains('OR'),
        reason: 'SQL should contain OR',
      );
    });
  });
}
