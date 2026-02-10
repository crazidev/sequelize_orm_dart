import 'package:sequelize_orm/src/connection/core_options.dart';

/// DB2 for LUW (Linux, Unix, Windows) connection options for Sequelize Dart
class Db2Connection extends SequelizeCoreOptions {
  final SequelizeDialects dialect;

  /// The hostname of the DB2 server.
  final String hostname;

  /// Enable SSL connection.
  final bool ssl;

  /// Path to the SSL server certificate.
  final String? sslServerCertificate;

  /// Additional ODBC connection options.
  final Map<String, dynamic>? odbcOptions;

  Db2Connection({
    required super.database,
    required super.user,
    required super.password,
    required this.hostname,
    super.port = 50000,
    this.ssl = false,
    this.sslServerCertificate,
    this.odbcOptions,
    this.dialect = SequelizeDialects.db2,
    super.hoistIncludeOptions,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dialect': dialect.value,
      'hostname': hostname,
      'ssl': ssl,
      if (sslServerCertificate != null)
        'sslServerCertificate': sslServerCertificate,
      if (odbcOptions != null) 'odbcOptions': odbcOptions,
    };
  }
}
