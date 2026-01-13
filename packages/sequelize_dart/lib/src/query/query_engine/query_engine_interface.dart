import 'package:sequelize_dart/src/model/model_instance_data.dart';
import 'package:sequelize_dart/src/query/query/query.dart';

/// Abstract interface for query engines
/// This interface defines the contract that all query engines must implement
/// regardless of whether they're running in JS or Dart VM environment
abstract class QueryEngineInterface {
  /// Find all records matching the query
  Future<List<ModelInstanceData>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Find one record matching the query
  Future<ModelInstanceData?> findOne({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Create a new record
  Future<ModelInstanceData> create({
    required String modelName,
    required Map<String, dynamic> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Create multiple records (bulk create)
  Future<List<ModelInstanceData>> bulkCreate({
    required String modelName,
    required List<Map<String, dynamic>> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Update records
  Future<int> update({
    required String modelName,
    required Map<String, dynamic> data,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Count records matching the query
  Future<int> count({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Find the maximum value of a column
  Future<num?> max({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Find the minimum value of a column
  Future<num?> min({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Sum values of a column
  Future<num?> sum({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Increment numeric column values
  Future<List<ModelInstanceData>> increment({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Decrement numeric column values
  Future<List<ModelInstanceData>> decrement({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Save an instance (INSERT for new records, UPDATE for existing)
  Future<ModelInstanceData> save({
    required String modelName,
    required Map<String, dynamic> currentData,
    Map<String, dynamic>? previousData,
    required Map<String, dynamic> primaryKeyValues,
    dynamic sequelize,
    dynamic model,
  });
}
