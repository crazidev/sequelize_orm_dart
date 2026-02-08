part of '../../sequelize_model_generator.dart';

class _FieldInfo {
  final String fieldName;
  final String name;
  final String dataType;
  final String dartType;
  final bool autoIncrement;
  final bool primaryKey;
  final bool? allowNull;
  final Object? defaultValue;
  final String? validateCode; // Generated code for ValidateOption
  final String? columnName;
  final String? comment;
  final Object? unique; // bool | String | UniqueOption
  final Object? index; // bool | String | IndexOption
  final bool? autoIncrementIdentity;
  final bool unsigned;
  final bool zerofill;
  final bool binary;

  /// Whether this field has a default value (via @Default decorator or defaultValue in ColumnDefinition).
  bool get hasDefaultValue => defaultValue != null;

  _FieldInfo({
    required this.fieldName,
    required this.name,
    required this.dataType,
    required this.dartType,
    this.autoIncrement = false,
    this.primaryKey = false,
    this.allowNull,
    this.defaultValue,
    this.validateCode,
    this.columnName,
    this.comment,
    this.unique,
    this.index,
    this.autoIncrementIdentity,
    this.unsigned = false,
    this.zerofill = false,
    this.binary = false,
  });
}

class _AssociationInfo {
  final String associationType; // 'hasOne' | 'hasMany' | 'belongsTo'
  final String modelClassName;
  final String fieldName;
  final String? foreignKey;
  final String? as;
  final String? sourceKey;
  final String? targetKey;
  final String? singularName;
  final String? pluralName;

  _AssociationInfo({
    required this.associationType,
    required this.modelClassName,
    required this.fieldName,
    this.foreignKey,
    this.as,
    this.sourceKey,
    this.targetKey,
    this.singularName,
    this.pluralName,
  });
}
