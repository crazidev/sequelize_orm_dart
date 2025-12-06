import 'package:sequelize_dart_annotations/src/enums.dart';

/// Marks a class as a database table
class Table {
  /// The name of the table in the database
  final String tableName;

  /// Use snake_case for column names
  final bool underscored;

  /// Timestamps (createdAt, updatedAt)
  final bool timestamps;

  const Table({
    required this.tableName,
    this.underscored = true,
    this.timestamps = true,
  });
}

/// Defines a database column
class Column {
  /// Database column name. Defaults to field name (or snake_case if underscored)
  final String? name;

  /// SQL data type. If null, inferred from Dart type
  final DataType? type;

  /// Allow null values
  final bool? allowNull;

  /// Default value
  final dynamic defaultValue;

  /// Unique constraint
  final bool? unique;

  /// Comment for documentation
  final String? comment;

  const Column({
    this.name,
    this.type,
    this.allowNull,
    this.defaultValue,
    this.unique,
    this.comment,
  });
}
