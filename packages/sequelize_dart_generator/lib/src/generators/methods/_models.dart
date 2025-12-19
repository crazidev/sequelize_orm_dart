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
  });
}

class _AssociationInfo {
  final String associationType; // 'hasOne' or 'hasMany'
  final String modelClassName;
  final String fieldName;
  final String? foreignKey;
  final String? as;
  final String? sourceKey;

  _AssociationInfo({
    required this.associationType,
    required this.modelClassName,
    required this.fieldName,
    this.foreignKey,
    this.as,
    this.sourceKey,
  });
}
