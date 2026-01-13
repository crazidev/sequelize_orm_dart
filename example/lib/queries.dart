// ignore_for_file: avoid_print

import 'package:sequelize_dart_example/models/post.model.dart';
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
        post: $PostCreate(
          title: 'test_post_${DateTime.now().millisecondsSinceEpoch}',
          content: 'Test Content',
          views: 1,
        ),
      ),
    ),
  );
}
