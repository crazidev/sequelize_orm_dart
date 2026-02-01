import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/db.dart';
import 'package:sequelize_dart_example/db/models/post.model.dart';
import 'package:sequelize_dart_example/db/models/post_details.model.dart';
import 'package:sequelize_dart_example/db/models/users.model.dart';

class SeedUserPost extends SequelizeSeeding<CreatePost> {
  @override
  int get order => 10;

  @override
  Future<PostValues> Function(CreatePost createData) get create =>
      Db.post.create;

  @override
  List<CreatePost> get seedData => [
    ...List.generate(
      100,
      (index) => CreatePost(
        title: 'Seeded post $index',
        content: 'Created by SeedUserPost',
        views: index,
        user: CreateUsers(
          email: 'seed$index@example.com',
          firstName: 'Seed $index',
          lastName: 'User',
        ),
        postDetails: CreatePostDetails(
          likes: index,
          metadata: {'source': 'seeder'},
        ),
      ),
    ),
  ];
}
