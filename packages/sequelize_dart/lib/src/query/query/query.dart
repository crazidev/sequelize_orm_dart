import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/query/query_attributes.dart';
import 'package:sequelize_dart/src/query/query/query_interface.dart';

export 'query_attributes.dart';

class Query extends QueryInterface {
  final QueryOperator? where;
  final dynamic include;
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
    return {
      'where': where?.toJson(),
      'include': include,
      'order': order,
      'limit': limit,
      'offset': offset,
      'attributes': attributes?.toJson()['value'],
    };
  }
}
