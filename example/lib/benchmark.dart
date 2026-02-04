// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/models/post.model.dart';
import 'package:sequelize_dart_example/db/models/post_details.model.dart';
import 'package:sequelize_dart_example/db/models/users.model.dart';

const connectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

/// Benchmark results holder
class BenchmarkResult {
  final String name;
  final int durationMs;
  final int rowCount;

  BenchmarkResult(this.name, this.durationMs, this.rowCount);

  @override
  String toString() => '$name: ${durationMs}ms ($rowCount rows)';
}

/// Run a single benchmark
Future<BenchmarkResult> runBenchmark<T>(
  String name,
  Future<T> Function() query, {
  int Function(T)? rowCounter,
}) async {
  final stopwatch = Stopwatch()..start();
  final result = await query();
  stopwatch.stop();

  int rowCount = 0;
  if (rowCounter != null) {
    rowCount = rowCounter(result);
  } else if (result is List) {
    rowCount = result.length;
  } else if (result is int) {
    rowCount = result;
  } else if (result != null) {
    rowCount = 1;
  }

  return BenchmarkResult(name, stopwatch.elapsedMilliseconds, rowCount);
}

/// Main benchmark entry point
Future<void> main() async {
  print('');
  print('=' * 60);
  print('SEQUELIZE DART BENCHMARK');
  print('=' * 60);
  print('');

  // Detect platform
  final platform = _detectPlatform();
  print('Platform: $platform');
  print('');

  // Initialize
  print('Initializing database connection...');
  final initStopwatch = Stopwatch()..start();

  final sequelize = Sequelize().createInstance(
    connection: SequelizeConnection.postgres(url: connectionString),
  );

  await sequelize.initialize(
    models: [
      Users.model,
      Post.model,
      PostDetails.model,
    ],
  );

  initStopwatch.stop();
  print('Initialization completed in ${initStopwatch.elapsedMilliseconds}ms');
  print('');

  // Warmup query (first query is always slower due to connection pooling)
  print('Warming up...');
  await Post.model.findAll();
  print('');

  // Run benchmarks
  final results = <BenchmarkResult>[];

  print('-' * 60);
  print('Running benchmarks...');
  print('-' * 60);

  // Benchmark 1: Simple findAll
  results.add(
    await runBenchmark(
      'findAll (all posts)',
      () => Post.model.findAll(),
    ),
  );

  // Benchmark 2: findAll with limit
  results.add(
    await runBenchmark(
      'findAll (limit 10)',
      () => Post.model.findAll(limit: 10),
    ),
  );

  // Benchmark 3: findOne
  results.add(
    await runBenchmark(
      'findOne',
      () => Post.model.findOne(where: (p) => p.id.eq(1)),
      rowCounter: (r) => r != null ? 1 : 0,
    ),
  );

  // Benchmark 4: count
  results.add(
    await runBenchmark(
      'count',
      () => Post.model.count(),
      rowCounter: (r) => r,
    ),
  );

  // Benchmark 5: findAll with where clause
  results.add(
    await runBenchmark(
      'findAll (where id < 5)',
      () => Post.model.findAll(where: (p) => p.id.lt(5)),
    ),
  );

  // Benchmark 6: findAll with include (join)
  results.add(
    await runBenchmark(
      'findAll with include (postDetails)',
      () => Post.model.findAll(
        limit: 10,
        include: (post) => [post.postDetails()],
      ),
    ),
  );

  // Benchmark 7: max
  results.add(
    await runBenchmark(
      'max (views)',
      () => Post.model.max((p) => p.views),
      rowCounter: (r) => r != null ? 1 : 0,
    ),
  );

  // Benchmark 8: sum
  results.add(
    await runBenchmark(
      'sum (views)',
      () => Post.model.sum((p) => p.views),
      rowCounter: (r) => r != null ? 1 : 0,
    ),
  );

  // Benchmark 9: Multiple sequential queries
  results.add(
    await runBenchmark(
      '5 sequential findOnes',
      () async {
        for (var i = 1; i <= 5; i++) {
          await Post.model.findOne(where: (p) => p.id.eq(i));
        }
        return 5;
      },
      rowCounter: (r) => r,
    ),
  );

  // Benchmark 10: Complex query with multiple conditions
  results.add(
    await runBenchmark(
      'findAll (complex where)',
      () => Post.model.findAll(
        where: (p) => and([
          p.id.gt(0),
          p.id.lt(100),
        ]),
        limit: 20,
      ),
    ),
  );

  // Print results
  print('');
  print('=' * 60);
  print('BENCHMARK RESULTS - $platform');
  print('=' * 60);
  print('');

  var totalTime = 0;
  for (final result in results) {
    final name = result.name.padRight(35);
    final time = '${result.durationMs}ms'.padLeft(8);
    final rows = '(${result.rowCount} rows)'.padLeft(12);
    print('$name $time $rows');
    totalTime += result.durationMs;
  }

  print('-' * 60);
  print('${'Total query time:'.padRight(35)} ${totalTime}ms'.padLeft(8));
  print(
    '${'Average per query:'.padRight(35)} ${(totalTime / results.length).toStringAsFixed(1)}ms'
        .padLeft(8),
  );
  print('');

  // Cleanup
  // await sequelize.close();
  print('Connection closed.');
}

String _detectPlatform() {
  try {
    // In dart2js, this will be true
    if (identical(1.0, 1)) {
      return 'dart2js (Worker Thread Bridge)';
    }
  } catch (_) {}
  return 'Dart VM (stdio Bridge)';
}
