import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/db.dart';
import 'package:sequelize_dart_example/db/models/users.model.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  print('\n=== Testing Destroy, Truncate, Restore Operations ===\n');

  // 1. Create a test user
  print('1. Creating a test user...');
  final user = await Db.users.create(
    CreateUsers(
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    ),
  );
  print('   Created user: ${user.id} - ${user.email}');

  // 2. Test static Model.destroy() with where clause (soft delete)
  print('\n2. Testing static Model.destroy() (soft delete)...');
  final destroyedCount = await Db.users.destroy(
    where: (u) => u.id.eq(user.id),
  );
  print('   Destroyed (soft deleted) $destroyedCount user(s)');

  // // 3. Test findAll without paranoid - should NOT find soft-deleted records
  print('\n3. Testing findAll (default - excludes soft-deleted)...');
  final usersExcludingSoftDeleted = await Db.users.findAll(
    where: (u) => u.id.eq(user.id),
  );
  print(
    '   Found ${usersExcludingSoftDeleted.length} user(s) (should be 0)',
  );

  // 4. Test findAll with paranoid: false - should find soft-deleted records
  print('\n4. Testing findAll with paranoid: false...');
  final usersIncludingSoftDeleted = await Db.users.findAll(
    where: (u) => u.id.eq(user.id),
    paranoid: false,
  );
  print(
    '   Found ${usersIncludingSoftDeleted.length} user(s) (should be 1)',
  );
  if (usersIncludingSoftDeleted.isNotEmpty) {
    print(
      '   User deletedAt: ${usersIncludingSoftDeleted.first.deletedAt}',
    );
  }

  // 5. Test findOne with paranoid: false
  print('\n5. Testing findOne with paranoid: false...');
  final softDeletedUser = await Db.users.findOne(
    where: (u) => u.id.eq(user.id),
    paranoid: false,
  );
  print(
    '   Found user: ${softDeletedUser?.id} (deletedAt: ${softDeletedUser?.deletedAt})',
  );

  // 6. Test static Model.restore()
  print('\n6. Testing static Model.restore()...');
  await Db.users.restore(
    where: (u) => u.id.eq(user.id),
  );
  print('   Restored user');

  // 7. Verify user is restored (deletedAt should be null)
  print('\n7. Verifying user is restored...');
  final restoredUser = await Db.users.findOne(
    where: (u) => u.id.eq(user.id),
  );
  print(
    '   Found user: ${restoredUser?.id} (deletedAt: ${restoredUser?.deletedAt})',
  );

  // 8. Test instance destroy() method
  print('\n8. Testing instance destroy() method...');
  if (restoredUser != null) {
    await restoredUser.destroy();
    print('   Instance soft-deleted');

    // Verify it's soft-deleted
    final afterInstanceDestroy = await Db.users.findOne(
      where: (u) => u.id.eq(user.id),
      paranoid: false,
    );
    print('   Verified deletedAt: ${afterInstanceDestroy?.deletedAt}');
  }

  // 9. Test instance restore() method
  print('\n9. Testing instance restore() method...');
  final softDeletedUserForRestore = await Db.users.findOne(
    where: (u) => u.id.eq(user.id),
    paranoid: false,
  );
  if (softDeletedUserForRestore != null) {
    await softDeletedUserForRestore.restore();
    print('   Instance restored');
    print('   deletedAt after restore: ${softDeletedUserForRestore.deletedAt}');
  }

  // 10. Test destroy with force: true (hard delete)
  print('\n10. Testing destroy with force: true (hard delete)...');
  final hardDeletedCount = await Db.users.destroy(
    where: (u) => u.id.eq(user.id),
    force: true,
  );
  print('   Hard deleted $hardDeletedCount user(s)');

  // 11. Verify user is completely gone (even with paranoid: false)
  print('\n11. Verifying user is completely gone...');
  final fullyDeletedUser = await Db.users.findOne(
    where: (u) => u.id.eq(user.id),
    paranoid: false,
  );
  print('   Found user: ${fullyDeletedUser?.id ?? "null"} (should be null)');

  // 12. Test Model.truncate() (commented out - use with caution)
  // print('\n12. Testing Model.truncate()...');
  // await Db.users.truncate();
  // print('   Table truncated');

  print('\n=== All Tests Completed ===\n');
}
