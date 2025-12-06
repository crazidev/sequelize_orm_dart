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

    return this;
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
  ///
  /// Example usage (in generated classes):
  /// ```dart
  /// final users = await Users.instance.findAll((q) => Query(
  ///   where: q.id.greaterThan(1),
  /// ));
  /// ```
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
  ///
  /// Example usage (in generated classes):
  /// ```dart
  /// final user = await Users.instance.findOne((q) => Query(
  ///   where: q.id.eq(1),
  /// ));
  /// ```
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
