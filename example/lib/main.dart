import 'package:sequelize_dart/sequelize_dart.dart';

import 'models/users.model.dart';
import 'queries.dart';

const connectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

/// Main entry point - handles database setup and initialization
Future<void> main() async {
  // Create and configure Sequelize instance
  final sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: connectionString,
      logging: (String sql) => print(sql),
      pool: SequelizePoolOptions(
        max: 10, // Maximum connections (increased to handle concurrent queries)
        min: 5, // Minimum connections
        idle: 10000, // Idle timeout (ms)
        acquire: 60000, // Max time to get connection (ms)
        evict: 1000, // Check for idle connections (ms)
      ),
    ),
  );

  // Authenticate and register models
  await sequelize.authenticate();
  sequelize.addModels([Users.instance]);

  // Run queries - all query logic is in queries.dart
  await runQueries();

  // Close the connection to free up resources
  await sequelize.close();
}
