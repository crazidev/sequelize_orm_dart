import 'dart:io';

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart_example/db/models/post.model.dart';
import 'package:sequelize_dart_example/db/models/post_details.model.dart';
import 'package:sequelize_dart_example/db/models/users.model.dart';
import 'package:test/test.dart';

/// Connection strings for test databases
const postgresUrl = 'postgresql://postgres:postgres@localhost:5432/postgres';
const mysqlUrl = 'mysql://root@localhost:3306/sequelize_dart';
const mariadbUrl = 'mariadb://root@localhost:3307/sequelize_dart';

/// List to capture SQL queries for assertions
final List<String> capturedSql = [];

/// Sequelize instance for tests
late Sequelize sequelize;

/// Initialize the test environment
/// Call this in setUpAll() in your test files
Future<void> initTestEnvironment() async {
  // Clear any previously captured SQL
  capturedSql.clear();

  final dbType = Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';

  SequelizeCoreOptions connection;

  switch (dbType) {
    case 'mysql':
      connection = MysqlConnection(url: mysqlUrl);
      break;
    case 'mariadb':
      connection = MariadbConnection(url: mariadbUrl);
      break;
    case 'postgres':
    default:
      connection = PostgresConnection(url: postgresUrl);
      break;
  }

  // Create Sequelize instance with SQL capture
  sequelize = Sequelize().createInstance(
    connection: connection,
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
  );

  // Initialize with all models
  await sequelize.initialize(
    models: [Users.model, Post.model, PostDetails.model],
  );
}

/// Seed initial data for tests
Future<void> seedInitialData() async {
  await Users.model.create(
    CreateUsers(
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      posts: [
        CreatePost(
          title: 'Post 1',
          content: 'Content 1',
          views: 10,
        ),
        CreatePost(
          title: 'Post 2',
          content: 'Content 2',
          views: 20,
        ),
      ],
    ),
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
String get lastSql => capturedSql.isNotEmpty ? capturedSql.last : '';

/// Get all captured SQL queries that contain SELECT
List<String> get selectQueries =>
    capturedSql.where((sql) => sql.contains('SELECT')).toList();

/// A smarter matcher for SQL queries that ignores quoting and is case-insensitive
Matcher containsSql(String expected) => _SqlMatcher(expected);

class _SqlMatcher extends Matcher {
  final String expected;
  _SqlMatcher(this.expected);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! String) return false;

    // Normalize: remove quotes (both " and `) and convert to lowercase
    String normalize(String sql) {
      return sql
          .replaceAll('"', '')
          .replaceAll('`', '')
          .replaceAll('  ', ' ') // Replace double spaces
          .toLowerCase();
    }

    final normalizedExpected = normalize(expected);
    final normalizedActual = normalize(item);

    return normalizedActual.contains(normalizedExpected);
  }

  @override
  Description describe(Description description) =>
      description.add('contains SQL similar to ').addDescriptionOf(expected);
}
