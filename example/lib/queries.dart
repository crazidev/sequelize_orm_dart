// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:sequelize_dart_example/utils/measureQuery.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  final includePost = IncludeBuilder<Post>(
    model: Post.instance,
    association: 'posts',
    where: (post) => and([
      const Column('id').eq(3),
    ]),
  );

  print(includePost.toJson());

  final users1 = await measureQuery(
    'Find users with posts (basic include)',
    () => Users.instance.findAll(
      where: (users) => and([
        users.id.eq(1),
      ]),
      include: (includeUser) => [
        includeUser.post().copyWith(),
        includePost.copyWith(
          attributes: QueryAttributes(
            columns: [const Column('id'), const Column('title')],
          ),
        ),
      ],
      order: [],
    ),
  );
  for (final user in users1) {
    print('User: ${user.toJson()}');
  }
}
