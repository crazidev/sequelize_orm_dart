import 'package:sequelize_dart/src/query/association/include_builder.dart';
import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/query/query_attributes.dart';
import 'package:sequelize_dart/src/query/query/query_interface.dart';

export 'package:sequelize_dart/src/query/association/association_reference.dart';
export 'package:sequelize_dart/src/query/association/include_builder.dart';

export 'query_attributes.dart';

class Query extends QueryInterface {
  final QueryOperator? where;
  final List<IncludeBuilder>?
  include; // Type-safe includes with infinite nesting support
  final List<List<String>>? order;
  final int? limit;
  final int? offset;
  final QueryAttributes? attributes;

  Query({
    this.where,
    this.include,
    this.order,
    this.limit,
    this.offset,
    this.attributes,
  });

  @override
  Map<String, dynamic> toJson() {
    // Convert include to JSON format
    // Supports infinite levels of nesting through recursive IncludeBuilder.toJson()
    final List<Map<String, dynamic>>? includeJson = include
        ?.map((inc) => inc.toJson())
        .toList();

    return {
      if (where != null) 'where': where!.toJson(),
      if (includeJson != null) 'include': includeJson,
      if (order != null) 'order': order,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
      if (attributes != null) 'attributes': attributes!.toJson()['value'],
    };
  }
}

class IncludeQuery extends Query {
  // Include-specific options
  final bool? separate;
  final bool? required;
  final bool? right;
  final Map<String, dynamic>? through;

  IncludeQuery({
    super.where,
    super.include,
    super.order,
    super.limit,
    super.offset,
    super.attributes,
    this.separate,
    this.required,
    this.right,
    this.through,
  });

  @override
  Map<String, dynamic> toJson() {
    final result = super.toJson();
    if (separate != null) result['separate'] = separate;
    if (required != null) result['required'] = required;
    if (right != null) result['right'] = right;
    if (through != null) result['through'] = through;
    return result;
  }
}
