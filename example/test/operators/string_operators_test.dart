import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

/// Tests for string operators: like, notLike, startsWith, endsWith, substring, iLike, notILike
///
/// These tests verify that string operators produce correct SQL output.
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

  group('String Operators', () {
    test('like produces WHERE "column" LIKE pattern', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.like('%@example.com')),
      );

      expect(
        lastSql,
        contains('LIKE'),
        reason: 'SQL should contain LIKE',
      );
      expect(
        lastSql,
        contains('%@example.com'),
        reason: 'SQL should contain the pattern',
      );
    });

    test('notLike produces WHERE "column" NOT LIKE pattern', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.notLike('%@spam.com')),
      );

      expect(
        lastSql,
        contains('NOT LIKE \'%@spam.com\''),
        reason: 'SQL should contain NOT LIKE',
      );
    });

    test('startsWith produces WHERE "column" LIKE pattern%', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.startsWith('admin')),
      );

      expect(
        lastSql,
        contains('LIKE \'admin%\''),
        reason: 'SQL should contain LIKE for startsWith',
      );
    });

    test('endsWith produces WHERE "column" LIKE %pattern', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.endsWith('.com')),
      );

      expect(
        lastSql,
        contains('LIKE \'%.com\''),
        reason: 'SQL should contain LIKE for endsWith',
      );
    });

    test('substring produces WHERE "column" LIKE %pattern%', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.substring('example')),
      );

      expect(
        lastSql,
        contains('LIKE \'%example%\''),
        reason: 'SQL should contain LIKE for substring',
      );
    });

    test('iLike produces WHERE "column" ILIKE pattern (PostgreSQL)', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.iLike('%@EXAMPLE.COM')),
      );

      expect(
        lastSql,
        contains('ILIKE \'%@EXAMPLE.COM\''),
        reason: 'SQL should contain ILIKE for case-insensitive match',
      );
    });

    test(
      'notILike produces WHERE "column" NOT ILIKE pattern (PostgreSQL)',
      () async {
        await Users.instance.findAll(
          (u) => Query(where: u.email.notILike('%@SPAM.COM')),
        );

        expect(
          lastSql,
          contains('NOT ILIKE \'%@SPAM.COM\''),
          reason: 'SQL should contain NOT ILIKE',
        );
      },
    );
  });
}
