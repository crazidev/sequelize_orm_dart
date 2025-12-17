import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/model/model_interface.dart';

abstract class Model<T> extends ModelInterface {
  @override
  ModelInterface define(String modelName, Object sequelize) {
    throw UnimplementedError();
  }

  @override
  Future<void> associateModel() async {
    throw UnimplementedError();
  }

  @override
  Future<Association> hasOne(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Association> hasMany(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  }) async {
    throw UnimplementedError();
  }

  /// Get model attributes for Sequelize
  List<ModelAttributes> getAttributes();

  /// Convert attributes to JSON for Sequelize
  Map<String, Map<String, dynamic>> getAttributesJson();

  /// Get model options for Sequelize
  Map<String, dynamic> getOptionsJson();
}
