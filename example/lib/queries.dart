// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:sequelize_dart_example/utils/measureQuery.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  final users1 = await measureQuery(
    'Find users with posts (basic include)',
    () => Users.instance.findAll(
      (users) => Query(
        where: and([users.id.eq(1)]),
        include: [
          users.posts.include(),
        ],
      ),
    ),
  );
  for (final user in users1) {
    print('User: ${user.toJson()}');
  }

  // final post1 = await measureQuery(
  //   'Find Post with postDetails (basic include)',
  //   () => Post.instance.findAll(
  //     (post) => Query(
  //       where: and([post.id.eq(1)]),
  //       include: [
  //         post.postDetails.include(
  //           attributes: QueryAttributes(columns: [const Column('id')]),
  //         ),
  //       ],
  //     ),
  //   ),
  // );
  // for (final post in post1) {
  //   print('Post: ${post.toJson()}');
  // }
}
