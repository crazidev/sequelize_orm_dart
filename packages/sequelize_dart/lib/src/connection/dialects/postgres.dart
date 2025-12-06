import 'package:sequelize_dart/src/connection/core_options.dart';

class PostgressConnection extends SequelizeCoreOptions {
  final String? schema;
  final bool ssl;
  final SequelizeDialects dialect;

  PostgressConnection({
    required super.url,
    required super.logging,
    this.schema,
    this.ssl = false,
    this.dialect = SequelizeDialects.postgres,
    super.pool,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "schema": schema,
      "ssl": ssl,
      "dialect": dialect.value,
    };
  }
}

