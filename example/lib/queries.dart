import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  final user = await Db.users.findOne(
    where: (users) => or([
      // users.metadata.key('isAdmin').eq(true),
      users.metadata.key('role').unquote().substring('user'),
      // users.scores.at(0).unquote().gt(1),
      // users.tags.contains(['dart', 'flutter']),
    ]),
  );

  print(user?.toJson());
}
