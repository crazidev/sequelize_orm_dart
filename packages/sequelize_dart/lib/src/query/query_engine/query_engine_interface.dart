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
}
