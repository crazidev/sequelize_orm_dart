// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:sequelize_dart_example/utils/measureQuery.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // Test create functionality with Create class
  final users = await measureQuery(
    'findAll',
    () => Users.instance.findAll(
      where: (whereUsers) => and([whereUsers.id.eq(6)]),
      include: (includeUsers) => [
        includeUsers.post(
          include: (i) => [i.postDetails()],
        ),
      ],
    ),
  );

  print(users.map((e) => e.toJson()));
}
