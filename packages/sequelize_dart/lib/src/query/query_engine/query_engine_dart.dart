import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/query_engine/query_engine_interface.dart';
import 'package:sequelize_dart/src/sequelize/bridge_client.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_dart.dart';

class QueryEngine extends QueryEngineInterface {
  BridgeClient getBridge(dynamic sequelize) {
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

    return bridge;
  }

  @override
  Future<List<Map<String, dynamic>>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    try {
      final result = await getBridge(sequelize).call('findAll', {
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
    try {
      final result = await getBridge(sequelize).call('findOne', {
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

  @override
  Future<int> count({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    try {
      final result = await getBridge(sequelize).call('count', {
        'model': modelName,
        'options': query?.toJson(),
      });

      if (result is int) {
        return result;
      }

      if (result is num) {
        return result.toInt();
      }

      throw Exception(
        'Invalid response format from bridge: expected int, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is BridgeException) {
        rethrow;
      }
      throw Exception('Failed to execute count: $e');
    }
  }

  @override
  Future<num?> max({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    try {
      final result = await getBridge(sequelize).call('max', {
        'model': modelName,
        'column': column,
        'options': query?.toJson(),
      });

      if (result == null) {
        return null;
      }

      if (result is num) {
        return result;
      }

      throw Exception(
        'Invalid response format from bridge: expected num or null, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is BridgeException) {
        rethrow;
      }
      throw Exception('Failed to execute max: $e');
    }
  }

  @override
  Future<num?> min({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    try {
      final result = await getBridge(sequelize).call('min', {
        'model': modelName,
        'column': column,
        'options': query?.toJson(),
      });

      if (result == null) {
        return null;
      }

      if (result is num) {
        return result;
      }

      throw Exception(
        'Invalid response format from bridge: expected num or null, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is BridgeException) {
        rethrow;
      }
      throw Exception('Failed to execute min: $e');
    }
  }

  @override
  Future<num?> sum({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    try {
      final result = await getBridge(sequelize).call('sum', {
        'model': modelName,
        'column': column,
        'options': query?.toJson(),
      });

      if (result == null) {
        return null;
      }

      if (result is num) {
        return result;
      }

      throw Exception(
        'Invalid response format from bridge: expected num or null, got ${result.runtimeType}',
      );
    } catch (e) {
      if (e is BridgeException) {
        rethrow;
      }
      throw Exception('Failed to execute sum: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> increment({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    return await _executeNumericOperation(
      modelName: modelName,
      fields: fields,
      query: query,
      sequelize: sequelize,
      model: model,
      operation: 'increment',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> decrement({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    return await _executeNumericOperation(
      modelName: modelName,
      fields: fields,
      query: query,
      sequelize: sequelize,
      model: model,
      operation: 'decrement',
    );
  }

  /// Shared method for both increment and decrement operations
  Future<List<Map<String, dynamic>>> _executeNumericOperation({
    required String modelName,
    required Map<String, dynamic> fields,
    Query? query,
    dynamic sequelize,
    dynamic model,
    required String operation,
  }) async {
    try {
      final result = await getBridge(sequelize).call(operation, {
        'model': modelName,
        'fields': fields,
        'query': query?.toJson(),
      });

      if (result is List) {
        return result.map((item) => item as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (e is BridgeException) {
        rethrow;
      }
      throw Exception('Failed to execute $operation: $e');
    }
  }
}
