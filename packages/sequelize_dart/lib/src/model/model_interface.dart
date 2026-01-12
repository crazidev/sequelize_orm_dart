import 'package:sequelize_dart/src/association/association_model.dart';
import 'package:sequelize_dart/src/sequelize/sequelize.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

abstract class ModelInterface<T> {
  late Sequelize sequelize;
  late String name;
  late dynamic sequelizeInstance;
  late dynamic sequelizeModel;
  List<String> primaryKeys = [];

  /// Get primary key attribute names
  List<String> getPrimaryKeys() => primaryKeys;

  /// Define the model in Sequelize
  ModelInterface<T> define(String modelName, Object sequelize);

  /// Associate models - called after all models are defined
  /// Override in generated models to set up associations
  Future<void> associateModel();

  Future<Association> hasOne(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  });

  Future<Association> hasMany(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  });

  /// Get the query builder for this model
  /// Returns a typed query builder (generated class)
  dynamic getQueryBuilder();
}

/// Extension to add toJsonForBridge to ModelAttributes for JS conversion
/// This wraps the attribute in a map with the column name as key
extension ModelAttributesJson on ModelAttributes {
  Map<String, Map<String, dynamic>> toJsonForBridge() {
    final attr = <String, dynamic>{
      'type': type.name,
    };

    // Column name (maps to 'field' in Sequelize)
    if (columnName != null) attr['columnName'] = columnName;

    // Null constraint
    if (allowNull != null) attr['allowNull'] = allowNull;

    // Primary key and auto increment
    if (primaryKey != null) attr['primaryKey'] = primaryKey;
    if (autoIncrement != null) attr['autoIncrement'] = autoIncrement;
    if (autoIncrementIdentity != null) {
      attr['autoIncrementIdentity'] = autoIncrementIdentity;
    }

    // Default value
    if (defaultValue != null) attr['defaultValue'] = defaultValue;

    // Unique constraint
    if (unique != null) {
      if (unique is bool || unique is String) {
        attr['unique'] = unique;
      } else if (unique is UniqueOption) {
        attr['unique'] = (unique as UniqueOption).toJson();
      }
    }

    // Index
    if (index != null) {
      if (index is bool || index is String) {
        attr['index'] = index;
      } else if (index is IndexOption) {
        attr['index'] = (index as IndexOption).toJson();
      }
    }

    // Comment
    if (comment != null) attr['comment'] = comment;

    // Validation
    if (validate != null) attr['validate'] = validate!.toJson();

    return {name: attr};
  }
}
