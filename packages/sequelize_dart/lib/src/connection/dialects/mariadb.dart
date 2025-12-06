import 'package:sequelize_dart/src/connection/core_options.dart';

class MariadbConnection extends SequelizeCoreOptions {
  final bool ssl;
  final SequelizeDialects dialect;

  MariadbConnection({
    required super.url,
    this.ssl = false,
    this.dialect = SequelizeDialects.mysql,
    super.pool,
    super.logging,
  });

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "ssl": ssl, "dialect": dialect.value};
  }
}
