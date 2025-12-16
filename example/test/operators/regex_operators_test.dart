import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

/// Tests for regex operators: regexp, notRegexp, iRegexp, notIRegexp
///
/// These tests verify that regex operators produce correct SQL output.
/// Note: PostgreSQL uses ~ for regex, MySQL uses REGEXP.
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

  group('Regex Operators', () {
    test('regexp produces WHERE "column" ~ pattern (PostgreSQL)', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.regexp('^admin')),
      );

      expect(
        lastSql,
        contains('~'),
        reason: 'SQL should contain ~ for PostgreSQL regex',
      );
    });

    test('notRegexp produces WHERE "column" !~ pattern (PostgreSQL)', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.notRegexp('^spam')),
      );

      expect(
        lastSql,
        contains('!~'),
        reason: 'SQL should contain !~ for PostgreSQL not regex',
      );
    });

    test('iRegexp produces WHERE "column" ~* pattern (PostgreSQL)', () async {
      await Users.instance.findAll(
        (u) => Query(where: u.email.iRegexp('^ADMIN')),
      );

      expect(
        lastSql,
        contains('~*'),
        reason: 'SQL should contain ~* for case-insensitive regex',
      );
    });

    test(
      'notIRegexp produces WHERE "column" !~* pattern (PostgreSQL)',
      () async {
        await Users.instance.findAll(
          (u) => Query(where: u.email.notIRegexp('^SPAM')),
        );

        expect(
          lastSql,
          contains('!~*'),
          reason: 'SQL should contain !~* for case-insensitive not regex',
        );
      },
    );
  });
}
