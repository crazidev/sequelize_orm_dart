import 'package:sequelize_orm_example/db/db.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  // JSON path query: find user where metadata.role contains 'user'
  final user = await Db.users.findOne(
    where: (users) => users.scores.at(0).lt(100),
  );

  print('JSON path findOne (role=user): ${user?.toJson()}');
}
