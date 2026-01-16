import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:sequelize_dart_example/models/post_details.model.dart';
import 'package:sequelize_dart_example/models/users.model.dart';

import 'package:sequelize_dart/sequelize_dart.dart';

/// Registry class for accessing all models
class Db {
  Db._();

  /// Returns the Post model instance
  static $Post get post => $Post();

  /// Returns the PostDetails model instance
  static $PostDetails get postDetails => $PostDetails();

  /// Returns the Users model instance
  static $Users get users => $Users();

  /// Returns a list of all model instances
  static List<Model> allModels() {
    return [
      Db.post,
      Db.postDetails,
      Db.users,
    ];
  }
}
