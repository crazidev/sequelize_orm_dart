import 'package:sequelize_dart/src/association/association_model.dart';
import 'package:sequelize_dart/src/sequelize/sequelize.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

abstract class ModelInterface<T> {
  late Sequelize sequelize;
  late String name;
  late dynamic sequelizeInstance;
  late dynamic sequelizeModel;

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
}

/// Extension to add toJson to ModelAttributes for JS conversion
extension ModelAttributesJson on ModelAttributes {
  Map<String, Map<String, dynamic>> toJson() {
    return {
      name: {
        'type': type.name,
        'notNull': notNull,
        'primaryKey': primaryKey,
        'autoIncrement': autoIncrement,
        'defaultValue': defaultValue,
      },
    };
  }
}
