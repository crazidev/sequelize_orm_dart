import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/models/post.model.dart';
import 'package:sequelize_dart_example/models/post_details.model.dart';
import 'package:sequelize_dart_example/models/users.model.dart';

/// Connection string for test database
const testConnectionString =
    'postgresql://postgres:postgres@localhost:5432/postgres';

/// List to capture SQL queries for assertions
final List<String> capturedSql = [];

/// Sequelize instance for tests
late dynamic sequelize;

/// Initialize the test environment
/// Call this in setUpAll() in your test files
Future<void> initTestEnvironment() async {
  // Clear any previously captured SQL
  capturedSql.clear();

  // Create Sequelize instance with SQL capture
  sequelize = Sequelize().createInstance(
    PostgressConnection(
      url: testConnectionString,
      logging: (String sql) {
        capturedSql.add(sql);
      },
      pool: SequelizePoolOptions(
        max: 5,
        min: 1,
        idle: 10000,
        acquire: 60000,
        evict: 1000,
      ),
    ),
  );

  // Initialize with all models
  await sequelize.initialize(
    models: [Users.instance, Post.instance, PostDetails.instance],
  );
}

/// Cleanup the test environment
/// Call this in tearDownAll() in your test files
Future<void> cleanupTestEnvironment() async {
  await sequelize.close();
}

/// Clear captured SQL between tests
/// Call this in setUp() to ensure clean state for each test
void clearCapturedSql() {
  capturedSql.clear();
}

/// Get the last captured SQL query
String? get lastSql => capturedSql.isNotEmpty ? capturedSql.last : null;

/// Get all captured SQL queries that contain SELECT
List<String> get selectQueries =>
    capturedSql.where((sql) => sql.contains('SELECT')).toList();
