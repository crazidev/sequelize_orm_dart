// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:sequelize_dart_example/utils/measureQuery.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // Test create functionality with Create class
  print('\n=== Testing CREATE ===');
  final newUser = await measureQuery(
    'create',
    () => Users.instance.create(
      $UsersCreate(
        email:
            'test_create_${DateTime.now().millisecondsSinceEpoch}@example.com',
        firstName: 'Test',
        lastName: 'User',
        posts: [
          // $PostCreate(
          //   title: 'test_post_${DateTime.now().millisecondsSinceEpoch}',
          //   content: 'Test Content',
          //   views: 1,
          // ),
          // $PostCreate(
          //   title: 'test_post_${DateTime.now().millisecondsSinceEpoch}',
          //   content: 'Test Content',
          //   views: 2,
          // ),
          // $PostCreate(
          //   title: 'test_post_${DateTime.now().millisecondsSinceEpoch}',
          //   content: 'Test Content',
          //   views: 3,
          // ),
        ],
      ),
    ),
  );
  print('Created user: ${newUser.email} (ID: ${newUser.id})');

  // Test increment functionality
  final users = await measureQuery(
    'findAll',
    () => Users.instance.findAll(
      limit: 1,
      where: (user) => user.id.eq(newUser.id),
      include: (includeUsers) => [includeUsers.post()],
    ),
  );

  final firstUser = users.first;

  final updatedPost = await firstUser.post?.increment(views: 1);
  print('Post views after increment: ${firstUser.post?.views}');

  // Test update functionality with named parameters
  print('\n=== Testing UPDATE ===');
  final updateTimestamp = DateTime.now().millisecondsSinceEpoch;
  final updatedEmail = 'updated_$updateTimestamp@example.com';
  final affectedRows = await measureQuery(
    'update',
    () => Users.instance.update(
      email: updatedEmail,
      firstName: 'Updated',
      lastName: 'Name',
      where: (user) => user.id.eq(newUser.id),
    ),
  );
  print('Updated $affectedRows row(s)');

  // Verify the update by fetching the user again
  final updatedUsers = await measureQuery(
    'findOne',
    () => Users.instance.findOne(
      where: (user) => user.id.eq(newUser.id),
    ),
  );

  if (updatedUsers != null) {
    print(
      'Updated user: ${updatedUsers.email} (${updatedUsers.firstName} ${updatedUsers.lastName})',
    );
    print(
      'Verification: Email matches = ${updatedUsers.email == updatedEmail}',
    );
  } else {
    print('ERROR: User not found after update!');
  }

  // Test save functionality
  print('\n=== Testing SAVE ===');
  final userToSave = await measureQuery(
    'findOne',
    () => Users.instance.findOne(
      where: (user) => user.id.eq(newUser.id),
    ),
  );

  if (userToSave != null) {
    final originalEmail = userToSave.email;
    final saveTimestamp = DateTime.now().millisecondsSinceEpoch;
    final savedEmail = 'saved_$saveTimestamp@example.com';

    // Modify fields
    userToSave.email = savedEmail;
    userToSave.firstName = 'Saved';
    userToSave.lastName = 'User';

    final savedRows = await measureQuery(
      'save',
      () => userToSave.save(),
    );
    print('Saved $savedRows row(s)');

    // Verify the save by reloading
    await userToSave.reload();
    print(
      'After save - Email: ${userToSave.email}, Name: ${userToSave.firstName} ${userToSave.lastName}',
    );
    print('Verification: Email changed = ${userToSave.email != originalEmail}');
    print('Verification: Email matches = ${userToSave.email == savedEmail}');
  } else {
    print('ERROR: User not found for save test!');
  }
}
