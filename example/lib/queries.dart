import 'package:sequelize_dart_example/db/models/db.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // 1) Create PostDetails and nested Post via BelongsTo include
  // final details = await Db.postDetails.create(
  //   CreatePostDetails(
  //     likes: 1,
  //     metadata: {'source': 'example'},
  //     post: CreatePost(
  //       title: 'BelongsTo created post',
  //       content: 'Created via CreatePostDetails.post',
  //       user: CreateUsers(
  //         email: 'test@example.com',
  //         firstName: 'Test',
  //         lastName: 'User',
  //       ),
  //     ),
  //   ),
  // );

  final allUsersCount = await Db.users.count();
  print('All users count: $allUsersCount');
  // print('postDetails with include(post): ${details.toJson()}');
}
