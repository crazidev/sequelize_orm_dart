import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

/// Tests for IS operators: isNull, isNotNull
///
/// These tests verify that IS operators produce correct SQL output.
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

  group('IS Operators', () {
    test('isNull produces WHERE "column" IS NULL', () async {
      await Users.model.findAll(where: (user) => user.email.isNull());

      expect(
        lastSql,
        containsSql('IS NULL'),
        reason: 'SQL should contain IS NULL',
      );
    });

    test('isNotNull produces WHERE "column" IS NOT NULL', () async {
      await Users.model.findAll(where: (user) => user.email.isNotNull());

      expect(
        lastSql,
        containsSql('IS NOT NULL'),
        reason: 'SQL should contain IS NOT NULL',
      );
    });
  });
}
