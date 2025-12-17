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
  void hasOne(ModelInterface model) {
    print('✅ Adding hasOne relationship to: $model');
    (sequelizeModel as SequelizeModel).hasOne(
      model.sequelizeModel as SequelizeModel,
      {
            'foreignKey': 'userId',
          }.jsify()
          as JSObject,
    );
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
  /// The base implementation accepts a function that takes a ModelQuery and returns a Query.
  Future<List<T>> findAll(Query Function(dynamic) builder) {
    final query = builder(null);
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
  /// The base implementation accepts a function that takes a ModelQuery and returns a Query.
  Future<T?> findOne(Query Function(dynamic) builder) {
    final query = builder(null);
    return QueryEngine().findOne(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<T?>;
  }
}
