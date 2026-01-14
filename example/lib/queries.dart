// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // Test create functionality with Create class
  final users = await Users.instance.findOne(
    where: (whereUsers) => and([const Column('view').eq(6)]),
    include: (includeUsers) => [
      // Intentionally invalid include to trigger EagerLoadingError
    ],
  );

  await Users.instance.findOne();
  // print(users.map((e) => e.toJson()));
}
