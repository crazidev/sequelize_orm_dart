// ignore_for_file: avoid_print

import 'package:sequelize_dart/src/association/association_model.dart';
import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/query_engine/query_engine.dart';
import 'package:sequelize_dart/src/sequelize/sequelize.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

/// Unified Model implementation for both Dart VM and dart2js.
/// Both platforms now use the bridge pattern, so the implementation is identical.
abstract class Model<T> extends ModelInterface {
  @override
  ModelInterface define(String modelName, Object sq) {
    sequelizeInstance = sq;
    name = modelName;
    sequelize = sq as Sequelize;
    sequelizeModel = <String, dynamic>{};

    print('✅ Defining model: $modelName');
    return this;
  }

  /// Base implementation of associateModel - override in generated models
  /// Called by Sequelize.initialize() after all models are defined
  @override
  Future<void> associateModel() async {
    // Base implementation does nothing
    // Generated model classes override this to set up associations
  }

  @override
  Future<Association> hasOne(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  }) async {
    print('✅ $name hasOne ${model.name}');

    await sequelize.bridge.call('associateModel', {
      'sourceModel': name,
      'targetModel': model.name,
      'associationType': 'hasOne',
      'options': {
        'foreignKey': foreignKey,
        'as': as,
        'sourceKey': sourceKey,
      },
    });

    return Association();
  }

  @override
  Future<Association> hasMany(
    ModelInterface model, {
    String? foreignKey,
    String? as,
    String? sourceKey,
  }) async {
    print('✅ $name hasMany ${model.name}');

    await sequelize.bridge.call('associateModel', {
      'sourceModel': name,
      'targetModel': model.name,
      'associationType': 'hasMany',
      'options': {
        'foreignKey': foreignKey,
        'as': as,
        'sourceKey': sourceKey,
      },
    });

    return Association();
  }

  /// Get model attributes for Sequelize
  List<ModelAttributes> getAttributes();

  /// Convert attributes to JSON for Sequelize
  Map<String, Map<String, dynamic>> getAttributesJson();

  /// Get model options for Sequelize
  Map<String, dynamic> getOptionsJson();

  /// Find all records matching the query
  Future<List<T>> findAll({
    covariant dynamic where,
    covariant dynamic include,
    dynamic order,
    dynamic group,
    int? limit,
    int? offset,
    QueryAttributes? attributes,
  }) {
    final query = Query.fromCallbacks(
      where: where,
      include: include,
      order: order,
      group: group,
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
  Future<T?> findOne({
    covariant dynamic where,
    covariant dynamic include,
    dynamic order,
    dynamic group,
    QueryAttributes? attributes,
  }) {
    final query = Query.fromCallbacks(
      where: where,
      include: include,
      order: order,
      group: group,
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

  /// Create a new record
  Future<T> create(covariant dynamic data) {
    // Convert data to Map if it's not already (for Create classes)
    final Map<String, dynamic> dataMap = data is Map<String, dynamic>
        ? data
        : (data as dynamic).toJson();

    return QueryEngine().create(
          modelName: name,
          data: dataMap,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<T>;
  }

  /// Count records matching the query
  Future<int> count({covariant dynamic where}) {
    final query = Query.fromCallbacks(where: where);
    return QueryEngine().count(
      modelName: name,
      query: query,
      sequelize: sequelizeInstance,
      model: sequelizeModel,
    );
  }

  /// Find the maximum value of a column
  Future<num?> max(covariant dynamic columnFn, {covariant dynamic where});

  /// Find the minimum value of a column
  Future<num?> min(covariant dynamic columnFn, {covariant dynamic where});

  /// Sum values of a column
  Future<num?> sum(covariant dynamic columnFn, {covariant dynamic where});
}
