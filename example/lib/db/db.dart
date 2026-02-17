import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/post_details.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:sequelize_orm_example/db/seeders/seed_user_post.seeder.dart';

import 'package:sequelize_orm/sequelize_orm.dart';

/// Registry class for accessing all models and seeders
class Db {
  Db._();

  /// Returns the Post model instance
  static PostModel get post => PostModel();

  /// Returns the PostDetails model instance
  static PostDetailsModel get postDetails => PostDetailsModel();

  /// Returns the Users model instance
  static UsersModel get users => UsersModel();

  /// Returns a list of all model instances
  static List<Model> allModels() {
    return [
      Db.post,
      Db.postDetails,
      Db.users,
    ];
  }

  /// Returns a list of all seeders
  static List<SequelizeSeeding> allSeeders() {
    return [
      SeedUserPost(),
    ];
  }
}
