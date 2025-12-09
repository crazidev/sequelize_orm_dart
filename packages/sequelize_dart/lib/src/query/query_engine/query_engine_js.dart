import 'dart:convert';
import 'dart:js_interop';

import 'package:sequelize_dart/src/model/model_value/model_value.dart';
import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/query_engine/query_engine_interface.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_js.dart';

/// Recursively converts DateTime objects to ISO strings for JSON encoding
dynamic _convertToJsonEncodable(dynamic value) {
  if (value is DateTime) {
    return value.toIso8601String();
  } else if (value is Map) {
    return value.map((key, val) => MapEntry(key, _convertToJsonEncodable(val)));
  } else if (value is List) {
    return value.map((item) => _convertToJsonEncodable(item)).toList();
  }
  return value;
}

class QueryEngine extends QueryEngineInterface {
  @override
  Future<List<Map<String, dynamic>>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    final res = await (model as SequelizeModel)
        .findAll(query?.toJson().jsify() as JSObject)
        .toDart;

    final List<ModelValue> data = res.toDart as List<ModelValue>;

    return data.map((value) {
      final dartified = value.dataValues.dartify();
      final converted = _convertToJsonEncodable(dartified);
      final q = jsonDecode(jsonEncode(converted));

      return q as Map<String, dynamic>;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> findOne({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    final res = await (model as SequelizeModel)
        .findOne(query?.toJson().jsify() as JSObject)
        .toDart;

    if (res == null) {
      return null;
    }

    final ModelValue data = res as ModelValue;
    final dartified = data.dataValues.dartify();
    final converted = _convertToJsonEncodable(dartified);
    return jsonDecode(jsonEncode(converted)) as Map<String, dynamic>;
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
