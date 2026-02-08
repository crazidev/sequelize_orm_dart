import 'package:sequelize_dart/src/connection/core_options.dart';
import 'package:sequelize_dart/src/connection/ssl_config.dart';

/// PostgreSQL connection options for Sequelize Dart
///
/// Based on pg package options from Sequelize v7.
/// See: https://sequelize.org/docs/v7/databases/postgres/#connection-options
class PostgresConnection extends SequelizeCoreOptions {
  final SequelizeDialects dialect;

  // --- Connection Options ---

  /// SSL configuration. Can be boolean or [SslConfig] object.
  final Object? ssl;

  /// Query timeout in milliseconds.
  final int? queryTimeout;

  /// Connection timeout in milliseconds.
  final int? connectionTimeoutMillis;

  /// Application name for PostgreSQL (shown in pg_stat_activity).
  final String? applicationName;

  /// Statement timeout in milliseconds.
  final int? statementTimeout;

  /// Idle in transaction session timeout in milliseconds.
  final int? idleInTransactionSessionTimeout;

  /// Client encoding (default: utf8).
  final String clientEncoding;

  /// Lock timeout in milliseconds.
  final int? lockTimeout;

  /// Additional libpq connection options.
  final String? options;

  /// Enable TCP keep-alive.
  final bool keepAlive;

  /// Initial delay for keep-alive in milliseconds.
  final int? keepAliveInitialDelayMillis;

  /// Database schema to use (default is 'public').
  final String schema;

  PostgresConnection({
    super.url,
    super.host = 'localhost',
    super.user,
    super.password,
    super.database,
    super.port = 5432,
    this.ssl = false,
    this.queryTimeout,
    this.connectionTimeoutMillis,
    this.applicationName,
    this.statementTimeout,
    this.idleInTransactionSessionTimeout,
    this.clientEncoding = 'utf8',
    this.lockTimeout,
    this.options,
    this.keepAlive = true,
    this.keepAliveInitialDelayMillis,
    this.schema = 'public',
    this.dialect = SequelizeDialects.postgres,
    super.hoistIncludeOptions,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dialect': dialect.value,
      'ssl': serializeSsl(ssl),
      if (queryTimeout != null) 'query_timeout': queryTimeout,
      if (connectionTimeoutMillis != null)
        'connectionTimeoutMillis': connectionTimeoutMillis,
      if (applicationName != null) 'application_name': applicationName,
      if (statementTimeout != null) 'statement_timeout': statementTimeout,
      if (idleInTransactionSessionTimeout != null)
        'idle_in_transaction_session_timeout': idleInTransactionSessionTimeout,
      'client_encoding': clientEncoding,
      if (lockTimeout != null) 'lock_timeout': lockTimeout,
      if (options != null) 'options': options,
      'keepAlive': keepAlive,
      if (keepAliveInitialDelayMillis != null)
        'keepAliveInitialDelayMillis': keepAliveInitialDelayMillis,
      'schema': schema,
    };
  }
}

/// @Deprecated('Use PostgresConnection instead')
/// Backward compatibility alias for PostgresConnection (old misspelled name)
typedef PostgressConnection = PostgresConnection;
