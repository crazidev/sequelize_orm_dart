import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:sequelize_dart/src/model/model_value/model_value.dart';
import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/query_engine/query_engine_interface.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_js.dart';

@JS('Array.isArray')
external bool _isJsArray(JSAny? value);

class QueryEngine extends QueryEngineInterface {
  @override
  Future<List<Map<String, dynamic>>> findAll({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    final options = _convertQueryOptions(
      query?.toJson(),
      sequelize as JSObject?,
    );
    final res = await (model as SequelizeModel).findAll(options).toDart;

    final List<dynamic> data = res.toDart;

    return data.map((value) {
      final modelValue = value as ModelValue;
      final json = modelValue.toJSON() as JSObject;
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
    final options = _convertQueryOptions(
      query?.toJson(),
      sequelize as JSObject?,
    );
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

  @override
  Future<int> count({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    final options = _convertQueryOptions(
      query?.toJson(),
      sequelize as JSObject?,
    );
    final res = await (model as SequelizeModel).count(options).toDart;

    final result = res.dartify();
    if (result is int) {
      return result;
    }
    if (result is num) {
      return result.toInt();
    }
    throw Exception(
      'Invalid response format from count: expected int, got ${result.runtimeType}',
    );
  }

  @override
  Future<num?> max({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    final options = _convertQueryOptions(
      query?.toJson(),
      sequelize as JSObject?,
    );
    final res = await (model as SequelizeModel)
        .max(column.toJS, options)
        .toDart;

    if ((res as JSAny?).isUndefinedOrNull) {
      return null;
    }

    final result = res.dartify();
    if (result is num) {
      return result;
    }
    // Handle string conversion (some databases return max as string)
    if (result is String) {
      final num? parsed = num.tryParse(result);
      if (parsed != null) {
        return parsed;
      }
    }
    throw Exception(
      'Invalid response format from max: expected num or null, got ${result.runtimeType}',
    );
  }

  @override
  Future<num?> min({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    final options = _convertQueryOptions(
      query?.toJson(),
      sequelize as JSObject?,
    );
    final res = await (model as SequelizeModel)
        .min(column.toJS, options)
        .toDart;

    if ((res as JSAny?).isUndefinedOrNull) {
      return null;
    }

    final result = res.dartify();
    if (result is num) {
      return result;
    }
    // Handle string conversion (some databases return min as string)
    if (result is String) {
      final num? parsed = num.tryParse(result);
      if (parsed != null) {
        return parsed;
      }
    }
    throw Exception(
      'Invalid response format from min: expected num or null, got ${result.runtimeType}',
    );
  }

  @override
  Future<num?> sum({
    required String modelName,
    required String column,
    Query? query,
    dynamic sequelize,
    dynamic model,
  }) async {
    final options = _convertQueryOptions(
      query?.toJson(),
      sequelize as JSObject?,
    );
    final res = await (model as SequelizeModel)
        .sum(column.toJS, options)
        .toDart;

    if ((res as JSAny?).isUndefinedOrNull) {
      return null;
    }

    final result = res.dartify();
    if (result is num) {
      return result;
    }
    // Handle string conversion (some databases return sum as string)
    if (result is String) {
      final num? parsed = num.tryParse(result);
      if (parsed != null) {
        return parsed;
      }
    }
    throw Exception(
      'Invalid response format from sum: expected num or null, got ${result.runtimeType}',
    );
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

@JS('Array')
external JSFunction get _jsArray;

JSObject _createPureArray() => _jsArray.callAsConstructor() as JSObject;

/// Converts a SQL expression from Dart format to Sequelize format
JSAny? _convertSqlExpression(Map<String, dynamic> expr) {
  final type = expr['__type'];
  if (type == null) return null;

  switch (type) {
    case 'fn':
      final fnName = expr['fn'] as String;
      final args = (expr['args'] as List?) ?? [];

      final sqlFn = Sql.getProperty('fn'.toJS) as JSFunction;
      final jsArgs = _createPureArray();
      jsArgs.callMethod('push'.toJS, fnName.toJS);
      for (final arg in args) {
        final jsArg = _toJsValue(arg);
        if (jsArg != null) {
          jsArgs.callMethod('push'.toJS, jsArg);
        }
      }

      return sqlFn.callMethod('apply'.toJS, Sql, jsArgs);
    case 'col':
      return Sql.col(expr['col'] as String);
    case 'literal':
      return Sql.literal(expr['value'] as String);
    case 'attribute':
      return Sql.attribute(expr['attribute'] as String);
    case 'identifier':
      return Sql.identifier(expr['identifier'] as String);
    case 'cast':
      return Sql.cast(_toJsValue(expr['expression'])!, expr['type'] as String);
    case 'random':
      return Sql.fn('RANDOM');
    default:
      return null;
  }
}

/// Hoist order and group from joined includes to the top level
void _hoistIncludeOptions(JSObject options) {
  final include = options.getProperty('include'.toJS);
  if (include == null || include.isUndefinedOrNull) return;

  void walk(JSAny includeAny, List<String> path) {
    final List<JSAny> items = _isJsArray(includeAny)
        ? (includeAny as JSArray).toDart.cast<JSAny>()
        : [includeAny];

    for (final itemAny in items) {
      if (itemAny is! JSObject) continue;
      final item = itemAny;

      final association =
          (item.getProperty('as'.toJS) ?? item.getProperty('association'.toJS))
                  ?.dartify()
              as String?;
      if (association == null) continue;

      final currentPath = [...path, association];

      // Hoist order if not separate
      final order = item.getProperty('order'.toJS);
      final separate = item.getProperty('separate'.toJS)?.dartify() == true;

      if (order != null && !order.isUndefinedOrNull && !separate) {
        var topOrder = options.getProperty('order'.toJS);
        if (topOrder == null || topOrder.isUndefinedOrNull) {
          topOrder = _createPureArray();
          options.setProperty('order'.toJS, topOrder);
        } else if (!_isJsArray(topOrder as JSAny?)) {
          final existingOrder = topOrder;
          topOrder = _createPureArray();
          (topOrder as JSObject).callMethod('push'.toJS, existingOrder);
          options.setProperty('order'.toJS, topOrder);
        }

        final itemOrders = _isJsArray(order)
            ? (order as JSArray).toDart.cast<JSAny>()
            : [order];

        bool isSingleOrder = false;
        if (_isJsArray(order)) {
          final arr = order as JSArray;
          if (arr.length == 2) {
            final dir = arr.getProperty(1.toJS)?.dartify();
            if (dir is String) {
              final d = dir.toUpperCase();
              if (d == 'ASC' || d == 'DESC') isSingleOrder = true;
            }
          }
        }

        final List<JSAny> ordersToHoist = (isSingleOrder || !_isJsArray(order))
            ? [order]
            : (order as JSArray).toDart.cast<JSAny>();

        for (final o in ordersToHoist) {
          final newOrder = _createPureArray();
          for (final p in currentPath) {
            newOrder.callMethod('push'.toJS, p.toJS);
          }
          if (_isJsArray(o)) {
            final oArr = o as JSArray;
            for (var i = 0; i < oArr.length; i++) {
              newOrder.callMethod('push'.toJS, oArr.getProperty(i.toJS)!);
            }
          } else {
            newOrder.callMethod('push'.toJS, o);
          }
          (topOrder as JSObject).callMethod('push'.toJS, newOrder);
        }
        item.delete('order'.toJS);
      }

      // Hoist group if not separate
      final group = item.getProperty('group'.toJS);
      if (group != null && !group.isUndefinedOrNull && !separate) {
        var topGroup = options.getProperty('group'.toJS);
        if (topGroup == null || topGroup.isUndefinedOrNull) {
          topGroup = _createPureArray();
          options.setProperty('group'.toJS, topGroup);
        } else if (!_isJsArray(topGroup as JSAny?)) {
          final existingGroup = topGroup;
          topGroup = _createPureArray();
          (topGroup as JSObject).callMethod('push'.toJS, existingGroup);
          options.setProperty('group'.toJS, topGroup);
        }

        final itemGroups = _isJsArray(group)
            ? (group as JSArray).toDart.cast<JSAny>()
            : [group];
        for (final g in itemGroups) {
          final newGroup = _createPureArray();
          for (final p in currentPath) {
            newGroup.callMethod('push'.toJS, p.toJS);
          }
          if (_isJsArray(g)) {
            final gArr = g as JSArray;
            for (var i = 0; i < gArr.length; i++) {
              newGroup.callMethod('push'.toJS, gArr.getProperty(i.toJS)!);
            }
          } else {
            newGroup.callMethod('push'.toJS, g);
          }
          (topGroup as JSObject).callMethod('push'.toJS, newGroup);
        }
        item.delete('group'.toJS);
      }

      final nestedInclude = item.getProperty('include'.toJS);
      if (nestedInclude != null && !nestedInclude.isUndefinedOrNull) {
        walk(nestedInclude, currentPath);
      }
    }
  }

  walk(include, []);
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
    final jsArray = _createPureArray();
    for (final item in value) {
      final jsItem = _toJsValue(item);
      if (jsItem != null) {
        jsArray.callMethod('push'.toJS, jsItem);
      }
    }
    return jsArray;
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    if (map.containsKey('__type')) {
      final sqlExpr = _convertSqlExpression(map);
      if (sqlExpr != null) return sqlExpr;
    }

    final jsObj = JSObject();
    for (final entry in map.entries) {
      final key = entry.key;
      final val = _toJsValue(entry.value);
      if (val != null) {
        jsObj[key] = val;
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
        final list = value.map((item) {
          if (item is Map) {
            return _convertWhereClause(Map<String, dynamic>.from(item));
          } else {
            return _toJsValue(item) as JSObject;
          }
        }).toList();
        result.setProperty(opSymbol, list.toJS);
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
            final val = _toJsValue(opValue);
            if (val != null) {
              converted.setProperty(opSym, val);
            }
          } else {
            // Keep unrecognized keys as-is
            final val = _toJsValue(opValue);
            if (val != null) {
              converted[opKey] = val;
            }
          }
        }
        result[key] = converted;
      } else {
        // Not an operator object, recurse into it
        result[key] = _convertWhereClause(mapValue);
      }
    } else {
      // Simple equality (primitive value)
      final val = _toJsValue(value);
      if (val != null) {
        result[key] = val;
      }
    }
  }

  return result;
}

JSObject? _convertQueryOptions(
  Map<String, dynamic>? options,
  JSObject? sequelize,
) {
  if (options == null) {
    return null;
  }

  final result = JSObject();

  for (final entry in options.entries) {
    final key = entry.key;
    final value = entry.value;

    if (value == null) continue;

    if (key == 'where' && value is Map) {
      result['where'] = _convertWhereClause(Map<String, dynamic>.from(value));
    } else if (key == 'include' && value is List) {
      final jsIncludeList = value
          .map((item) {
            if (item is Map) {
              return _convertQueryOptions(
                Map<String, dynamic>.from(item),
                null,
              );
            } else {
              return _toJsValue(item) as JSObject?;
            }
          })
          .where((i) => i != null)
          .cast<JSObject>()
          .toList();

      result['include'] = jsIncludeList.toJS;
    } else {
      // Copy other options as-is using _toJsValue
      final val = _toJsValue(value);
      if (val != null) {
        result[key] = val;
      }
    }
  }

  if (sequelize != null) {
    final hoist =
        sequelize.getProperty('hoistIncludeOptions'.toJS).dartify() == true;
    if (hoist) {
      _hoistIncludeOptions(result);
    }
  }

  return result;
}
