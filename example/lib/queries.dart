// ignore_for_file: avoid_print

import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:sequelize_dart_example/utils/measureQuery.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  // Test create functionality with Create class
  print('\n=== Testing CREATE ===');
  final newUser = await measureQuery(
    'create',
    () => Users.instance.findAll(limit: 2),
  );
}
