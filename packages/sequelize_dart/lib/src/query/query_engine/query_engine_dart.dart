import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_dart.dart';
import 'package:sequelize_dart/src/sequelize/bridge_client.dart';

import 'query_engine_interface.dart';

class QueryEngine extends QueryEngineInterface {
  @override
  Future<List<Map<String, dynamic>>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    if (sequelize == null) {
      throw Exception('Sequelize instance is required');
    }

    if (sequelize is! Sequelize) {
      throw Exception('Invalid Sequelize instance type');
    }

    final bridge = sequelize.bridge;

    if (!bridge.isConnected) {
      throw Exception('Bridge is not connected');
    }

    try {
      final result = await bridge.call('findAll', {
        'model': modelName,
        'options': query?.toJson(),
      });

      if (result is List) {
        return result.map((item) => item as Map<String, dynamic>).toList();
      }

      throw Exception('Invalid response format from bridge');
    } catch (e) {
      if (e is BridgeException) {
        rethrow;
      }
      throw Exception('Failed to execute findAll: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> findOne({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    if (sequelize == null) {
      throw Exception('Sequelize instance is required');
    }

    if (sequelize is! Sequelize) {
      throw Exception('Invalid Sequelize instance type');
    }

    final bridge = sequelize.bridge;

    if (!bridge.isConnected) {
      throw Exception('Bridge is not connected');
    }

    try {
      final result = await bridge.call('findOne', {
        'model': modelName,
        'options': query?.toJson(),
      });

      if (result == null) {
        return null;
      }

      if (result is Map) {
        return result as Map<String, dynamic>;
      }

      throw Exception('Invalid response format from bridge');
    } catch (e) {
      if (e is BridgeException) {
        rethrow;
      }
      throw Exception('Failed to execute findOne: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> create({
    required String modelName,
    required Map<String, dynamic> data,
    dynamic sequelize,
    dynamic model,
  }) async {
    throw UnimplementedError();
  }
}
