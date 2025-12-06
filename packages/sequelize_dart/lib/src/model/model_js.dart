import 'dart:js_interop';

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_js.dart';

abstract class Model<T> extends ModelInterface {
  @override
  ModelInterface define(String modelName, Object sq) {
    print('✅ Defining model: $modelName');
    var sequelize = sq as SequelizeJS;

    SequelizeModel model = sequelize.define(
      modelName.toJS,
      getAttributesJson().jsify() as JSObject,
      getOptionsJson().jsify() as JSObject,
    );

    sequelizeInstance = sequelize;
    sequelizeModel = model;
    return this;
  }

  /// Get model attributes for Sequelize
  List<ModelAttributes> getAttributes();

  /// Convert attributes to JSON for Sequelize
  Map<String, Map<String, dynamic>> getAttributesJson();

  /// Get model options for Sequelize
  Map<String, dynamic> getOptionsJson();

  Future<List<T>> findAll([Query? query]) {
    return QueryEngine().findAll(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<List<T>>;
  }

  Future<T?> findOne([Query? query]) {
    return QueryEngine().findOne(
          modelName: name,
          query: query,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<T?>;
  }
}
