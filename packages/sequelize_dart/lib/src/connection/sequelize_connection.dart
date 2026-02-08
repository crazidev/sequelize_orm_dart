import 'package:sequelize_dart/src/connection/dialects/db2.dart';
import 'package:sequelize_dart/src/connection/dialects/mariadb.dart';
import 'package:sequelize_dart/src/connection/dialects/mssql.dart';
import 'package:sequelize_dart/src/connection/dialects/mysql.dart';
import 'package:sequelize_dart/src/connection/dialects/postgres.dart';
import 'package:sequelize_dart/src/connection/dialects/sqlite.dart';

/// Factory class for creating Sequelize connection configurations.
///
/// Use the static methods to create connection options for specific database dialects:
///
/// ```dart
/// // PostgreSQL
/// final sequelize = Sequelize().createInstance(
///   connection: SequelizeConnection.postgres(
///     host: 'localhost',
///     database: 'mydb',
///     user: 'user',
///     password: 'password',
///     ssl: SslConfig(),
///   ),
///   logging: (sql) => print(sql),
///   pool: SequelizePoolOptions(max: 10),
/// );
/// ```
class SequelizeConnection {
  // Private constructor to prevent instantiation
  SequelizeConnection._();

  /// Creates a PostgreSQL connection configuration.
  ///
  /// See: https://sequelize.org/docs/v7/databases/postgres/#connection-options
  static PostgresConnection postgres({
    String? url,
    String host = 'localhost',
    int port = 5432,
    String? database,
    String? user,
    String? password,
    Object? ssl = false,
    int? queryTimeout,
    int? connectionTimeoutMillis,
    String? applicationName,
    int? statementTimeout,
    int? idleInTransactionSessionTimeout,
    String clientEncoding = 'utf8',
    int? lockTimeout,
    String? options,
    bool keepAlive = true,
    int? keepAliveInitialDelayMillis,
    String schema = 'public',
    bool hoistIncludeOptions = false,
  }) {
    return PostgresConnection(
      url: url,
      host: host,
      port: port,
      database: database,
      user: user,
      password: password,
      ssl: ssl,
      queryTimeout: queryTimeout,
      connectionTimeoutMillis: connectionTimeoutMillis,
      applicationName: applicationName,
      statementTimeout: statementTimeout,
      idleInTransactionSessionTimeout: idleInTransactionSessionTimeout,
      clientEncoding: clientEncoding,
      lockTimeout: lockTimeout,
      options: options,
      keepAlive: keepAlive,
      keepAliveInitialDelayMillis: keepAliveInitialDelayMillis,
      schema: schema,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }

  /// Creates a MySQL connection configuration.
  ///
  /// See: https://sequelize.org/docs/v7/databases/mysql/#connection-options
  static MysqlConnection mysql({
    String? url,
    String host = 'localhost',
    int port = 3306,
    String? database,
    String? user,
    String? password,
    String? localAddress,
    String? socketPath,
    Object? ssl = false,
    String charset = 'utf8mb4',
    bool compress = false,
    bool enableKeepAlive = true,
    int? keepAliveInitialDelay,
    int connectTimeout = 10000,
    Map<String, String>? connectAttributes,
    bool showWarnings = false,
    bool hoistIncludeOptions = false,
  }) {
    return MysqlConnection(
      url: url,
      host: host,
      port: port,
      database: database,
      user: user,
      password: password,
      localAddress: localAddress,
      socketPath: socketPath,
      ssl: ssl,
      charset: charset,
      compress: compress,
      enableKeepAlive: enableKeepAlive,
      keepAliveInitialDelay: keepAliveInitialDelay,
      connectTimeout: connectTimeout,
      connectAttributes: connectAttributes,
      showWarnings: showWarnings,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }

  /// Creates a MariaDB connection configuration.
  ///
  /// See: https://sequelize.org/docs/v7/databases/mariadb/#connection-options
  static MariadbConnection mariadb({
    String? url,
    String host = 'localhost',
    int port = 3306,
    String? database,
    String? user,
    String? password,
    String? socketPath,
    bool compress = false,
    int connectTimeout = 1000,
    int socketTimeout = 0,
    int maxAllowedPacket = 4196304,
    int prepareCacheLength = 256,
    Object? ssl = false,
    String charset = 'utf8mb4',
    String? collation,
    Map<String, String>? connectAttributes,
    int? keepAliveDelay,
    int? queryTimeout,
    bool showWarnings = false,
    bool hoistIncludeOptions = false,
  }) {
    return MariadbConnection(
      url: url,
      host: host,
      port: port,
      database: database,
      user: user,
      password: password,
      socketPath: socketPath,
      compress: compress,
      connectTimeout: connectTimeout,
      socketTimeout: socketTimeout,
      maxAllowedPacket: maxAllowedPacket,
      prepareCacheLength: prepareCacheLength,
      ssl: ssl,
      charset: charset,
      collation: collation,
      connectAttributes: connectAttributes,
      keepAliveDelay: keepAliveDelay,
      queryTimeout: queryTimeout,
      showWarnings: showWarnings,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }

  /// Creates a SQLite connection configuration.
  ///
  /// See: https://sequelize.org/docs/v7/databases/sqlite/#connection-options
  static SqliteConnection sqlite({
    required String storage,
    List<SqliteMode>? mode,
    String? password,
    bool foreignKeys = true,
    bool hoistIncludeOptions = false,
  }) {
    return SqliteConnection(
      storage: storage,
      mode: mode,
      sqlitePassword: password,
      foreignKeys: foreignKeys,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }

  /// Creates a Microsoft SQL Server (MSSQL) connection configuration.
  ///
  /// See: https://sequelize.org/docs/v7/databases/mssql/#connection-options
  static MssqlConnection mssql({
    String host = 'localhost',
    int port = 1433,
    String? database,
    String? user,
    String? password,
    String? server,
    String? instanceName,
    MssqlAuthentication? authentication,
    bool abortTransactionOnError = false,
    String? appName,
    int connectTimeout = 15000,
    MssqlIsolationLevel connectionIsolationLevel =
        MssqlIsolationLevel.readCommitted,
    Object encrypt = true,
    bool trustServerCertificate = false,
    int requestTimeout = 15000,
    TdsVersion? tdsVersion,
    bool hoistIncludeOptions = false,
  }) {
    return MssqlConnection(
      host: host,
      port: port,
      database: database,
      user: user,
      password: password,
      server: server,
      instanceName: instanceName,
      authentication: authentication,
      abortTransactionOnError: abortTransactionOnError,
      appName: appName,
      connectTimeout: connectTimeout,
      connectionIsolationLevel: connectionIsolationLevel,
      encrypt: encrypt,
      trustServerCertificate: trustServerCertificate,
      requestTimeout: requestTimeout,
      tdsVersion: tdsVersion,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }

  /// Creates a DB2 for LUW (Linux, Unix, Windows) connection configuration.
  ///
  /// See: https://sequelize.org/docs/v7/databases/db2/#connection-options
  static Db2Connection db2({
    required String hostname,
    required String database,
    required String user,
    required String password,
    int? port,
    bool ssl = false,
    String? sslServerCertificate,
    Map<String, dynamic>? odbcOptions,
    bool hoistIncludeOptions = false,
  }) {
    return Db2Connection(
      hostname: hostname,
      database: database,
      user: user,
      password: password,
      port: port,
      ssl: ssl,
      sslServerCertificate: sslServerCertificate,
      odbcOptions: odbcOptions,
      hoistIncludeOptions: hoistIncludeOptions,
    );
  }
}
