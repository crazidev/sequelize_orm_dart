import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

abstract class Model<T> extends ModelInterface {
  @override
  ModelInterface define(String modelName, Object sequelize) {
    throw UnimplementedError();
  }

  /// Get model attributes for Sequelize
  List<ModelAttributes> getAttributes();

  /// Convert attributes to JSON for Sequelize
  Map<String, Map<String, dynamic>> getAttributesJson();

  /// Get model options for Sequelize
  Map<String, dynamic> getOptionsJson();
}
