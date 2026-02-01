import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/models/db.dart';
import 'package:sequelize_dart_example/db/seeders/seeders.dart';
import 'package:sequelize_dart_example/queries.dart';

const connectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

/// Main entry point - handles database setup and initialization
Future<void> main() async {
  // Create and configure Sequelize instance
  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(url: connectionString),
    // logging: (sql) => SqlFormatter.printFormatted(
    //   sql,
    //   colorScheme: SqlFormatterColors.redTheme,
    // ),
  );

  // Initialize with models - this properly awaits:
  // 1. Bridge connection
  // 2. All model definitions
  // 3. All model associations
  await sequelize.initialize(
    models: Db.allModels(),
  );

  await sequelize.sync(alter: true, force: true);
  await sequelize.seed(
    seeders: Seeders.all(),
  );

  // Run queries - all query logic is in queries.dart
  await runQueries();

  // Close the connection to free up resources
  await sequelize.close();
}
