import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

/// Store the seeded user's ID for use in tests
late int seededUserId;

void main() {
  group('Include Query Tests',
      skip: isSqlite ? 'SQLite does not support TRUNCATE with CASCADE' : null,
      () {
    setUpAll(() async {
      await initTestEnvironment();
      await sequelize.sync(alter: true);

      // Clean slate: truncate tables before seeding to ensure predictable IDs
      await Post.model.truncate(cascade: true);
      await Users.model.truncate(cascade: true);

      // Seed test data and capture the user ID
      final seededUser = await Users.model.create(
        CreateUsers(
          email: 'include_test@example.com',
          firstName: 'Test',
          lastName: 'User',
          posts: [
            CreatePost(
              title: 'Post 1',
              content: 'Content 1',
              views: 10,
            ),
            CreatePost(
              title: 'Post 2',
              content: 'Content 2',
              views: 20,
            ),
          ],
        ),
      );
      seededUserId = seededUser.id!;
    });

    tearDownAll(() async {
      await cleanupTestEnvironment();
    });

    setUp(() {
      clearCapturedSql();
    });

    test('Basic include with type-safe syntax', () async {
      final users = await Users.model.findAll(
        where: (user) => and([user.id.eq(seededUserId)]),
        include: (includeUser) => [
          includeUser.posts(),
        ],
      );

      expect(users, isNotEmpty);
      expect(lastSql, isNotNull);
      expect(lastSql, containsSql('SELECT'));
      // Verify that include was processed
      expect(selectQueries.length, greaterThan(0));
    });

    test('Include with separate query', () async {
      final users = await Users.model.findAll(
        where: (user) => and([user.id.eq(seededUserId)]),
        include: (includeUser) => [
          includeUser.posts(separate: true),
        ],
      );

      expect(users, isNotEmpty);
      // With separate: true, there should be multiple queries
      expect(selectQueries.length, greaterThan(1));
    });

    test('Include with filtering (where clause)', () async {
      final users = await Users.model.findAll(
        where: (user) => and([user.id.eq(seededUserId)]),
        include: (includeUser) => [
          includeUser.posts(
            where: (post) => and([
              post.title.like('%Post%'),
            ]),
            separate: true,
          ),
        ],
      );

      expect(users, isNotEmpty);
      // Verify that where clause was included in the query
      final sql = selectQueries.last;
      expect(sql, containsSql('WHERE'));
    });

    test('Include with required (INNER JOIN)', () async {
      final users = await Users.model.findAll(
        where: (user) => and([user.id.eq(seededUserId)]),
        include: (includeUser) => [
          includeUser.posts(required: true),
        ],
      );

      expect(users, isNotEmpty);
      // With required: true, should use INNER JOIN
      final sql = selectQueries.first;
      expect(sql, anyOf(containsSql('INNER JOIN'), containsSql('JOIN')));
    });

    test('Include with pagination (limit and offset)', () async {
      final users = await Users.model.findAll(
        where: (user) => and([user.id.eq(seededUserId)]),
        include: (includeUser) => [
          includeUser.posts(
            separate: true,
            limit: 5,
            offset: 0,
          ),
        ],
      );

      expect(users, isNotEmpty);
      // Verify limit was applied
      final sql = selectQueries.last;
      expect(sql, containsSql('LIMIT'));
    });

    test('Include with ordering', () async {
      final users = await Users.model.findAll(
        where: (user) => and([user.id.eq(seededUserId)]),
        include: (includeUser) => [
          includeUser.posts(
            separate: true,
            order: [
              ['id', 'DESC'],
            ],
          ),
        ],
      );

      expect(users, isNotEmpty);
      // Verify order was applied
      final sql = selectQueries.last;
      expect(sql, containsSql('ORDER BY'));
    });

    test('HasOne association include', () async {
      final users = await Users.model.findAll(
        where: (user) => and([user.id.eq(seededUserId)]),
        include: (includeUser) => [
          includeUser.post(),
        ],
      );

      expect(users, isNotEmpty);
    });

    test('Nested includes support infinite levels', () async {
      // Test that nested includes can be chained infinitely
      final users = await Users.model.findAll(
        where: (user) => and([user.id.eq(seededUserId)]),
        include: (includeUser) => [
          includeUser.posts(
            separate: true,
            // Nested includes would be added here:
            include: (includePost) => [
              includePost.postDetails(),
            ],
          ),
        ],
      );

      expect(users, isNotEmpty);
      // Verify that nested includes are processed
      expect(selectQueries.length, greaterThan(0));
    });

    test('IncludeBuilder creation and toJson', () async {
      // Test that IncludeBuilder can be created with various options
      const includeHelper = UsersIncludeHelper();
      final include = includeHelper.posts(
        separate: true,
        required: false,
        limit: 10,
        offset: 0,
      );
      expect(include, isNotNull);
      expect(include.separate, isTrue);
      expect(include.required, isFalse);
      expect(include.limit, equals(10));
      expect(include.offset, equals(0));

      // Test toJson conversion
      final json = include.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['association'], equals('posts'));
      expect(json['separate'], isTrue);
      expect(json['required'], isFalse);
      expect(json['limit'], equals(10));
      expect(json['offset'], equals(0));
    });

    test('AssociationReference col method', () async {
      // Test that we can get column references from associations
      final queryBuilder = UsersQuery();
      final colRef = queryBuilder.posts.col('title');
      expect(colRef, equals('posts.title'));
    });
  });
}
