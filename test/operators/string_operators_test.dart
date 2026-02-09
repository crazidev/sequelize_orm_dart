import 'dart:io';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
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
      await Users.model.findAll(
        where: (user) => user.email.like('%@example.com'),
      );

      expect(
        lastSql,
        containsSql('LIKE'),
        reason: 'SQL should contain LIKE',
      );
      expect(
        lastSql,
        containsSql('%@example.com'),
        reason: 'SQL should contain the pattern',
      );
    });

    test('notLike produces WHERE "column" NOT LIKE pattern', () async {
      await Users.model.findAll(
        where: (user) => user.email.notLike('%@spam.com'),
      );

      expect(
        lastSql,
        containsSql("NOT LIKE '%@spam.com'"),
        reason: 'SQL should contain NOT LIKE',
      );
    });

    test('startsWith produces WHERE "column" LIKE pattern%', () async {
      await Users.model.findAll(
        where: (user) => user.email.startsWith('admin'),
      );

      expect(
        lastSql,
        containsSql("LIKE 'admin%'"),
        reason: 'SQL should contain LIKE for startsWith',
      );
    });

    test('endsWith produces WHERE "column" LIKE %pattern', () async {
      await Users.model.findAll(
        where: (user) => user.email.endsWith('.com'),
      );

      expect(
        lastSql,
        containsSql("LIKE '%.com'"),
        reason: 'SQL should contain LIKE for endsWith',
      );
    });

    test('substring produces WHERE "column" LIKE %pattern%', () async {
      await Users.model.findAll(
        where: (user) => user.email.substring('example'),
      );

      expect(
        lastSql,
        containsSql("LIKE '%example%'"),
        reason: 'SQL should contain LIKE for substring',
      );
    });

    test('iLike produces correct SQL', () async {
      await Users.model.findAll(
        where: (user) => user.email.iLike('%@EXAMPLE.COM'),
      );

      final dbType =
          Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';
      final isMysqlFamily = dbType == 'mysql' || dbType == 'mariadb';
      if (isMysqlFamily) {
        expect(lastSql, containsSql("LIKE '%@EXAMPLE.COM'"));
      } else {
        expect(lastSql, containsSql("ILIKE '%@EXAMPLE.COM'"));
      }
    });

    test('notILike produces correct SQL', () async {
      await Users.model.findAll(
        where: (user) => user.email.notILike('%@SPAM.COM'),
      );

      final dbType =
          Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';
      final isMysqlFamily = dbType == 'mysql' || dbType == 'mariadb';
      if (isMysqlFamily) {
        expect(lastSql, containsSql("NOT LIKE '%@SPAM.COM'"));
      } else {
        expect(lastSql, containsSql("NOT ILIKE '%@SPAM.COM'"));
      }
    });
  });
}
