import 'package:sequelize_dart_example/db/db.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  final allUsersCount = await Db.users.count();
  print('All users count: $allUsersCount');
}
