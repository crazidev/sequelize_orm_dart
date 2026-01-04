import 'package:sequelize_dart/src/query/association/include_builder.dart';
import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/query/query_attributes.dart';
import 'package:sequelize_dart/src/query/query/query_interface.dart';
import 'package:sequelize_dart/src/query/sql.dart';

export 'package:sequelize_dart/src/query/association/association_reference.dart';
export 'package:sequelize_dart/src/query/association/include_builder.dart';
export 'package:sequelize_dart/src/query/association/include_helper.dart';

export 'query_attributes.dart';

class Query extends QueryInterface {
  final QueryOperator? where;
  final List<IncludeBuilder>?
  include; // Type-safe includes with infinite nesting support
  final dynamic order;
  final dynamic group;
  final int? limit;
  final int? offset;
  final QueryAttributes? attributes;

  Query({
    this.where,
    this.include,
    this.order,
    this.group,
    this.limit,
    this.offset,
    this.attributes,
  });

  /// Create a Query from callbacks
  /// This is used internally by findAll/findOne to resolve callbacks
  factory Query.fromCallbacks({
    Function? where,
    Function? include,
    dynamic columns,
    dynamic includeHelper,
    dynamic order,
    dynamic group,
    int? limit,
    int? offset,
    QueryAttributes? attributes,
  }) {
    return Query(
      where: where != null && columns != null
          ? where(columns) as QueryOperator
          : null,
      include: include != null && includeHelper != null
          ? (include(includeHelper) as List).cast<IncludeBuilder>()
          : null,
      order: order,
      group: group,
      limit: limit,
      offset: offset,
      attributes: attributes,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // Convert include to JSON format
    // Supports infinite levels of nesting through recursive IncludeBuilder.toJson()
    final List<Map<String, dynamic>>? includeJson = include
        ?.map((inc) => inc.toJson())
        .toList();

    return {
      'where': where?.toJson(),
      'include': includeJson,
      'order': _serializeExpression(order),
      'group': _serializeExpression(group),
      'limit': limit,
      'offset': offset,
      if (attributes != null) 'attributes': attributes!.toJson()['value'],
    };
  }

  dynamic _serializeExpression(dynamic expr) {
    if (expr is SqlExpression) {
      return expr.toJson();
    } else if (expr is List) {
      return expr.map(_serializeExpression).toList();
    } else if (expr is Map) {
      return expr.map(
        (key, value) => MapEntry(key, _serializeExpression(value)),
      );
    }
    return expr;
  }
}
