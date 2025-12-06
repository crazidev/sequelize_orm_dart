import 'package:sequelize_dart/src/sequelize/sequelize.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

abstract class ModelInterface<T> {
  late Sequelize sequelize;
  late String name;
  late dynamic sequelizeInstance;
  late dynamic sequelizeModel;

  /// Define the model in Sequelize
  ModelInterface<T> define(String modelName, Object sequelize);
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
