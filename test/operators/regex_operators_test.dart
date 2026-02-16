import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

/// Tests for regex operators: regexp, notRegexp, iRegexp, notIRegexp
///
/// These tests verify that regex operators produce correct SQL output.
/// Note: PostgreSQL uses ~ for regex, MySQL uses REGEXP.
/// SQLite does not natively support REGEXP without a user-defined function,
/// so these tests are skipped for SQLite.
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

  group('Regex Operators', skip: isSqlite ? 'SQLite does not support REGEXP natively' : null, () {
    test('regexp produces correct SQL', () async {
      await Users.model.findAll(
        where: (user) => user.email.regexp('^admin'),
      );

      if (isMysqlFamily) {
        expect(lastSql, containsSql('REGEXP'));
      } else {
        expect(lastSql, containsSql('~'));
      }
    });

    test('notRegexp produces correct SQL', () async {
      await Users.model.findAll(
        where: (user) => user.email.notRegexp('^spam'),
      );

      if (isMysqlFamily) {
        expect(lastSql, containsSql('NOT REGEXP'));
      } else {
        expect(lastSql, containsSql('!~'));
      }
    });

    test('iRegexp produces correct SQL', () async {
      // In MySQL, REGEXP is usually case-insensitive depending on collation
      await Users.model.findAll(
        where: (user) => user.email.iRegexp('^ADMIN'),
      );

      if (isMysqlFamily) {
        expect(lastSql, containsSql('REGEXP'));
      } else {
        expect(lastSql, containsSql('~*'));
      }
    });

    test('notIRegexp produces correct SQL', () async {
      await Users.model.findAll(
        where: (user) => user.email.notIRegexp('^SPAM'),
      );

      if (isMysqlFamily) {
        expect(lastSql, containsSql('NOT REGEXP'));
      } else {
        expect(lastSql, containsSql('!~*'));
      }
    });
  });
}
