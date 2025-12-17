import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:sequelize_dart/src/model/model_value/model_value.dart';
import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/query_engine/query_engine_interface.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_js.dart';

class QueryEngine extends QueryEngineInterface {
  @override
  Future<List<Map<String, dynamic>>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    final options = _convertQueryOptions(query?.toJson());
    final res = await (model as SequelizeModel).findAll(options).toDart;

    final List<ModelValue> data = res.toDart as List<ModelValue>;

    return data.map((value) {
      final json = value.toJSON() as JSObject;
      final converted = _convertToJsonEncodable(json.dartify());
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
    final options = _convertQueryOptions(query?.toJson());
    final res = await (model as SequelizeModel).findOne(options).toDart;

    if (res == null) {
      return null;
    }

    final ModelValue data = res as ModelValue;
    // Use toJSON() for consistency with findAll - includes nested associations
    final json = data.toJSON() as JSObject;
    final converted = _convertToJsonEncodable(json.dartify());
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

/// Recursively converts DateTime objects to ISO strings for JSON encoding
dynamic _convertToJsonEncodable(dynamic value) {
  if (value is DateTime) {
    return value.toIso8601String();
  } else if (value is Map) {
    return value.map((key, val) => MapEntry(key, _convertToJsonEncodable(val)));
  } else if (value is List) {
    return value.map((item) => _convertToJsonEncodable(item)).toList();
  } else if (value is JSObject) {
    final toJsJson = (value as ModelValue).toJSON();
    final toDartJson = jsonEncode((toJsJson as JSObject).dartify());
    return jsonDecode(toDartJson);
  }
  return value;
}

/// Gets the Sequelize Op symbol for a given string operator
JSSymbol? _getOpSymbol(String opKey) {
  final op = Op;
  return switch (opKey) {
    // Logical operators
    '\$and' => op.and,
    '\$or' => op.or,
    '\$not' => op.not,
    // Basic comparison operators
    '\$eq' => op.eq,
    '\$ne' => op.ne,
    '\$is' => op.isOp,
    '\$isNot' => op.isNot,
    // Number comparison operators
    '\$gt' => op.gt,
    '\$gte' => op.gte,
    '\$lt' => op.lt,
    '\$lte' => op.lte,
    '\$between' => op.between,
    '\$notBetween' => op.notBetween,
    // List operators
    '\$in' => op.inOp,
    '\$notIn' => op.notIn,
    '\$all' => op.all,
    '\$any' => op.any,
    // String operators
    '\$like' => op.like,
    '\$notLike' => op.notLike,
    '\$startsWith' => op.startsWith,
    '\$endsWith' => op.endsWith,
    '\$substring' => op.substring,
    '\$ilike' || '\$iLike' => op.iLike,
    '\$notILike' => op.notILike,
    // Regex operators
    '\$regexp' => op.regexp,
    '\$notRegexp' => op.notRegexp,
    '\$iRegexp' => op.iRegexp,
    '\$notIRegexp' => op.notIRegexp,
    // Other operators
    '\$col' => op.col,
    '\$match' => op.match,
    _ => null,
  };
}

/// Converts a Dart value to a pure JS value without identity hash
JSAny? _toJsValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value.toJS;
  }
  if (value is num) {
    return value.toJS;
  }
  if (value is bool) {
    return value.toJS;
  }
  if (value is List) {
    final jsArray = JSArray<JSAny?>.withLength(value.length);
    for (var i = 0; i < value.length; i++) {
      jsArray[i] = _toJsValue(value[i]);
    }
    return jsArray;
  }
  if (value is Map) {
    final jsObj = JSObject();
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is String) {
        jsObj[key] = _toJsValue(entry.value);
      }
    }
    return jsObj;
  }
  // Fallback to jsify for other types
  return (value as Object).jsify();
}

/// Converts a where clause from Dart format to Sequelize Op format
JSObject _convertWhereClause(Map<String, dynamic> where) {
  final result = JSObject();

  for (final entry in where.entries) {
    final key = entry.key;
    final value = entry.value;

    // Check if this is a logical operator ($and, $or, $not)
    final opSymbol = _getOpSymbol(key);
    if (opSymbol != null &&
        (key == '\$and' || key == '\$or' || key == '\$not')) {
      // Logical operators contain arrays of conditions
      if (value is List) {
        final jsArray = JSArray<JSObject>.withLength(value.length);
        for (var i = 0; i < value.length; i++) {
          final item = value[i];
          if (item is Map) {
            jsArray[i] = _convertWhereClause(Map<String, dynamic>.from(item));
          } else {
            jsArray[i] = _toJsValue(item) as JSObject;
          }
        }
        result.setProperty(opSymbol, jsArray);
      } else {
        result.setProperty(opSymbol, _toJsValue(value));
      }
    } else if (value is Map) {
      // This is a column with operators, e.g., { email: { $isNot: null } }
      final mapValue = Map<String, dynamic>.from(value);
      final hasOperatorKeys = mapValue.keys.any(
        (k) =>
            k.startsWith('\$') && k != '\$and' && k != '\$or' && k != '\$not',
      );

      if (hasOperatorKeys) {
        // Convert operator keys to Sequelize Op symbols
        final converted = JSObject();
        for (final opEntry in mapValue.entries) {
          final opKey = opEntry.key;
          final opValue = opEntry.value;
          final opSym = _getOpSymbol(opKey);

          if (opSym != null) {
            converted.setProperty(opSym, _toJsValue(opValue));
          } else {
            // Keep unrecognized keys as-is
            converted[opKey] = _toJsValue(opValue);
          }
        }
        result[key] = converted;
      } else {
        // Not an operator object, recurse into it
        result[key] = _convertWhereClause(mapValue);
      }
    } else {
      // Simple equality (primitive value)
      result[key] = _toJsValue(value);
    }
  }

  return result;
}

/// Converts query options from Dart format to Sequelize format with Op symbols
JSObject? _convertQueryOptions(Map<String, dynamic>? options) {
  if (options == null) {
    return null;
  }

  final result = JSObject();

  if (options['where'] != null && options['where'] is Map) {
    // Cast to Map<String, dynamic> - the keys should be strings after our changes
    final whereMap = Map<String, dynamic>.from(options['where'] as Map);
    result['where'] = _convertWhereClause(whereMap);
  }

  // Copy other options as-is using _toJsValue for clean JS objects
  if (options['include'] != null) {
    result['include'] = _toJsValue(options['include']);
  }
  if (options['order'] != null) {
    result['order'] = _toJsValue(options['order']);
  }
  if (options['limit'] != null) {
    result['limit'] = _toJsValue(options['limit']);
  }
  if (options['offset'] != null) {
    result['offset'] = _toJsValue(options['offset']);
  }
  if (options['attributes'] != null) {
    result['attributes'] = _toJsValue(options['attributes']);
  }

  return result;
}
