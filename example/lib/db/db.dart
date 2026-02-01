import 'package:sequelize_dart_example/db/models/post.model.dart';
import 'package:sequelize_dart_example/db/models/post_details.model.dart';
import 'package:sequelize_dart_example/db/models/users.model.dart';

import 'package:sequelize_dart/sequelize_dart.dart';

/// Registry class for accessing all models
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
}
