// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:sequelize_dart_example/utils/measureQuery.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // Example query: Find users with specific IDs, ordered by ID descending
  final users = await measureQuery(
    'Find users by IDs',
    () => Users.instance.findAll(
      (users) => Query(
        where: or([
          users.id.not(1),
        ]),
        order: [
          ['id', 'DESC'],
        ],
        attributes: QueryAttributes(
          columns: [
            const Column('id'),
            users.email,
          ],
        ),
      ),
    ),
  );

  for (final user in users) {
    // print('${user.toJson()}');
  }
}
