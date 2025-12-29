import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

/// Tests for list operators: in_, notIn
///
/// These tests verify that list operators produce correct SQL output.
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

  group('List Operators', () {
    test('in_ produces WHERE "column" IN (values)', () async {
      await Users.instance.findAll(where: (user) => user.id.in_([1, 2, 3]));

      expect(
        lastSql,
        contains('"id" IN (1, 2, 3)'),
        reason: 'SQL should contain "id" IN (1, 2, 3)',
      );
    });

    test('notIn produces WHERE "column" NOT IN (values)', () async {
      await Users.instance.findAll(where: (user) => user.id.notIn([1, 2, 3]));

      expect(
        lastSql,
        contains('"id" NOT IN (1, 2, 3)'),
        reason: 'SQL should contain "id" NOT IN (1, 2, 3)',
      );
    });

    test(
      'in_ with strings produces WHERE "column" IN (string values)',
      () async {
        await Users.instance.findAll(
          where: (user) => user.email.in_(['a@test.com', 'b@test.com']),
        );

        expect(
          lastSql,
          contains('IN'),
          reason: 'SQL should contain IN clause',
        );
        expect(
          lastSql,
          contains('\'a@test.com\''),
          reason: 'SQL should contain string values',
        );
      },
    );
  });
}
