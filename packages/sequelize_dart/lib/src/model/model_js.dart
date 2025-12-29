// ignore_for_file: avoid_print

import 'dart:js_interop';

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_js.dart';

abstract class Model<T> extends ModelInterface {
  @override
  ModelInterface define(String modelName, Object sq) {
    print('✅ Defining model: $modelName');
    final sequelize = sq as SequelizeJS;

    final SequelizeModel model = sequelize.define(
      modelName.toJS,
      getAttributesJson().jsify() as JSObject,
      getOptionsJson().jsify() as JSObject,
    );

    sequelizeInstance = sequelize;
    sequelizeModel = model;
    return this;
  }

  @override
  Future<void> associateModel() async {
    // Base implementation - empty, overridden by generated code
  }

  @override
  Future<Association> hasOne(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  }) async {
    // Check if this model has been initialized
    try {
      final _ = sequelizeModel;
    } catch (e) {
      throw StateError(
        "Model '$name' has not been initialized. Please call sequelize.addModels([$name.instance]) before setting up associations.",
      );
    }

    // Check if the target model has been initialized, if not, define it automatically
    try {
      final _ = model.sequelizeModel;
    } catch (e) {
      // Target model not initialized, define it automatically using this model's sequelize instance
      print('⚠️  Model ${model.name} not initialized, auto-defining it...');
      model.define(model.name, sequelizeInstance);
    }

    print('✅ $name hasOne ${model.name}');
    (sequelizeModel as SequelizeModel).hasOne(
      model.sequelizeModel as SequelizeModel,
      ({
            'foreignKey': foreignKey,
            'as': as,
            'sourceKey': sourceKey,
          }).jsify()
          as JSObject,
    );

    return Association();
  }

  @override
  Future<Association> hasMany(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  }) async {
    // Check if the target model has been initialized, if not, define it automatically
    try {
      final _ = model.sequelizeModel;
    } catch (e) {
      // Target model not initialized, define it automatically using this model's sequelize instance
      print('⚠️  Model ${model.name} not initialized, auto-defining it...');
      model.define(model.name, sequelizeInstance);
    }

    print('✅ $name hasMany ${model.name}');
    (sequelizeModel as SequelizeModel).hasMany(
      model.sequelizeModel as SequelizeModel,
      ({
            'foreignKey': foreignKey,
            'as': as,
            'sourceKey': sourceKey,
          }).jsify()
          as JSObject,
    );

    return Association();
  }

  /// Get model attributes for Sequelize
  List<ModelAttributes> getAttributes();

  /// Convert attributes to JSON for Sequelize
  Map<String, Map<String, dynamic>> getAttributesJson();

  /// Get model options for Sequelize
  Map<String, dynamic> getOptionsJson();

  /// Find all records matching the query
  ///
  /// Generated model classes will override this method to accept a typed query builder.
  Future<List<T>> findAll({
    covariant dynamic where,
    covariant dynamic include,
    List<List<String>>? order,
    int? limit,
    int? offset,
    QueryAttributes? attributes,
  }) {
    final query = Query.fromCallbacks(
      where: where,
      include: include,
      order: order,
      limit: limit,
      offset: offset,
      attributes: attributes,
    );
    return QueryEngine().findAll(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<List<T>>;
  }

  /// Find one record matching the query
  ///
  /// Generated model classes will override this method to accept a typed query builder.
  Future<T?> findOne({
    covariant dynamic where,
    covariant dynamic include,
    List<List<String>>? order,
    QueryAttributes? attributes,
  }) {
    final query = Query.fromCallbacks(
      where: where,
      include: include,
      order: order,
      attributes: attributes,
    );
    return QueryEngine().findOne(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<T?>;
  }
}
