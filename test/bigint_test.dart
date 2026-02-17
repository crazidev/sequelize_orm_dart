import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

/// Tests for SequelizeBigInt type and BIGINT column handling.
///
/// Verifies that BIGINT values round-trip correctly through
/// create, findOne, findAll, toJson, and type conversions.
void main() {
  setUpAll(() async {
    await initTestEnvironment();
    // Ensure the users table has the phone_number BIGINT column
    await sequelize.sync(alter: true);
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  setUp(() {
    clearCapturedSql();
  });

  group('SequelizeBigInt type', () {
    test('constructor stores string value', () {
      final bigInt = SequelizeBigInt('9223372036854775807');
      expect(bigInt.value, equals('9223372036854775807'));
    });

    test('fromInt constructor', () {
      final bigInt = SequelizeBigInt.fromInt(42);
      expect(bigInt.value, equals('42'));
    });

    test('fromBigInt constructor', () {
      final bigInt =
          SequelizeBigInt.fromBigInt(BigInt.parse('9223372036854775807'));
      expect(bigInt.value, equals('9223372036854775807'));
    });

    test('toBigInt converts correctly', () {
      final bigInt = SequelizeBigInt('9223372036854775807');
      expect(bigInt.toBigInt(), equals(BigInt.parse('9223372036854775807')));
    });

    test('toInt converts small values', () {
      final bigInt = SequelizeBigInt('42');
      expect(bigInt.toInt(), equals(42));
    });

    test('toJson returns string', () {
      final bigInt = SequelizeBigInt('9223372036854775807');
      expect(bigInt.toJson(), equals('9223372036854775807'));
      expect(bigInt.toJson(), isA<String>());
    });

    test('toString returns value', () {
      final bigInt = SequelizeBigInt('123');
      expect(bigInt.toString(), equals('123'));
    });

    test('equality works on value', () {
      final a = SequelizeBigInt('42');
      final b = SequelizeBigInt('42');
      final c = SequelizeBigInt('99');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      final a = SequelizeBigInt('42');
      final b = SequelizeBigInt('42');
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('parseSequelizeBigIntValue', () {
    test('returns null for null input', () {
      expect(parseSequelizeBigIntValue(null), isNull);
    });

    test('wraps String input', () {
      final result = parseSequelizeBigIntValue('9223372036854775807');
      expect(result, isA<SequelizeBigInt>());
      expect(result?.value, equals('9223372036854775807'));
    });

    test('wraps int input', () {
      final result = parseSequelizeBigIntValue(42);
      expect(result, isA<SequelizeBigInt>());
      expect(result?.value, equals('42'));
    });

    test('throws on unsupported type', () {
      expect(
        () => parseSequelizeBigIntValue(3.14),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('BIGINT column - database round-trip', () {
    test('create with max int64 value and read back',
        skip: isSqlite
            ? 'SQLite stores large integers as IEEE doubles, losing precision'
            : null, () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final maxInt64 = '9223372036854775807';

      final created = await Users.model.create(CreateUsers(
        email: 'bigint_max_$timestamp@test.com',
        firstName: 'BigInt',
        lastName: 'Max',
        phoneNumber: SequelizeBigInt(maxInt64),
      ));

      expect(created.phoneNumber, isNotNull);
      expect(created.phoneNumber, isA<SequelizeBigInt>());
      expect(created.phoneNumber?.value, equals(maxInt64));

      // Read back from database
      final found = await Users.model.findOne(
        where: (u) => u.id.eq(created.id),
      );

      expect(found, isNotNull);
      expect(found?.phoneNumber, isNotNull);
      expect(found?.phoneNumber, isA<SequelizeBigInt>());
      expect(found?.phoneNumber?.value, equals(maxInt64));
    });

    test('create with small bigint value', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final created = await Users.model.create(CreateUsers(
        email: 'bigint_small_$timestamp@test.com',
        firstName: 'BigInt',
        lastName: 'Small',
        phoneNumber: SequelizeBigInt.fromInt(42),
      ));

      expect(created.phoneNumber?.value, equals('42'));
      expect(created.phoneNumber?.toInt(), equals(42));
    });

    test('create with null bigint value', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final created = await Users.model.create(CreateUsers(
        email: 'bigint_null_$timestamp@test.com',
        firstName: 'BigInt',
        lastName: 'Null',
      ));

      expect(created.phoneNumber, isNull);
    });

    test('toJson serializes bigint as string',
        skip: isSqlite
            ? 'SQLite stores large integers as IEEE doubles, losing precision'
            : null, () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final created = await Users.model.create(CreateUsers(
        email: 'bigint_json_$timestamp@test.com',
        firstName: 'BigInt',
        lastName: 'Json',
        phoneNumber: SequelizeBigInt('1234567890123456789'),
      ));

      final json = created.toJson();
      expect(json['phone_number'], isA<String>());
      expect(json['phone_number'], equals('1234567890123456789'));
    });

    test('findAll returns correct bigint values with row context', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create two users with distinct bigint values
      await Users.model.create(CreateUsers(
        email: 'bigint_list_a_$timestamp@test.com',
        firstName: 'ListA',
        lastName: 'BigInt',
        phoneNumber: SequelizeBigInt('1111111111111111111'),
      ));
      await Users.model.create(CreateUsers(
        email: 'bigint_list_b_$timestamp@test.com',
        firstName: 'ListB',
        lastName: 'BigInt',
        phoneNumber: SequelizeBigInt('2222222222222222222'),
      ));

      final users = await Users.model.findAll(
        where: (u) => u.lastName.eq('BigInt'),
      );

      final bigintUsers =
          users.where((u) => u.lastName == 'BigInt').toList();
      expect(bigintUsers.length, greaterThanOrEqualTo(2));

      for (final user in bigintUsers) {
        expect(user.phoneNumber, isA<SequelizeBigInt>());
        expect(user.phoneNumber?.value, isNotEmpty);
      }
    });

    test('toBigInt enables arithmetic on large values',
        skip: isSqlite
            ? 'SQLite stores large integers as IEEE doubles, losing precision'
            : null, () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final largeValue = '9000000000000000000';

      final created = await Users.model.create(CreateUsers(
        email: 'bigint_arith_$timestamp@test.com',
        firstName: 'BigInt',
        lastName: 'Arithmetic',
        phoneNumber: SequelizeBigInt(largeValue),
      ));

      final result = created.phoneNumber!.toBigInt() + BigInt.one;
      expect(result, equals(BigInt.parse('9000000000000000001')));
    });
  });
}
