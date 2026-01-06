import 'package:sequelize_dart/src/query/query/query.dart';

/// Abstract interface for query engines
/// This interface defines the contract that all query engines must implement
/// regardless of whether they're running in JS or Dart VM environment
abstract class QueryEngineInterface {
  /// Find all records matching the query
  Future<dynamic> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Find one record matching the query
  Future<dynamic> findOne({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Create a new record
  Future<dynamic> create({
    required String modelName,
    required Map<String, dynamic> data,
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
  Future<List<Map<String, dynamic>>> increment({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });

  /// Decrement numeric column values
  Future<List<Map<String, dynamic>>> decrement({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });
}
