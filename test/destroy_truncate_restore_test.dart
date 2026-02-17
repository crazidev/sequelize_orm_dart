import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

/// Tests for destroy, truncate, restore, and paranoid mode operations
///
/// These tests verify that soft delete (paranoid mode), hard delete,
/// truncate, and restore operations work correctly for both static
/// model methods and instance methods.
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

  group('Model.destroy() - Static Method', () {
    test('soft delete with where clause (paranoid model)', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final user = await Users.model.create(
        CreateUsers(
          email: 'destroy_soft_$timestamp@example.com',
          firstName: 'Destroy',
          lastName: 'Soft',
        ),
      );

      expect(user.id, isNotNull, reason: 'User should be created');
      expect(user.deletedAt, isNull, reason: 'deletedAt should be null initially');

      clearCapturedSql();

      // Soft delete the user
      final destroyedCount = await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
      );

      expect(
        destroyedCount,
        equals(1),
        reason: 'destroy() should return 1 for soft deleted record',
      );
      expect(
        lastSql,
        containsSql('UPDATE'),
        reason: 'Soft delete should use UPDATE statement',
      );
      expect(
        lastSql,
        containsSql('deleted_at'),
        reason: 'Soft delete should update deleted_at column',
      );

      // Verify user is soft deleted (not found by default query)
      final findResult = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );
      expect(
        findResult,
        isNull,
        reason: 'Soft deleted user should not be found by default',
      );

      // Verify user still exists with paranoid: false
      final findWithParanoid = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );
      expect(
        findWithParanoid,
        isNotNull,
        reason: 'Soft deleted user should be found with paranoid: false',
      );
      expect(
        findWithParanoid?.deletedAt,
        isNotNull,
        reason: 'Soft deleted user should have deletedAt set',
      );
    });

    test('hard delete with force: true', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final user = await Users.model.create(
        CreateUsers(
          email: 'destroy_hard_$timestamp@example.com',
          firstName: 'Destroy',
          lastName: 'Hard',
        ),
      );

      expect(user.id, isNotNull, reason: 'User should be created');

      clearCapturedSql();

      // Hard delete the user
      final destroyedCount = await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
        force: true,
      );

      expect(
        destroyedCount,
        equals(1),
        reason: 'destroy() should return 1 for hard deleted record',
      );
      expect(
        lastSql,
        containsSql('DELETE'),
        reason: 'Hard delete should use DELETE statement',
      );

      // Verify user is completely gone (even with paranoid: false)
      final findResult = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );
      expect(
        findResult,
        isNull,
        reason: 'Hard deleted user should not be found even with paranoid: false',
      );
    });

    test('destroy returns correct count of affected rows', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create multiple users
      await Users.model.create(
        CreateUsers(
          email: 'destroy_count1_$timestamp@example.com',
          firstName: 'Count1',
          lastName: 'Test',
        ),
      );
      await Users.model.create(
        CreateUsers(
          email: 'destroy_count2_$timestamp@example.com',
          firstName: 'Count2',
          lastName: 'Test',
        ),
      );

      clearCapturedSql();

      // Destroy all users with lastName 'Test' (should match both)
      final destroyedCount = await Users.model.destroy(
        where: (u) => u.lastName.eq('Test'),
        force: true,
      );

      expect(
        destroyedCount,
        greaterThanOrEqualTo(2),
        reason: 'destroy() should return count of all affected rows',
      );
    });
  });

  group('Model.truncate() - Static Method',
      skip: isSqlite ? 'SQLite does not support TRUNCATE with CASCADE' : null,
      () {
    test('truncate removes all records from table', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create some test users
      await Users.model.create(
        CreateUsers(
          email: 'truncate1_$timestamp@example.com',
          firstName: 'Truncate1',
          lastName: 'Test',
        ),
      );
      await Users.model.create(
        CreateUsers(
          email: 'truncate2_$timestamp@example.com',
          firstName: 'Truncate2',
          lastName: 'Test',
        ),
      );

      // Verify users exist
      final countBefore = await Users.model.count();
      expect(
        countBefore,
        greaterThanOrEqualTo(2),
        reason: 'Should have at least 2 users before truncate',
      );

      clearCapturedSql();

      // Truncate the table
      await Users.model.truncate(cascade: true);

      expect(
        lastSql,
        containsSql('TRUNCATE'),
        reason: 'truncate() should use TRUNCATE statement',
      );

      // Verify all records are removed
      final countAfter = await Users.model.count();
      expect(
        countAfter,
        equals(0),
        reason: 'All records should be removed after truncate',
      );
    });

    test('truncate with restartIdentity option', () async {
      clearCapturedSql();

      // Truncate with restartIdentity
      await Users.model.truncate(
        cascade: true,
        restartIdentity: true,
      );

      expect(
        lastSql,
        containsSql('TRUNCATE'),
        reason: 'truncate() should use TRUNCATE statement',
      );
    });
  });

  group('Model.restore() - Static Method', () {
    test('restore soft-deleted record with where clause', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final user = await Users.model.create(
        CreateUsers(
          email: 'restore_$timestamp@example.com',
          firstName: 'Restore',
          lastName: 'Test',
        ),
      );

      // Soft delete the user
      await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
      );

      // Verify user is soft deleted
      final deletedUser = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );
      expect(
        deletedUser?.deletedAt,
        isNotNull,
        reason: 'User should be soft deleted',
      );

      clearCapturedSql();

      // Restore the user
      await Users.model.restore(
        where: (u) => u.id.eq(user.id),
      );

      expect(
        lastSql,
        containsSql('UPDATE'),
        reason: 'restore() should use UPDATE statement',
      );
      expect(
        lastSql,
        containsSql('deleted_at'),
        reason: 'restore() should update deleted_at column',
      );

      // Verify user is restored (found by default query)
      final restoredUser = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );
      expect(
        restoredUser,
        isNotNull,
        reason: 'Restored user should be found by default query',
      );
      expect(
        restoredUser?.deletedAt,
        isNull,
        reason: 'Restored user should have deletedAt set to null',
      );
    });
  });

  group('Instance destroy() Method', () {
    test('instance soft delete', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final user = await Users.model.create(
        CreateUsers(
          email: 'instance_destroy_$timestamp@example.com',
          firstName: 'Instance',
          lastName: 'Destroy',
        ),
      );

      expect(user.id, isNotNull, reason: 'User should be created');

      clearCapturedSql();

      // Soft delete using instance method
      await user.destroy();

      expect(
        lastSql,
        containsSql('UPDATE'),
        reason: 'Instance soft delete should use UPDATE statement',
      );

      // Verify user is soft deleted
      final findResult = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );
      expect(
        findResult,
        isNull,
        reason: 'Soft deleted user should not be found by default',
      );

      // Verify user exists with paranoid: false
      final findWithParanoid = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );
      expect(
        findWithParanoid,
        isNotNull,
        reason: 'Soft deleted user should be found with paranoid: false',
      );
    });

    test('instance hard delete with force: true', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final user = await Users.model.create(
        CreateUsers(
          email: 'instance_hard_$timestamp@example.com',
          firstName: 'Instance',
          lastName: 'Hard',
        ),
      );

      expect(user.id, isNotNull, reason: 'User should be created');

      clearCapturedSql();

      // Hard delete using instance method
      await user.destroy(force: true);

      expect(
        lastSql,
        containsSql('DELETE'),
        reason: 'Instance hard delete should use DELETE statement',
      );

      // Verify user is completely gone
      final findResult = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );
      expect(
        findResult,
        isNull,
        reason: 'Hard deleted user should not be found',
      );
    });
  });

  group('Instance restore() Method', () {
    test('instance restore after soft delete', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final user = await Users.model.create(
        CreateUsers(
          email: 'instance_restore_$timestamp@example.com',
          firstName: 'Instance',
          lastName: 'Restore',
        ),
      );

      // Soft delete the user
      await user.destroy();

      // Fetch the soft-deleted user
      final deletedUser = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );
      expect(
        deletedUser,
        isNotNull,
        reason: 'Soft deleted user should be found with paranoid: false',
      );
      expect(
        deletedUser?.deletedAt,
        isNotNull,
        reason: 'Soft deleted user should have deletedAt set',
      );

      clearCapturedSql();

      // Restore using instance method
      await deletedUser!.restore();

      expect(
        lastSql,
        containsSql('UPDATE'),
        reason: 'Instance restore should use UPDATE statement',
      );

      // Verify user is restored
      final restoredUser = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );
      expect(
        restoredUser,
        isNotNull,
        reason: 'Restored user should be found by default query',
      );
      expect(
        restoredUser?.deletedAt,
        isNull,
        reason: 'Restored user should have deletedAt set to null',
      );
    });
  });

  group('Sequelize.truncate() - Instance Method',
      skip: isSqlite ? 'SQLite does not support TRUNCATE with CASCADE' : null,
      () {
    test('sequelize truncate all tables', () async {
      // Create test data
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await Users.model.create(
        CreateUsers(
          email: 'seq_truncate_$timestamp@example.com',
          firstName: 'Seq',
          lastName: 'Truncate',
        ),
      );

      clearCapturedSql();

      // Truncate all tables
      await sequelize.truncate(cascade: true);

      expect(
        lastSql,
        containsSql('TRUNCATE'),
        reason: 'sequelize.truncate() should use TRUNCATE statement',
      );

      // Verify all records are removed
      final userCount = await Users.model.count();
      expect(
        userCount,
        equals(0),
        reason: 'All users should be removed after sequelize.truncate()',
      );
    });
  });

  group('Sequelize.destroyAll() - Instance Method', () {
    test('sequelize destroyAll removes all records', () async {
      // Create test data
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await Users.model.create(
        CreateUsers(
          email: 'seq_destroy_$timestamp@example.com',
          firstName: 'Seq',
          lastName: 'Destroy',
        ),
      );

      clearCapturedSql();

      // Destroy all records
      await sequelize.destroyAll(force: true);

      // Verify all records are removed
      final userCount = await Users.model.count();
      expect(
        userCount,
        equals(0),
        reason: 'All users should be removed after sequelize.destroyAll()',
      );
    });
  });

  group('Paranoid Queries', () {
    test('findAll excludes soft-deleted records by default', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create and soft delete a user
      final user = await Users.model.create(
        CreateUsers(
          email: 'paranoid_default_$timestamp@example.com',
          firstName: 'Paranoid',
          lastName: 'Default',
        ),
      );
      await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
      );

      clearCapturedSql();

      // Find all users - should exclude soft deleted
      final users = await Users.model.findAll(
        where: (u) => u.id.eq(user.id),
      );

      expect(
        users.length,
        equals(0),
        reason: 'findAll should exclude soft-deleted records by default',
      );
      expect(
        lastSql,
        containsSql('deleted_at IS NULL'),
        reason: 'Default query should filter by deleted_at IS NULL',
      );
    });

    test('findAll with paranoid: false includes soft-deleted records', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create and soft delete a user
      final user = await Users.model.create(
        CreateUsers(
          email: 'paranoid_false_$timestamp@example.com',
          firstName: 'Paranoid',
          lastName: 'False',
        ),
      );
      await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
      );

      clearCapturedSql();

      // Find all users with paranoid: false
      final users = await Users.model.findAll(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );

      expect(
        users.length,
        equals(1),
        reason: 'findAll with paranoid: false should include soft-deleted records',
      );
      expect(
        users.first.deletedAt,
        isNotNull,
        reason: 'Soft-deleted record should have deletedAt set',
      );
    });

    test('findOne excludes soft-deleted records by default', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create and soft delete a user
      final user = await Users.model.create(
        CreateUsers(
          email: 'findone_default_$timestamp@example.com',
          firstName: 'FindOne',
          lastName: 'Default',
        ),
      );
      await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
      );

      clearCapturedSql();

      // Find one user - should exclude soft deleted
      final foundUser = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );

      expect(
        foundUser,
        isNull,
        reason: 'findOne should exclude soft-deleted records by default',
      );
      expect(
        lastSql,
        containsSql('deleted_at IS NULL'),
        reason: 'Default query should filter by deleted_at IS NULL',
      );
    });

    test('findOne with paranoid: false includes soft-deleted records', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create and soft delete a user
      final user = await Users.model.create(
        CreateUsers(
          email: 'findone_paranoid_$timestamp@example.com',
          firstName: 'FindOne',
          lastName: 'Paranoid',
        ),
      );
      await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
      );

      clearCapturedSql();

      // Find one user with paranoid: false
      final foundUser = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );

      expect(
        foundUser,
        isNotNull,
        reason: 'findOne with paranoid: false should include soft-deleted records',
      );
      expect(
        foundUser?.deletedAt,
        isNotNull,
        reason: 'Soft-deleted record should have deletedAt set',
      );
    });
  });

  // Note: Paranoid Includes tests are skipped because the Post model
  // doesn't have a deletedAt column and has timestamps: false.
  // To properly test paranoid includes, both the parent and child models
  // need to support paranoid mode (soft deletes).
  //
  // The IncludeBuilder correctly supports the paranoid: false option,
  // but it requires the associated model to have paranoid enabled.
  group('Paranoid Includes', () {
    test('include paranoid option is passed correctly', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create user with post
      final user = await Users.model.create(
        CreateUsers(
          email: 'include_paranoid_$timestamp@example.com',
          firstName: 'Include',
          lastName: 'Paranoid',
          post: CreatePost(
            title: 'paranoid_post_$timestamp',
            content: 'Paranoid Content',
            views: 10,
          ),
        ),
      );

      expect(user.post, isNotNull, reason: 'User should have a post');

      clearCapturedSql();

      // Fetch user with post include using paranoid: false option
      // This verifies the option is correctly passed through the bridge
      final userWithPost = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        include: (i) => [i.post(paranoid: false)],
      );

      expect(
        userWithPost?.post,
        isNotNull,
        reason: 'User should have post included',
      );
    });
  });

  group('Combined Destroy/Restore Workflow', () {
    test('complete soft delete and restore workflow', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 1. Create user
      final user = await Users.model.create(
        CreateUsers(
          email: 'workflow_$timestamp@example.com',
          firstName: 'Workflow',
          lastName: 'Test',
        ),
      );
      expect(user.id, isNotNull, reason: 'User should be created');

      // 2. Soft delete
      await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
      );

      // 3. Verify soft deleted
      final afterDelete = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );
      expect(afterDelete, isNull, reason: 'User should not be found after soft delete');

      // 4. Verify exists with paranoid: false
      final withParanoid = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );
      expect(withParanoid, isNotNull, reason: 'User should exist with paranoid: false');
      expect(withParanoid?.deletedAt, isNotNull, reason: 'deletedAt should be set');

      // 5. Restore
      await Users.model.restore(
        where: (u) => u.id.eq(user.id),
      );

      // 6. Verify restored
      final afterRestore = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
      );
      expect(afterRestore, isNotNull, reason: 'User should be found after restore');
      expect(afterRestore?.deletedAt, isNull, reason: 'deletedAt should be null after restore');

      // 7. Hard delete
      final hardDeleteCount = await Users.model.destroy(
        where: (u) => u.id.eq(user.id),
        force: true,
      );
      expect(hardDeleteCount, equals(1), reason: 'Hard delete should affect 1 row');

      // 8. Verify completely gone
      final afterHardDelete = await Users.model.findOne(
        where: (u) => u.id.eq(user.id),
        paranoid: false,
      );
      expect(afterHardDelete, isNull, reason: 'User should be completely gone after hard delete');
    });
  });
}
