import 'package:sequelize_dart/src/association/association_model.dart';
import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/query_engine/query_engine.dart';
import 'package:sequelize_dart/src/sequelize/sequelize.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

abstract class Model<T> extends ModelInterface {
  @override
  ModelInterface define(String modelName, Object sq) {
    // Store references
    sequelizeInstance = sq;
    name = modelName;
    sequelize = sq as Sequelize;

    // Set sequelizeModel to empty object for Dart VM
    // In JS, this would be the actual Sequelize model, but in Dart we just need it initialized
    sequelizeModel = <String, dynamic>{};

    // Register model with Sequelize
    // Note: This is handled in addModels, so we don't call it here
    // to avoid double registration

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

    await sequelize.bridge?.call('associateModel', {
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

    await sequelize.bridge?.call('associateModel', {
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
  ///
  /// Generated model classes will override this method to accept a typed query builder.
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
  ///
  /// Generated model classes will override this method to accept a typed query builder.
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
  Future<T> create(Map<String, dynamic> data) {
    return QueryEngine().create(
          modelName: name,
          data: data,
          sequelize: sequelizeInstance,
          model: sequelizeModel,
        )
        as Future<T>;
  }
}
