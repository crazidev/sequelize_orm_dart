import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';

const connectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

Future<void> main() async {
  var sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: connectionString,
      ssl: false,
      logging: (String sql) => false,
      pool: SequelizePoolOptions(
        max: 10, // Maximum connections (increased to handle concurrent queries)
        min: 5, // Minimum connections
        idle: 10000, // Idle timeout (ms)
        acquire: 60000, // Max time to get connection (ms)
        evict: 1000, // Check for idle connections (ms)
      ),
    ),
  );

  await sequelize.authenticate();
  sequelize.addModels([Users.instance]);

  final startTime = DateTime.now();

  // Fire off 100 concurrent queries
  final futures = <Future>[];
  for (var i = 0; i < 100; i++) {
    final queryStart = DateTime.now();
    final future = Users.instance
        .findAll(
          Query(
            where: or([]),
            order: [
              ['id', 'DESC'],
            ],
          ),
        )
        .then((value) {
          final queryDuration = DateTime.now().difference(queryStart);
          print(
            "RESULT $i: ${value.map((e) => e.email)} (took ${queryDuration.inMilliseconds}ms)",
          );
        });
    futures.add(future);
  }

  // Wait for all queries to complete
  await Future.wait(futures);
  final totalDuration = DateTime.now().difference(startTime);
  print("\nAll 100 queries completed in ${totalDuration.inMilliseconds}ms");

  // Close the connection to free up resources
  await sequelize.close();
}
