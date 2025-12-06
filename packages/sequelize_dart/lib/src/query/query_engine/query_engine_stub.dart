import 'package:sequelize_dart/src/query/query/query.dart';
import 'query_engine_interface.dart';

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
}

