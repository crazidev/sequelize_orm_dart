import 'dart:io';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_example/db/models/post.model.dart';
import 'package:sequelize_orm_example/db/models/post_details.model.dart';
import 'package:sequelize_orm_example/db/models/users.model.dart';
import 'package:test/test.dart';

/// Connection strings for test databases
const postgresUrl = 'postgresql://postgres:postgres@localhost:5432/postgres';
const mysqlUrl = 'mysql://root@localhost:3306/sequelize_orm';
const mariadbUrl = 'mariadb://root@localhost:3307/sequelize_orm';

/// SQLite database file path for tests (auto-cleaned on teardown)
const sqliteStorage = 'test_sequelize.db';

/// List to capture SQL queries for assertions
final List<String> capturedSql = [];

/// Sequelize instance for tests
late Sequelize sequelize;

/// The active dialect resolved from the DB_TYPE environment variable.
/// Available after [initTestEnvironment] is called, but the getter itself
/// can be used before that (it only reads the env var).
///
/// Supported values: `postgres` (default), `mysql`, `mariadb`, `sqlite`.
///
/// Usage:
/// ```sh
/// # Run tests with SQLite
/// DB_TYPE=sqlite dart test
///
/// # Run tests with MySQL
/// DB_TYPE=mysql dart test
/// ```
String get dbType =>
    Platform.environment['DB_TYPE']?.toLowerCase() ?? 'postgres';

/// Whether the active dialect is SQLite.
bool get isSqlite => dbType == 'sqlite';

/// Whether the active dialect is PostgreSQL.
bool get isPostgres => dbType == 'postgres';

/// Whether the active dialect is MySQL or MariaDB.
bool get isMysqlFamily => dbType == 'mysql' || dbType == 'mariadb';

/// Initialize the test environment
/// Call this in setUpAll() in your test files
Future<void> initTestEnvironment() async {
  // Clear any previously captured SQL
  capturedSql.clear();

  SequelizeCoreOptions connection;
  bool normalizeJsonTypes = true;

  switch (dbType) {
    case 'mysql':
      connection = MysqlConnection(url: mysqlUrl);
      break;
    case 'mariadb':
      connection = MariadbConnection(url: mariadbUrl);
      break;
    case 'sqlite':
      // Delete stale SQLite file to ensure test isolation between suites
      final dbFile = File(sqliteStorage);
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
      connection = SqliteConnection(storage: sqliteStorage);
      normalizeJsonTypes = false;
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
    normalizeJsonTypes: normalizeJsonTypes,
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

  // Remove the SQLite database file if it was created
  if (isSqlite) {
    final dbFile = File(sqliteStorage);
    if (dbFile.existsSync()) {
      dbFile.deleteSync();
    }
  }
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
