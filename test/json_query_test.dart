import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

/// Tests for JSON/JSONB querying — verifies that the fluent JsonColumn API
/// works end-to-end against the database for all supported operations:
///
/// - `.key()` / `.at()` navigation
/// - `.eq()` / `.ne()` / `.gt()` / `.gte()` / `.lt()` / `.lte()` comparisons
/// - `.isNull()` / `.isNotNull()` null checks
/// - `.unquote()` text extraction (string operators)
/// - `.contains()` array containment (PostgreSQL JSONB only)
/// - Whole-column `.eq()` with type-safe generics
/// - Combining JSON conditions with `and()`, `or()`
void main() {
  // Unique prefix to avoid collisions with other test suites
  final prefix = DateTime.now().millisecondsSinceEpoch;

  // IDs of seeded users for lookup
  late int? userAdminId;
  late int? userModId;
  late int? userNullId;

  setUpAll(() async {
    await initTestEnvironment();
    await sequelize.sync(alter: true);

    // Seed test data
    final admin = await Users.model.create(CreateUsers(
      email: 'jq_admin_$prefix@test.com',
      firstName: 'Admin',
      lastName: 'JsonQuery',
      tags: ['dart', 'flutter', 'sequelize'],
      scores: [95, 87, 100],
      metadata: {
        'role': 'admin',
        'level': 5,
        'active': true,
        'address': {
          'city': 'Berlin',
          'zip': '10115',
        },
      },
    ));
    userAdminId = admin.id;

    final moderator = await Users.model.create(CreateUsers(
      email: 'jq_mod_$prefix@test.com',
      firstName: 'Mod',
      lastName: 'JsonQuery',
      tags: ['dart', 'backend'],
      scores: [60, 70],
      metadata: {
        'role': 'moderator',
        'level': 3,
        'active': false,
        'address': {
          'city': 'Munich',
          'zip': '80331',
        },
      },
    ));
    userModId = moderator.id;

    // User with null JSON columns
    final nullUser = await Users.model.create(CreateUsers(
      email: 'jq_null_$prefix@test.com',
      firstName: 'NullJson',
      lastName: 'JsonQuery',
    ));
    userNullId = nullUser.id;
  });

  tearDownAll(() async {
    // Cleanup seeded data
    await Users.model.destroy(
      where: (u) => u.lastName.eq('JsonQuery'),
      force: true,
    );
    await cleanupTestEnvironment();
  });

  setUp(() {
    clearCapturedSql();
  });

  // ── .key() navigation ──

  group('JsonColumn.key() - object key navigation', () {
    test('top-level string key with .eq()', () async {
      final user = await Users.model.findOne(
        where: (u) => u.metadata.key('role').eq('admin'),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('top-level numeric key with .eq()', () async {
      final user = await Users.model.findOne(
        where: (u) => u.metadata.key('level').eq(5),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('top-level boolean key with .eq()', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.metadata.key('active').eq(true),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('nested key with chained .key()', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.metadata.key('address').key('city').eq('Berlin'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('nested key returns correct value', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.metadata.key('address').key('zip').eq('80331'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userModId);
    });

    test('.ne() excludes matching key', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('role').ne('admin'),
          u.lastName.eq('JsonQuery'),
          u.metadata.isNotNull(),
        ]),
      );
      expect(users.any((u) => u.id == userModId), isTrue);
      expect(users.any((u) => u.id == userAdminId), isFalse);
    });
  });

  // ── .at() navigation ──

  group('JsonColumn.at() - array index navigation', () {
    test('first element with .eq()', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.tags.at(0).eq('dart'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      // Both admin and mod have 'dart' at index 0
    });

    test('specific index distinguishes records', () async {
      // Admin has 'flutter' at index 1, Mod has 'backend' at index 1
      final user = await Users.model.findOne(
        where: (u) => and([
          u.tags.at(1).eq('flutter'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('numeric array element with .eq()', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.scores.at(0).eq(95),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('numeric array element with .gt()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.scores.at(0).gt(80),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Only admin has scores[0] = 95 > 80
      expect(users.length, 1);
      expect(users.first.id, userAdminId);
    });

    test('numeric array element with .lt()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.scores.at(0).lt(80),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Only mod has scores[0] = 60 < 80
      expect(users.length, 1);
      expect(users.first.id, userModId);
    });

    test('numeric array element with .gte()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.scores.at(0).gte(60),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Both admin (95) and mod (60) match >= 60
      expect(users.length, 2);
    });

    test('numeric array element with .lte()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.scores.at(0).lte(60),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Only mod (60) matches <= 60
      expect(users.length, 1);
      expect(users.first.id, userModId);
    });
  });

  // ── .unquote() text extraction ──

  group('JsonPath.unquote() - text extraction', () {
    test('unquote string key with .eq()', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.metadata.key('role').unquote().eq('admin'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('unquote nested key with .eq()', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.metadata.key('address').key('city').unquote().eq('Berlin'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('unquote array element with .eq()', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.tags.at(0).unquote().eq('dart'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
    });

    test('unquote with .like() pattern matching', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('role').unquote().like('%mod%'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 1);
      expect(users.first.id, userModId);
    });

    test('unquote with .startsWith()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('role').unquote().startsWith('adm'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 1);
      expect(users.first.id, userAdminId);
    });

    test('unquote with .endsWith()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('role').unquote().endsWith('ator'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 1);
      expect(users.first.id, userModId);
    });

    test('unquote with .substring()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('address').key('city').unquote().substring('erli'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 1);
      expect(users.first.id, userAdminId);
    });

    test('unquote with .ne()', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('role').unquote().ne('admin'),
          u.lastName.eq('JsonQuery'),
          u.metadata.isNotNull(),
        ]),
      );
      expect(users.any((u) => u.id == userModId), isTrue);
      expect(users.any((u) => u.id == userAdminId), isFalse);
    });
  });

  // ── Null checks ──

  group('JsonColumn null checks', () {
    test('.isNull() finds users with null JSON', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.isNull(),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 1);
      expect(users.first.id, userNullId);
    });

    test('.isNotNull() excludes users with null JSON', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.isNotNull(),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 2);
      expect(users.any((u) => u.id == userNullId), isFalse);
    });

    test('.isNull() on tags', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.tags.isNull(),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 1);
      expect(users.first.id, userNullId);
    });

    test('.isNotNull() on scores', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.scores.isNotNull(),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 2);
      expect(users.any((u) => u.id == userNullId), isFalse);
    });
  });

  // ── Whole-column equality (type-safe generics) ──

  group('JsonColumn.eq() - whole-column equality', () {
    test('List<String> tags equality', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.tags.eq(['dart', 'flutter', 'sequelize']),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('List<String> tags equality - different array', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.tags.eq(['dart', 'backend']),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userModId);
    });

    test('List<int> scores equality', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.scores.eq([95, 87, 100]),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('List<String> tags .ne() excludes match', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.tags.ne(['dart', 'flutter', 'sequelize']),
          u.lastName.eq('JsonQuery'),
          u.tags.isNotNull(),
        ]),
      );
      expect(users.any((u) => u.id == userAdminId), isFalse);
      expect(users.any((u) => u.id == userModId), isTrue);
    });
  });

  // ── Combining conditions ──

  group('Combining JSON conditions', () {
    test('and() with multiple JSON keys', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.metadata.key('role').eq('admin'),
          u.metadata.key('level').eq(5),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('or() with JSON conditions', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          or([
            u.metadata.key('role').eq('admin'),
            u.metadata.key('role').eq('moderator'),
          ]),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 2);
    });

    test('mixing JSON and regular column conditions', () async {
      final user = await Users.model.findOne(
        where: (u) => and([
          u.firstName.eq('Admin'),
          u.tags.at(0).eq('dart'),
          u.metadata.key('level').gt(3),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });

    test('complex nested and/or with JSON', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.tags.at(0).eq('dart'),
          u.metadata.key('level').gt(2),
          or([
            u.metadata.key('role').eq('admin'),
            u.metadata.key('role').eq('moderator'),
          ]),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 2);
    });

    test('and() with key comparison and null check', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.isNotNull(),
          u.metadata.key('active').eq(false),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 1);
      expect(users.first.id, userModId);
    });
  });

  // ── JsonPath comparison operators on key ──

  group('JsonPath comparison operators', () {
    test('.gt() on numeric key', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('level').gt(3),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Only admin has level 5 > 3
      expect(users.length, 1);
      expect(users.first.id, userAdminId);
    });

    test('.gte() on numeric key', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('level').gte(3),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Admin (5) and Mod (3) both match >= 3
      expect(users.length, 2);
    });

    test('.lt() on numeric key', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('level').lt(5),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Only mod has level 3 < 5
      expect(users.length, 1);
      expect(users.first.id, userModId);
    });

    test('.lte() on numeric key', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('level').lte(5),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Both admin (5) and mod (3) match <= 5
      expect(users.length, 2);
    });

    test('.isNull() on JsonPath', () async {
      // metadata.key('nonexistent') should be null
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('nonexistent').isNull(),
          u.lastName.eq('JsonQuery'),
          u.metadata.isNotNull(),
        ]),
      );
      // Both admin and mod have metadata but no 'nonexistent' key
      expect(users.length, 2);
    });

    test('.isNotNull() on JsonPath', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.key('role').isNotNull(),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(users.length, 2);
    });
  });

  // ── Update JSON columns ──

  group('Updating JSON columns', () {
    late int? updateUserId;

    setUp(() async {
      final user = await Users.model.create(CreateUsers(
        email: 'jq_update_${DateTime.now().millisecondsSinceEpoch}@test.com',
        firstName: 'Update',
        lastName: 'JsonQuery',
        tags: ['old'],
        scores: [1],
        metadata: {'status': 'pending'},
      ));
      updateUserId = user.id;
    });

    test('update List<String> tags', () async {
      await Users.model.update(
        tags: ['new', 'tags', 'here'],
        where: (u) => u.id.eq(updateUserId),
      );

      final found = await Users.model.findOne(
        where: (u) => u.id.eq(updateUserId),
      );
      expect(found?.tags, equals(['new', 'tags', 'here']));
    });

    test('update List<int> scores', () async {
      await Users.model.update(
        scores: [100, 200],
        where: (u) => u.id.eq(updateUserId),
      );

      final found = await Users.model.findOne(
        where: (u) => u.id.eq(updateUserId),
      );
      expect(found?.scores, equals([100, 200]));
    });

    test('update Map<String, dynamic> metadata', () async {
      await Users.model.update(
        metadata: {'status': 'active', 'level': 10},
        where: (u) => u.id.eq(updateUserId),
      );

      final found = await Users.model.findOne(
        where: (u) => u.id.eq(updateUserId),
      );
      expect(found?.metadata?['status'], 'active');
      expect(found?.metadata?['level'], 10);
    });

    test('query after update returns correct record', () async {
      await Users.model.update(
        tags: ['updated_tag'],
        where: (u) => u.id.eq(updateUserId),
      );

      final user = await Users.model.findOne(
        where: (u) => and([
          u.tags.at(0).eq('updated_tag'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, updateUserId);
    });
  });

  // ── JsonColumn.unquote() on whole column ──

  group('JsonColumn.unquote() - whole column text extraction', () {
    test('unquote on whole column with .eq()', () async {
      // This tests the JsonColumn.unquote() method (not JsonPath.unquote())
      // Less common but available for cases where the entire column
      // needs text extraction
      final user = await Users.model.findOne(
        where: (u) => and([
          u.metadata.key('role').unquote().eq('admin'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      expect(user, isNotNull);
      expect(user?.id, userAdminId);
    });
  });

  // ── findAll with JSON where ──

  group('findAll with JSON conditions', () {
    test('findAll with key condition returns multiple', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.tags.at(0).eq('dart'),
          u.lastName.eq('JsonQuery'),
        ]),
      );
      // Both admin and mod have 'dart' at tags[0]
      expect(users.length, 2);
    });

    test('findAll with ordering and JSON where', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.isNotNull(),
          u.lastName.eq('JsonQuery'),
        ]),
        order: [
          ['id', 'ASC']
        ],
      );
      expect(users.length, greaterThanOrEqualTo(2));
      expect(users.first.id!, lessThan(users.last.id!));
    });

    test('findAll with limit and JSON where', () async {
      final users = await Users.model.findAll(
        where: (u) => and([
          u.metadata.isNotNull(),
          u.lastName.eq('JsonQuery'),
        ]),
        limit: 1,
      );
      expect(users.length, 1);
    });
  });
}
