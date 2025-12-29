import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

/// Tests for numeric comparison operators: gt, gte, lt, lte, between, notBetween
///
/// These tests verify that numeric operators produce correct SQL output.
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

  group('Numeric Comparison Operators', () {
    test('gt produces WHERE "column" > value', () async {
      await Users.instance.findAll(where: (user) => user.id.gt(10));

      expect(
        lastSql,
        contains('"id" > 10'),
        reason: 'SQL should contain "id" > 10',
      );
    });

    test('gte produces WHERE "column" >= value', () async {
      await Users.instance.findAll(where: (user) => user.id.gte(10));

      expect(
        lastSql,
        contains('"id" >= 10'),
        reason: 'SQL should contain "id" >= 10',
      );
    });

    test('lt produces WHERE "column" < value', () async {
      await Users.instance.findAll(where: (user) => user.id.lt(10));

      expect(
        lastSql,
        contains('"id" < 10'),
        reason: 'SQL should contain "id" < 10',
      );
    });

    test('lte produces WHERE "column" <= value', () async {
      await Users.instance.findAll(where: (user) => user.id.lte(10));

      expect(
        lastSql,
        contains('"id" <= 10'),
        reason: 'SQL should contain "id" <= 10',
      );
    });

    test('between produces WHERE "column" BETWEEN x AND y', () async {
      await Users.instance.findAll(where: (user) => user.id.between([1, 10]));

      expect(
        lastSql,
        contains('BETWEEN 1 AND 10'),
        reason: 'SQL should contain BETWEEN 1 AND 10',
      );
    });

    test('notBetween produces WHERE "column" NOT BETWEEN x AND y', () async {
      await Users.instance.findAll(
        where: (user) => user.id.notBetween([1, 10]),
      );

      expect(
        lastSql,
        contains('NOT BETWEEN 1 AND 10'),
        reason: 'SQL should contain NOT BETWEEN 1 AND 10',
      );
    });
  });
}
