import 'package:sequelize_dart/src/connection/core_options.dart';

class MysqlConnection extends SequelizeCoreOptions {
  final bool ssl;
  final SequelizeDialects dialect;

  MysqlConnection({
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

