import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:sequelize_dart_example/models/post_details.model.dart';
import 'package:sequelize_dart_example/models/users.model.dart';
import 'package:sequelize_dart_example/queries.dart';

const connectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

/// Main entry point - handles database setup and initialization
Future<void> main() async {
  // Create and configure Sequelize instance
  final sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: connectionString,
      logging: (String sql) => SqlFormatter.printFormatted(
        sql,
        colorScheme: SqlFormatterColors.redTheme,
      ),
    ),
  );

  // Initialize with models - this properly awaits:
  // 1. Bridge connection
  // 2. All model definitions
  // 3. All model associations
  await sequelize.initialize(
    models: [
      Users.instance,
      Post.instance,
      PostDetails.instance,
    ],
  );

  // Run queries - all query logic is in queries.dart
  await runQueries();

  // Close the connection to free up resources
  // await sequelize.close();
}
