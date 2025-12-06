import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'query_interface.dart';

/// Query options for Sequelize operations (Dart VM version)
class Query extends QueryInterface {
  final QueryOperator? where;
  final List<dynamic>? include;
  final List<List<String>>? order;
  final int? limit;
  final int? offset;

  Query({
    this.where,
    this.include,
    this.order,
    this.limit,
    this.offset,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      if (where != null) 'where': where!.toJson(),
      if (include != null) 'include': include,
      if (order != null) 'order': order,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    };
  }
}
