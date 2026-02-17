import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/db.dart';
import 'package:sequelize_orm_example/queries.dart';

const connectionString = 'mysql://root@localhost:3306/sequelize_dart';
const postgresConnectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

/// Main entry point - handles database setup and initialization
Future<void> main() async {
  // Create and configure Sequelize instance
  final sequelize = Sequelize().createInstance(
    // connection: SequelizeConnection.postgres(url: postgresConnectionString),
    // connection: SequelizeConnection.mysql(url: connectionString),
    connection: SequelizeConnection.sqlite(storage: 'test_db.db'),
    logging: SqlFormatter.printFormatted,
    normalizeJsonTypes: false,
  );

  // Initialize with models - this properly awaits:
  // 1. Bridge connection
  // 2. All model definitions
  // 3. All model associations
  await sequelize.initialize(
    models: Db.allModels(),
  );

  // await sequelize.sync(alter: true);

  await sequelize.seed(
    seeders: Db.allSeeders(),
    syncTableMode: SyncTableMode.alter,
  );

  // Run queries - all query logic is in queries.dart
  await runQueries();

  // Close the connection to free up resources
  await sequelize.close();
}
