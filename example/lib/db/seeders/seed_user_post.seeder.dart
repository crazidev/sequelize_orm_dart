import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/post_details.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';

class SeedUserPost extends SequelizeSeeding<CreatePost> {
  @override
  int get order => 10;

  @override
  Future<PostValues> Function(CreatePost createData) get create =>
      Db.post.create;

  @override
  List<CreatePost> get seedData => [
        ...List.generate(
          2,
          (index) => CreatePost(
            title: 'Seeded post $index',
            content: 'Created by SeedUserPost',
            views: index,
            user: CreateUsers(
              email: 'seed$index@example.com',
              firstName: 'Seed $index',
              lastName: 'User',
              status: UsersStatus.active,
              phoneNumber: SequelizeBigInt('${9000000000000 + index}'),
              tags: ['dart', 'flutter', 'sequelize'],
              scores: [index * 10, index * 20, index * 30],
              metadata: {
                'role': 'user',
                'isAdmin': index % 2 == 0,
                'level': 'beginner',
                'address': {'city': 'Berlin', 'country': 'Germany'},
                'age': index,
              },
            ),
            postDetails: CreatePostDetails(
              likes: index,
              metadata: {
                'source': 'seeder',
                'tags': ['dart', 'sequelize', 'database'],
                'category': 'tutorial',
                'author': 'SeedUserPost',
              },
            ),
          ),
        ),
      ];
}
