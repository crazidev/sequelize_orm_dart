import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';

/// Run all query examples
/// This function is called from
/// main.dart after the database connection is established
Future<void> runQueries() async {
  // Fetch user based on Enum

  final user = await Db.users.findOne(
    where: (users) => or([
      users.status.isActive,
      users.status.notActive,
    ]),
  );

  print(user.toString());
}
