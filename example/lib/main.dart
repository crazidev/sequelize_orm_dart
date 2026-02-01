import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/db.dart';
import 'package:sequelize_dart_example/queries.dart';

const connectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

/// Main entry point - handles database setup and initialization
Future<void> main() async {
  // Create and configure Sequelize instance
  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(url: connectionString),
    logging: (msg) => print(msg),
  );

  // Initialize with models - this properly awaits:
  // 1. Bridge connection
  // 2. All model definitions
  // 3. All model associations
  await sequelize.initialize(
    models: Db.allModels(),
  );

  await sequelize.seed(
    seeders: Db.allSeeders(),
    syncTableMode: SyncTableMode.force,
  );

  // Run queries - all query logic is in queries.dart
  await runQueries();

  // Close the connection to free up resources
  await sequelize.close();
}
