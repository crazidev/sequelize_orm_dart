import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
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
      logging: (String sql) => SqlFormatter.printFormatted(sql),
      pool: SequelizePoolOptions(
        max: 10, // Maximum connections (increased to handle concurrent queries)
        min: 5, // Minimum connections
        idle: 10000, // Idle timeout (ms)
        acquire: 60000, // Max time to get connection (ms)
        evict: 1000, // Check for idle connections (ms)
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
    ],
  );

  // Run queries - all query logic is in queries.dart
  await runQueries();

  // Close the connection to free up resources
  // await sequelize.close();
}
