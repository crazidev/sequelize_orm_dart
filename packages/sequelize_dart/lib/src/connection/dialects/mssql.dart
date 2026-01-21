import 'package:sequelize_dart/src/connection/core_options.dart';

/// Tedious isolation levels for MSSQL transactions
enum MssqlIsolationLevel {
  readUncommitted('READ_UNCOMMITTED'),
  readCommitted('READ_COMMITTED'),
  repeatableRead('REPEATABLE_READ'),
  serializable('SERIALIZABLE'),
  snapshot('SNAPSHOT');

  final String value;
  const MssqlIsolationLevel(this.value);
}

/// Microsoft SQL Server TDS protocol versions
enum TdsVersion {
  version71('7_1'),
  version72('7_2'),
  version73('7_3'),
  version73A('7_3_A'),
  version73B('7_3_B'),
  version74('7_4');

  final String value;
  const TdsVersion(this.value);
}

/// Authentication configuration for MSSQL
class MssqlAuthentication {
  /// Authentication type: 'default', 'ntlm', 'azure-active-directory-password', etc.
  final String type;

  /// Options for authentication (depends on type)
  final MssqlAuthOptions? options;

  MssqlAuthentication({
    required this.type,
    this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (options != null) 'options': options!.toJson(),
    };
  }
}

/// Authentication options for MSSQL
class MssqlAuthOptions {
  /// Username for authentication
  final String? userName;

  /// Password for authentication
  final String? password;

  /// Domain for NTLM authentication
  final String? domain;

  MssqlAuthOptions({
    this.userName,
    this.password,
    this.domain,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userName != null) 'userName': userName,
      if (password != null) 'password': password,
      if (domain != null) 'domain': domain,
    };
  }
}

/// Microsoft SQL Server connection options for Sequelize Dart
///
/// Based on tedious package options from Sequelize v7.
/// See: https://sequelize.org/docs/v7/databases/mssql/#connection-options
class MssqlConnection extends SequelizeCoreOptions {
  final SequelizeDialects dialect;

  // --- Connection Options (from tedious) ---

  /// Server hostname or IP address.
  final String? server;

  /// SQL Server instance name (mutually exclusive with port).
  final String? instanceName;

  /// Authentication configuration.
  final MssqlAuthentication? authentication;

  /// Whether to abort the transaction on error.
  final bool abortTransactionOnError;

  /// Application name for SQL Server.
  final String? appName;

  /// Connection timeout in milliseconds.
  final int connectTimeout;

  /// Default isolation level for transactions.
  final MssqlIsolationLevel connectionIsolationLevel;

  /// Encryption setting: true, false, or 'strict'.
  final Object encrypt;

  /// Trust the server certificate without validation.
  final bool trustServerCertificate;

  /// Request timeout in milliseconds.
  final int requestTimeout;

  /// TDS protocol version to use.
  final TdsVersion? tdsVersion;

  MssqlConnection({
    super.host = 'localhost',
    super.user,
    super.password,
    super.database,
    super.port = 1433,
    this.server,
    this.instanceName,
    this.authentication,
    this.abortTransactionOnError = false,
    this.appName,
    this.connectTimeout = 15000,
    this.connectionIsolationLevel = MssqlIsolationLevel.readCommitted,
    this.encrypt = true,
    this.trustServerCertificate = false,
    this.requestTimeout = 15000,
    this.tdsVersion,
    this.dialect = SequelizeDialects.mssql,
    super.hoistIncludeOptions,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dialect': dialect.value,
      if (server != null) 'server': server,
      if (instanceName != null) 'instanceName': instanceName,
      if (authentication != null) 'authentication': authentication!.toJson(),
      'abortTransactionOnError': abortTransactionOnError,
      if (appName != null) 'appName': appName,
      'connectTimeout': connectTimeout,
      'connectionIsolationLevel': connectionIsolationLevel.value,
      'encrypt': encrypt,
      'trustServerCertificate': trustServerCertificate,
      'requestTimeout': requestTimeout,
      if (tdsVersion != null) 'tdsVersion': tdsVersion!.value,
    };
  }
}
