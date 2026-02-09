import 'package:sequelize_orm/src/connection/core_options.dart';
import 'package:sequelize_orm/src/connection/ssl_config.dart';

/// MySQL connection options for Sequelize Dart
///
/// Based on mysql2 package options from Sequelize v7.
/// See: https://sequelize.org/docs/v7/databases/mysql/#connection-options
class MysqlConnection extends SequelizeCoreOptions {
  final SequelizeDialects dialect;

  // --- Connection Options ---

  /// Local address to bind to for network connections.
  final String? localAddress;

  /// Socket path for local connections (alternative to host/port).
  final String? socketPath;

  /// SSL configuration. Can be boolean or [SslConfig] object.
  final Object? ssl;

  /// Character set to use.
  final String charset;

  /// Enable compression.
  final bool compress;

  /// Enable TCP keep-alive.
  final bool enableKeepAlive;

  /// Initial delay for keep-alive in milliseconds.
  final int? keepAliveInitialDelay;

  /// Connection timeout in milliseconds.
  final int connectTimeout;

  /// Connection attributes sent to server.
  final Map<String, String>? connectAttributes;

  // --- Other MySQL Options ---

  /// Show SQL warnings when logging is enabled.
  final bool showWarnings;

  MysqlConnection({
    super.url,
    super.host = 'localhost',
    super.user,
    super.password,
    super.database,
    super.port = 3306,
    this.localAddress,
    this.socketPath,
    this.ssl = false,
    this.charset = 'utf8mb4',
    this.compress = false,
    this.enableKeepAlive = true,
    this.keepAliveInitialDelay,
    this.connectTimeout = 10000,
    this.connectAttributes,
    this.showWarnings = false,
    this.dialect = SequelizeDialects.mysql,
    super.hoistIncludeOptions,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dialect': dialect.value,
      'ssl': serializeSsl(ssl),
      if (localAddress != null) 'localAddress': localAddress,
      if (socketPath != null) 'socketPath': socketPath,
      'charset': charset,
      'compress': compress,
      'enableKeepAlive': enableKeepAlive,
      if (keepAliveInitialDelay != null)
        'keepAliveInitialDelay': keepAliveInitialDelay,
      'connectTimeout': connectTimeout,
      if (connectAttributes != null) 'connectAttributes': connectAttributes,
      'showWarnings': showWarnings,
    };
  }
}
