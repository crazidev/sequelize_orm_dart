// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:sequelize_dart_example/utils/measureQuery.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // Test increment functionality
  final users = await measureQuery(
    'findAll',
    () => Users.instance.findAll(
      limit: 1,
      include: (includeUsers) => [
        includeUsers.post(
          where: (post) => post.views.greaterThan(0),
        ),
      ],
    ),
  );

  final firstUser = users.first;
  print('${firstUser.firstName} post view ${firstUser.post?.views}');
  await firstUser.post?.increment(views: 1);
  print('${firstUser.firstName} post view is ${firstUser.post?.views}');
}
