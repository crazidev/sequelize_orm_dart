import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/users.model.dart';

const connectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

Future<void> main() async {
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

  await sequelize.authenticate();
  sequelize.addModels([Users.instance]);

  final startTime = DateTime.now();

  const totalQueries = 1;

  // Test type-safe queries
  print('\n=== Testing Type-Safe Queries ===\n');

  // Example 1: Type-safe findAll with autocomplete
  final users1 = await Users.instance.findAll(
    (q) => Query(
      where: or([
        q.id.greaterThan(1),
      ]),
      order: [
        ['id', 'DESC'],
      ],
    ),
  );

  // Example 2: Type-safe findOne
  final user = await Users.instance.findOne(
    (q) => Query(
      where: q.id.eq(1),
    ),
  );

  print('Found ${users1.length} users');
  print('Found user: ${user?.email}');

  // Performance test
  final futures = <Future>[];
  for (var i = 0; i < totalQueries; i++) {
    final queryStart = DateTime.now();
    final future = Users.instance
        .findAll(
          (q) => Query(
            where: q.id.in_([1, 2]),
            order: [
              ['id', 'DESC'],
            ],
          ),
        )
        .then((value) {
          final queryDuration = DateTime.now().difference(queryStart);
          print(
            '\nQUERY $i: ${value.map((e) => e.toJson())} (took ${queryDuration.inMilliseconds}ms)',
          );
        });
    futures.add(future);
  }

  // Wait for all queries to complete
  await Future.wait(futures);
  final totalDuration = DateTime.now().difference(startTime);
  print(
    '\n$totalQueries queries completed in ${totalDuration.inMilliseconds}ms',
  );

  // Close the connection to free up resources
  await sequelize.close();
}
