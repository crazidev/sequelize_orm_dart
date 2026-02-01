import 'package:sequelize_dart_example/db/seeders/seed_user_post.seeder.dart';

import 'package:sequelize_dart/sequelize_dart.dart';

/// Registry class for accessing all seeders
class Seeders {
  Seeders._();

  static List<SequelizeSeeding> all() {
    return [
      SeedUserPost(),
    ];
  }
}
