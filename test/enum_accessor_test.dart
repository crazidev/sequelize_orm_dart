import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  final prefix = DateTime.now().millisecondsSinceEpoch;

  late int userActiveId;
  late int userInactiveId;
  late int userPendingId;
  late int userNullId;

  setUpAll(() async {
    await initTestEnvironment();
    await sequelize.sync(alter: true);

    // Seed test data
    final active = await Users.model.create(
      CreateUsers(
        email: 'enum_active_$prefix@test.com',
        firstName: 'Active',
        lastName: 'EnumTest',
        status: UsersStatus.active,
      ),
    );
    userActiveId = active.id!;

    final inactive = await Users.model.create(
      CreateUsers(
        email: 'enum_inactive_$prefix@test.com',
        firstName: 'Inactive',
        lastName: 'EnumTest',
        status: UsersStatus.inactive,
      ),
    );
    userInactiveId = inactive.id!;

    final pending = await Users.model.create(
      CreateUsers(
        email: 'enum_pending_$prefix@test.com',
        firstName: 'Pending',
        lastName: 'EnumTest',
        status: UsersStatus.pending,
      ),
    );
    userPendingId = pending.id!;

    final nullUser = await Users.model.create(
      CreateUsers(
        email: 'enum_null_$prefix@test.com',
        firstName: 'Null',
        lastName: 'EnumTest',
      ),
    );
    userNullId = nullUser.id!;
  });

  tearDownAll(() async {
    await Users.model.destroy(
      where: (u) => u.lastName.eq('EnumTest'),
      force: true,
    );
    await cleanupTestEnvironment();
  });

  group('Enum Accessors - Prefix Shortcuts', () {
    test('isActive shortcut', () async {
      final user = await Users.model.findOne(
        where: (u) => u.status.isActive,
      );
      expect(user?.id, userActiveId);
    });

    test('notActive shortcut', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.status.notActive,
          u.lastName.eq('EnumTest'),
          u.status.isNotNull(),
        ]),
      );
      // Should find inactive and pending
      expect(users.length, 2);
      expect(users.any((u) => u.id == userInactiveId), isTrue);
      expect(users.any((u) => u.id == userPendingId), isTrue);
    });
  });

  group('Enum Accessors - Grouped is/not', () {
    test('status.eq.active', () async {
      final user = await Users.model.findOne(
        where: (u) => u.status.eq.active,
      );
      expect(user?.id, userActiveId);
    });

    test('status.not.inactive', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.status.not.inactive,
          u.lastName.eq('EnumTest'),
          u.status.isNotNull(),
        ]),
      );
      // Should find active and pending
      expect(users.length, 2);
      expect(users.any((u) => u.id == userActiveId), isTrue);
      expect(users.any((u) => u.id == userPendingId), isTrue);
    });
  });

  group('Enum Accessors - Standard Operators', () {
    test('status.eq.active', () async {
      final user = await Users.model.findOne(
        where: (u) => u.status.eq.active,
      );
      expect(user?.id, userActiveId);
    });

    test('status.not.active', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.status.not.active,
          u.lastName.eq('EnumTest'),
          u.status.isNotNull(),
        ]),
      );
      expect(users.any((u) => u.id == userActiveId), isFalse);
    });
  });

  group('Enum Accessors - Null Checks', () {
    test('isNull() method', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.status.isNull(),
          u.lastName.eq('EnumTest'),
        ]),
      );
      expect(user?.id, userNullId);
    });

    test('isNotNull() method', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.status.isNotNull(),
          u.lastName.eq('EnumTest'),
        ]),
      );
      expect(users.length, 3);
      expect(users.any((u) => u.id == userNullId), isFalse);
    });
  });

  group('Enum Accessors - Method-based calls', () {
    test('eq(UsersStatus.active)', () async {
      final user = await Users.model.findOne(
        where: (u) => u.status.eq(UsersStatus.active),
      );
      expect(user?.id, userActiveId);
    });

    test('eq(null) is same as isNull()', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.status.eq(null),
          u.lastName.eq('EnumTest'),
        ]),
      );
      expect(user?.id, userNullId);
    });

    test('not(null) is same as isNotNull()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.status.not(null),
          u.lastName.eq('EnumTest'),
        ]),
      );
      expect(users.length, 3);
    });
  });
}
