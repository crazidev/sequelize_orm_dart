import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

/// Tests for create, update, reload, and save methods
///
/// These tests verify that create, update, reload, and save methods work correctly
/// for both instance and static implementations, including with associations.
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

  group('Create Method - Static Implementation', () {
    test('create user with single post and increment post views', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_create_$timestamp@example.com',
          firstName: 'Test',
          lastName: 'User',
          post: $PostCreate(
            title: 'test_post_$timestamp',
            content: 'Test Content',
            views: 1,
          ),
        ),
      );

      expect(
        newUser,
        isA<$UsersValues>(),
        reason: 'create() should return a UsersValues instance',
      );
      expect(newUser.id, isNotNull, reason: 'User should have an ID');
      expect(newUser.post, isNotNull, reason: 'User should have a post');
      expect(newUser.post?.id, isNotNull, reason: 'Post should have an ID');

      // Note: userId might be null in Dart instance but set in DB
      // Verify by fetching from database
      final fetchedPost = await Post.instance.findOne(
        where: (post) => post.id.eq(newUser.post?.id),
      );
      expect(
        fetchedPost?.userId,
        equals(newUser.id),
        reason: 'Post should have user_id set to user id in database',
      );
      expect(
        newUser.post?.views,
        equals(1),
        reason: 'Post should have initial views of 1',
      );

      clearCapturedSql();

      // Increment post views using instance method
      final updatedPost = await newUser.post?.increment(views: 5);

      expect(
        updatedPost,
        isA<$PostValues?>(),
        reason: 'increment() should return PostValues instance',
      );
      expect(
        newUser.post?.views,
        equals(6),
        reason: 'Post views should be incremented to 6',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
      expect(
        lastSql,
        contains('views'),
        reason: 'SQL should contain views field',
      );
    });

    test(
      'create user with multiple posts and increment all post views',
      () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newUser = await Users.instance.create(
          $UsersCreate(
            email: 'test_multi_$timestamp@example.com',
            firstName: 'Multi',
            lastName: 'Post',
            posts: [
              $PostCreate(
                title: 'post_1_$timestamp',
                content: 'Content 1',
                views: 10,
              ),
              $PostCreate(
                title: 'post_2_$timestamp',
                content: 'Content 2',
                views: 20,
              ),
            ],
          ),
        );

        expect(
          newUser,
          isA<$UsersValues>(),
          reason: 'create() should return a UsersValues instance',
        );
        expect(newUser.id, isNotNull, reason: 'User should have an ID');
        expect(
          newUser.posts,
          isNotNull,
          reason: 'User should have posts',
        );
        expect(
          newUser.posts?.length,
          equals(2),
          reason: 'User should have 2 posts',
        );

        // Verify all posts have user_id set in database
        for (final post in newUser.posts!) {
          final fetchedPost = await Post.instance.findOne(
            where: (p) => p.id.eq(post.id),
          );
          expect(
            fetchedPost?.userId,
            equals(newUser.id),
            reason: 'Post should have user_id set to user id in database',
          );
        }

        clearCapturedSql();

        // Increment views for all posts using static method
        for (final post in newUser.posts!) {
          final updatedPost = await Post.instance.increment(
            views: 3,
            where: (p) => p.id.eq(post.id),
          );

          expect(
            updatedPost,
            isA<List<$PostValues>>(),
            reason: 'increment() should return list of PostValues',
          );
          expect(
            updatedPost.isNotEmpty,
            isTrue,
            reason: 'increment() should return at least one result',
          );
        }

        expect(
          lastSql,
          contains('UPDATE'),
          reason: 'SQL should contain UPDATE statement',
        );
      },
    );

    test(
      'create user with post, modify and save post, then save user',
      () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newUser = await Users.instance.create(
          $UsersCreate(
            email: 'test_save_$timestamp@example.com',
            firstName: 'Save',
            lastName: 'Test',
            post: $PostCreate(
              title: 'save_post_$timestamp',
              content: 'Save Content',
              views: 5,
            ),
          ),
        );

        expect(newUser.id, isNotNull, reason: 'User should have an ID');
        expect(newUser.post, isNotNull, reason: 'User should have a post');

        // Verify user_id is set in database
        final fetchedPost = await Post.instance.findOne(
          where: (post) => post.id.eq(newUser.post?.id),
        );
        expect(
          fetchedPost?.userId,
          equals(newUser.id),
          reason: 'Post should have user_id set in database',
        );

        final originalViews = newUser.post?.views ?? 0;

        // Modify post views
        newUser.post?.views = 10;

        clearCapturedSql();

        // Save the post
        final postSaveResult = await newUser.post?.save();

        expect(
          postSaveResult,
          equals(1),
          reason: 'save() should return 1 for successful save',
        );
        expect(
          newUser.post?.views,
          equals(10),
          reason: 'Post views should be updated to 10',
        );
        expect(
          lastSql,
          contains('UPDATE'),
          reason: 'SQL should contain UPDATE statement for post',
        );

        clearCapturedSql();

        // Modify user and save
        final originalEmail = newUser.email;
        newUser.firstName = 'Updated';
        newUser.lastName = 'Name';

        final userSaveResult = await newUser.save();

        expect(
          userSaveResult,
          equals(1),
          reason: 'save() should return 1 for successful save',
        );
        expect(
          newUser.firstName,
          equals('Updated'),
          reason: 'User firstName should be updated',
        );
        expect(
          newUser.lastName,
          equals('Name'),
          reason: 'User lastName should be updated',
        );
        expect(
          lastSql,
          contains('UPDATE'),
          reason: 'SQL should contain UPDATE statement for user',
        );

        // Verify post still has correct user_id after user save
        final postAfterUserSave = await Post.instance.findOne(
          where: (post) => post.id.eq(newUser.post?.id),
        );
        expect(
          postAfterUserSave?.userId,
          equals(newUser.id),
          reason: 'Post user_id should still be correct after user save',
        );
      },
    );

    test('verify associated post has user_id after create', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_fk_$timestamp@example.com',
          firstName: 'FK',
          lastName: 'Test',
          post: $PostCreate(
            title: 'fk_post_$timestamp',
            content: 'FK Content',
            views: 0,
          ),
        ),
      );

      expect(newUser.id, isNotNull, reason: 'User should have an ID');
      expect(newUser.post, isNotNull, reason: 'User should have a post');

      // Verify user_id is set in database (may be null in Dart instance)
      final verifyPost = await Post.instance.findOne(
        where: (post) => post.id.eq(newUser.post?.id),
      );
      expect(
        verifyPost?.userId,
        isNotNull,
        reason: 'Post should have user_id in database',
      );
      expect(
        verifyPost?.userId,
        equals(newUser.id),
        reason: 'Post user_id should equal user id in database',
      );

      // Already verified above, no need to verify again
    });
  });

  group('Update Method - Static Implementation', () {
    test('static update() with named parameters', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_update_$timestamp@example.com',
          firstName: 'Update',
          lastName: 'Test',
        ),
      );

      clearCapturedSql();

      final affectedRows = await Users.instance.update(
        email: 'updated_$timestamp@example.com',
        firstName: 'Updated',
        lastName: 'Name',
        where: (user) => user.id.eq(newUser.id),
      );

      expect(
        affectedRows,
        equals(1),
        reason: 'update() should return 1 affected row',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement',
      );

      // Verify the update
      clearCapturedSql();

      final updatedUser = await Users.instance.findOne(
        where: (user) => user.id.eq(newUser.id),
      );

      expect(
        updatedUser,
        isNotNull,
        reason: 'Updated user should be found',
      );
      expect(
        updatedUser?.email,
        equals('updated_$timestamp@example.com'),
        reason: 'User email should be updated',
      );
      expect(
        updatedUser?.firstName,
        equals('Updated'),
        reason: 'User firstName should be updated',
      );
    });

    test('static update() with where clause filters correctly', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final user1 = await Users.instance.create(
        $UsersCreate(
          email: 'user1_$timestamp@example.com',
          firstName: 'User1',
          lastName: 'Test',
        ),
      );
      final user2 = await Users.instance.create(
        $UsersCreate(
          email: 'user2_$timestamp@example.com',
          firstName: 'User2',
          lastName: 'Test',
        ),
      );

      clearCapturedSql();

      final affectedRows = await Users.instance.update(
        lastName: 'Updated',
        where: (user) => user.id.eq(user1.id),
      );

      expect(
        affectedRows,
        equals(1),
        reason: 'update() should affect only one row',
      );

      // Verify only user1 was updated
      final fetchedUser1 = await Users.instance.findOne(
        where: (user) => user.id.eq(user1.id),
      );
      final fetchedUser2 = await Users.instance.findOne(
        where: (user) => user.id.eq(user2.id),
      );

      expect(
        fetchedUser1?.lastName,
        equals('Updated'),
        reason: 'User1 lastName should be updated',
      );
      expect(
        fetchedUser2?.lastName,
        equals('Test'),
        reason: 'User2 lastName should not be updated',
      );
    });
  });

  group('Update Method - Instance Implementation', () {
    test('instance update() method', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_instance_update_$timestamp@example.com',
          firstName: 'Instance',
          lastName: 'Update',
        ),
      );

      clearCapturedSql();

      final affectedRows = await newUser.update({
        'email': 'instance_updated_$timestamp@example.com',
        'first_name': 'InstanceUpdated',
      });

      expect(
        affectedRows,
        equals(1),
        reason: 'instance update() should return 1 affected row',
      );

      // Instance update() calls reload() which does a SELECT
      // The actual UPDATE happens in the static method
      expect(
        lastSql,
        contains('SELECT'),
        reason: 'SQL should contain SELECT statement from reload',
      );

      // Reload to verify changes
      await newUser.reload();

      expect(
        newUser.email,
        equals('instance_updated_$timestamp@example.com'),
        reason: 'User email should be updated after reload',
      );
      expect(
        newUser.firstName,
        equals('InstanceUpdated'),
        reason: 'User firstName should be updated after reload',
      );
    });
  });

  group('Reload Method', () {
    test('reload() updates instance with latest database values', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_reload_$timestamp@example.com',
          firstName: 'Reload',
          lastName: 'Test',
        ),
      );

      // Modify instance locally
      newUser.firstName = 'Modified';
      newUser.lastName = 'Locally';

      clearCapturedSql();

      // Reload from database
      final reloaded = await newUser.reload();

      expect(
        reloaded,
        isNotNull,
        reason: 'reload() should return the instance',
      );
      expect(
        reloaded,
        same(newUser),
        reason: 'reload() should return the same instance',
      );
      expect(
        newUser.firstName,
        equals('Reload'),
        reason: 'firstName should be reloaded from database',
      );
      expect(
        newUser.lastName,
        equals('Test'),
        reason: 'lastName should be reloaded from database',
      );
      expect(
        lastSql,
        contains('SELECT'),
        reason: 'SQL should contain SELECT statement',
      );
    });

    test('reload() with associations preserves includes', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_reload_include_$timestamp@example.com',
          firstName: 'Reload',
          lastName: 'Include',
          post: $PostCreate(
            title: 'reload_post_$timestamp',
            content: 'Reload Content',
            views: 100,
          ),
        ),
      );

      // Fetch with include
      final userWithPost = await Users.instance.findOne(
        where: (user) => user.id.eq(newUser.id),
        include: (includeUsers) => [includeUsers.post()],
      );

      expect(
        userWithPost?.post,
        isNotNull,
        reason: 'User should have post included',
      );

      // Modify post views in database using static update
      await Post.instance.update(
        views: 200,
        where: (post) => post.id.eq(userWithPost?.post?.id),
      );

      clearCapturedSql();

      // Reload user (should preserve original query with include)
      final reloaded = await userWithPost?.reload();

      expect(
        reloaded,
        isNotNull,
        reason: 'reload() should return the instance',
      );
      expect(
        userWithPost?.post?.views,
        equals(200),
        reason: 'Post views should be reloaded from database',
      );
    });

    test('reload() throws error when instance has no primary key', () async {
      final newUser = $UsersValues(
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
      );

      expect(
        () => newUser.reload(),
        throwsA(isA<StateError>()),
        reason: 'reload() should throw StateError when no primary key',
      );
    });
  });

  group('Save Method - Instance Implementation', () {
    test('save() creates new record when no primary key', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = $UsersValues(
        email: 'test_save_new_$timestamp@example.com',
        firstName: 'Save',
        lastName: 'New',
      );

      clearCapturedSql();

      final saveResult = await newUser.save();

      expect(
        saveResult,
        equals(1),
        reason: 'save() should return 1 for successful save',
      );
      expect(
        newUser.id,
        isNotNull,
        reason: 'User should have an ID after save',
      );
      expect(
        lastSql,
        contains('INSERT'),
        reason: 'SQL should contain INSERT statement for new record',
      );
    });

    test('save() updates existing record when primary key exists', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_save_update_$timestamp@example.com',
          firstName: 'Save',
          lastName: 'Update',
        ),
      );

      // Modify instance
      newUser.firstName = 'Updated';
      newUser.lastName = 'Name';

      clearCapturedSql();

      final saveResult = await newUser.save();

      expect(
        saveResult,
        equals(1),
        reason: 'save() should return 1 for successful save',
      );
      expect(
        lastSql,
        contains('UPDATE'),
        reason: 'SQL should contain UPDATE statement for existing record',
      );

      // Verify changes persisted
      await newUser.reload();

      expect(
        newUser.firstName,
        equals('Updated'),
        reason: 'firstName should be updated',
      );
      expect(
        newUser.lastName,
        equals('Name'),
        reason: 'lastName should be updated',
      );
    });

    test(
      'save() preserves foreign keys when saving associated instances',
      () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newUser = await Users.instance.create(
          $UsersCreate(
            email: 'test_save_fk_$timestamp@example.com',
            firstName: 'Save',
            lastName: 'FK',
            post: $PostCreate(
              title: 'save_fk_post_$timestamp',
              content: 'Save FK Content',
              views: 50,
            ),
          ),
        );

        // Verify user_id is set in database
        final initialPost = await Post.instance.findOne(
          where: (post) => post.id.eq(newUser.post?.id),
        );
        expect(
          initialPost?.userId,
          equals(newUser.id),
          reason: 'Post should have user_id set initially in database',
        );

        // Ensure post has previousDataValues set (may need reload)
        if (newUser.post?.previousDataValues == null) {
          await newUser.post?.reload();
        }

        // Modify post views
        newUser.post?.views = 100;

        clearCapturedSql();

        // Save post (should preserve user_id)
        final postSaveResult = await newUser.post?.save();

        expect(
          postSaveResult,
          equals(1),
          reason: 'Post save() should return 1',
        );
        // Verify post user_id is preserved in database
        final postAfterSave = await Post.instance.findOne(
          where: (post) => post.id.eq(newUser.post?.id),
        );
        expect(
          postAfterSave?.userId,
          equals(newUser.id),
          reason: 'Post user_id should be preserved after save',
        );
        expect(
          newUser.post?.views,
          equals(100),
          reason: 'Post views should be updated',
        );
        // Save may do a reload first if previousDataValues was null
        // So we check for either UPDATE or SELECT (from reload)
        expect(
          lastSql,
          anyOf(contains('UPDATE'), contains('SELECT')),
          reason: 'SQL should contain UPDATE or SELECT statement',
        );
      },
    );

    test('save() with fields parameter saves only specified fields', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_save_fields_$timestamp@example.com',
          firstName: 'Save',
          lastName: 'Fields',
        ),
      );

      final originalLastName = newUser.lastName;

      // Ensure previousDataValues is set (should be set after create)
      // If not, reload to set it
      if (newUser.previousDataValues == null) {
        await newUser.reload();
      }

      // Verify previousDataValues is now set
      expect(
        newUser.previousDataValues,
        isNotNull,
        reason: 'previousDataValues should be set after create/reload',
      );

      // Modify multiple fields
      newUser.firstName = 'Updated';
      newUser.lastName = 'Changed';

      clearCapturedSql();

      // Save only firstName
      final saveResult = await newUser.save(fields: ['first_name']);

      expect(
        saveResult,
        equals(1),
        reason: 'save() should return 1',
      );

      // Reload to verify
      await newUser.reload();

      expect(
        newUser.firstName,
        equals('Updated'),
        reason: 'firstName should be updated',
      );
      expect(
        newUser.lastName,
        equals(originalLastName),
        reason: 'lastName should not be updated (not in fields list)',
      );
    });
  });

  group('Combined Operations', () {
    test('create, update, reload, and save workflow', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 1. Create
      final newUser = await Users.instance.create(
        $UsersCreate(
          email: 'test_workflow_$timestamp@example.com',
          firstName: 'Workflow',
          lastName: 'Test',
          post: $PostCreate(
            title: 'workflow_post_$timestamp',
            content: 'Workflow Content',
            views: 1,
          ),
        ),
      );

      expect(newUser.id, isNotNull, reason: 'User should be created');
      expect(newUser.post, isNotNull, reason: 'Post should be created');

      // 2. Update using static method
      clearCapturedSql();

      final updateResult = await Users.instance.update(
        firstName: 'Updated',
        where: (user) => user.id.eq(newUser.id),
      );

      expect(
        updateResult,
        equals(1),
        reason: 'Update should affect 1 row',
      );

      // 3. Reload to get updated values
      clearCapturedSql();

      await newUser.reload();

      expect(
        newUser.firstName,
        equals('Updated'),
        reason: 'User should be reloaded with updated values',
      );

      // 4. Modify and save
      newUser.lastName = 'Saved';

      clearCapturedSql();

      final saveResult = await newUser.save();

      expect(
        saveResult,
        equals(1),
        reason: 'Save should succeed',
      );

      // 5. Verify final state
      await newUser.reload();

      expect(
        newUser.firstName,
        equals('Updated'),
        reason: 'firstName should remain updated',
      );
      expect(
        newUser.lastName,
        equals('Saved'),
        reason: 'lastName should be saved',
      );
      // Verify post user_id is still correct in database
      final finalPost = await Post.instance.findOne(
        where: (post) => post.id.eq(newUser.post?.id),
      );
      expect(
        finalPost?.userId,
        equals(newUser.id),
        reason: 'Post user_id should still be correct in database',
      );
    });
  });
}
