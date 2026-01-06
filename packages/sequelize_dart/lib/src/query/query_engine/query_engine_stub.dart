import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/query_engine/query_engine_interface.dart';

class QueryEngine extends QueryEngineInterface {
  @override
  Future<List<Map<String, dynamic>>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> findOne({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> create({
    required String modelName,
    required Map<String, dynamic> data,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<int> count({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<num?> max({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<num?> min({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<num?> sum({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> increment({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> decrement({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) {
    throw UnimplementedError();
  }
}
