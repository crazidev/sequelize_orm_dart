// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:sequelize_dart_example/utils/measureQuery.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // Test increment functionality
  final posts = await measureQuery('findAll', () => Post.instance.findAll());

  if (posts.isNotEmpty) {
    final firstPost = posts.first;
    print('Before increment - Post ${firstPost.id} views: ${firstPost.views}');

    // Increment views by 1
    final updatedPost = await Post.instance.increment(
      views: 1,
      where: (post) => and([
        post.id.lessThan(5),
      ]),
    );

    print(
      'After increment - Post views updated ${updatedPost.firstOrNull?.toJson()}',
    );
  }
}
