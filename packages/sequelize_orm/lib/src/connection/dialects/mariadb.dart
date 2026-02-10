import 'package:sequelize_orm/src/connection/core_options.dart';
import 'package:sequelize_orm/src/connection/ssl_config.dart';

/// MariaDB connection options for Sequelize Dart
///
/// Based on mariadb package options from Sequelize v7.
/// See: https://sequelize.org/docs/v7/databases/mariadb/#connection-options
class MariadbConnection extends SequelizeCoreOptions {
  final SequelizeDialects dialect;

  // --- Connection Options ---

  /// Unix domain socket or named pipe path.
  final String? socketPath;

  /// Enable gzip compression.
  final bool compress;

  /// Connection timeout in milliseconds.
  final int connectTimeout;

  /// Socket timeout in milliseconds after the connection is established.
  final int socketTimeout;

  /// Maximum allowed packet size (default: 4Mb).
  final int maxAllowedPacket;

  /// Size of prepared statement cache (0 to disable).
  final int prepareCacheLength;

  /// SSL configuration. Can be boolean or [SslConfig] object.
  final Object? ssl;

  /// Character set to use.
  final String charset;

  /// Collation to use.
  final String? collation;

  /// Connection attributes sent to server (shown in Performance Schema).
  final Map<String, String>? connectAttributes;

  /// Enable TCP keep-alive delay in milliseconds.
  final int? keepAliveDelay;

  /// Query timeout in milliseconds.
  final int? queryTimeout;

  /// Show SQL warnings when logging is enabled.
  final bool showWarnings;

  MariadbConnection({
    super.url,
    super.host = 'localhost',
    super.user,
    super.password,
    super.database,
    super.port = 3306,
    this.socketPath,
    this.compress = false,
    this.connectTimeout = 1000,
    this.socketTimeout = 0,
    this.maxAllowedPacket = 4196304,
    this.prepareCacheLength = 256,
    this.ssl = false,
    this.charset = 'utf8mb4',
    this.collation,
    this.connectAttributes,
    this.keepAliveDelay,
    this.queryTimeout,
    this.showWarnings = false,
    this.dialect = SequelizeDialects.mariadb,
    super.hoistIncludeOptions,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dialect': dialect.value,
      'ssl': serializeSsl(ssl),
      if (socketPath != null) 'socketPath': socketPath,
      'compress': compress,
      'connectTimeout': connectTimeout,
      'socketTimeout': socketTimeout,
      'maxAllowedPacket': maxAllowedPacket,
      'prepareCacheLength': prepareCacheLength,
      'charset': charset,
      if (collation != null) 'collation': collation,
      if (connectAttributes != null) 'connectAttributes': connectAttributes,
      if (keepAliveDelay != null) 'keepAliveDelay': keepAliveDelay,
      if (queryTimeout != null) 'queryTimeout': queryTimeout,
      'showWarnings': showWarnings,
    };
  }
}
