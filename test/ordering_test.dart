import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:sequelize_dart_example/models/post_details.model.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  group('Ordering Queries', () {
    setUpAll(() async {
      await initTestEnvironment();
      await seedInitialData();
    });

    tearDownAll(() async {
      await cleanupTestEnvironment();
    });

    setUp(() {
      clearCapturedSql();
    });

    test('should order by simple column', () async {
      await Users.model.findAll(
        order: [
          ['id', 'DESC'],
        ],
      );

      expect(lastSql, containsSql('ORDER BY'));
      expect(lastSql, containsSql('id DESC'));
    });

    test('should order by Sequelize.fn', () async {
      await Users.model.findAll(
        order: [Sequelize.fn('max', Sequelize.col('id'))],
        group: ['id'], // Grouping required for aggregate function in order
      );

      expect(lastSql, containsSql('ORDER BY max(id)'));
    });

    test('should order by Sequelize.fn with direction', () async {
      await Users.model.findAll(
        order: [
          [Sequelize.fn('max', Sequelize.col('id')), 'DESC'],
        ],
        group: ['id'],
      );

      expect(lastSql, containsSql('ORDER BY max(id) DESC'));
    });

    test('should order by included model column', () async {
      await Users.model.findAll(
        include: (include) => [include.post()],
        order: [
          ['post', 'id', 'DESC'],
        ],
      );

      expect(lastSql, containsSql('ORDER BY post.id DESC'));
    });

    test('should combined multiple order clauses', () async {
      await Users.model.findAll(
        include: (include) => [include.post()],
        order: [
          ['id', 'DESC'],
          Sequelize.fn('max', Sequelize.col('Users.id')),
          [Sequelize.fn('max', Sequelize.col('Users.id')), 'DESC'],
          ['post', 'id', 'DESC'],
        ],
        group: ['Users.id', 'post.id'], // Fix ambiguity and satisfy aggregate
      );

      expect(lastSql, containsSql('ORDER BY'));
      expect(lastSql, containsSql('max(Users.id)'));
      expect(lastSql, containsSql('max(Users.id) DESC'));
      expect(lastSql, containsSql('post.id DESC'));
    });

    test(
      'should order in nested include with hoistIncludeOptions = true',
      () async {
        // Close the default bridge first to ensure fresh state for hoist test
        await cleanupTestEnvironment();
        clearCapturedSql();

        final hoistSequelize = Sequelize().createInstance(
          connection: PostgresConnection(
            url: postgresUrl,
            hoistIncludeOptions: true,
          ),
          logging: (String sql) {
            capturedSql.add(sql);
          },
        );

        await hoistSequelize.initialize(
          models: [Users.model, Post.model, PostDetails.model],
        );

        await Users.model.findAll(
          include: (include) => [
            include.post(
              order: [
                ['id', 'DESC'],
              ],
            ),
          ],
        );

        // When hoisted, the order from include should be in the main query
        expect(lastSql, containsSql('ORDER BY post.id DESC'));

        await hoistSequelize.close();

        // Re-initialize for next tests if any
        await initTestEnvironment();
      },
    );
  });
}
