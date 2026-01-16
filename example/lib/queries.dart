// ignore_for_file: avoid_print

import 'package:sequelize_dart_example/models/db.dart';

/// Run all query examples
/// This function is called from main.dart after the database connection is established
Future<void> runQueries() async {
  final result = await Db.post.findOne();

  print(result);
}
