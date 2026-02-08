import 'dart:io';

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/models/users.model.dart';
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
    test('regexp produces correct SQL', () async {
      await Users.model.findAll(
        where: (user) => user.email.regexp('^admin'),
      );

      final dbType =
          Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';
      final isMysqlFamily = dbType == 'mysql' || dbType == 'mariadb';
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

      final dbType =
          Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';
      final isMysqlFamily = dbType == 'mysql' || dbType == 'mariadb';
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

      final dbType =
          Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';
      final isMysqlFamily = dbType == 'mysql' || dbType == 'mariadb';
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

      final dbType =
          Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';
      final isMysqlFamily = dbType == 'mysql' || dbType == 'mariadb';
      if (isMysqlFamily) {
        expect(lastSql, containsSql('NOT REGEXP'));
      } else {
        expect(lastSql, containsSql('!~*'));
      }
    });
  });
}
