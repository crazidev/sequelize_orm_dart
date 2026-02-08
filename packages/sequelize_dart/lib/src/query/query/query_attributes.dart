import 'package:sequelize_dart/src/query/sql.dart';
import 'package:sequelize_dart/src/query/typed_column.dart';

enum QueryAttributesType { include, exclude }

class QueryAttributes {
  final List<dynamic> columns;
  final bool isExclude;

  QueryAttributes({
    required this.columns,
    this.isExclude = false,
  });

  factory QueryAttributes.include(List<dynamic> columns) {
    return QueryAttributes(columns: columns);
  }

  factory QueryAttributes.exclude(List<dynamic> columns) {
    return QueryAttributes(columns: columns, isExclude: true);
  }

  Map<String, dynamic> toJson() {
    if (!isExclude) {
      return {
        'value': columns.map(_serializeColumn).toList(),
      };
    } else {
      return {
        'value': {
          'exclude': columns.map(_serializeColumn).toList(),
        },
      };
    }
  }

  dynamic _serializeColumn(dynamic column) {
    if (column is Column) {
      return column.name;
    } else if (column is SqlExpression) {
      return column.toJson();
    } else if (column is List && column.length == 2) {
      final expr = column[0];
      final alias = column[1];
      return [
        expr is SqlExpression
            ? expr.toJson()
            : (expr is Column ? expr.name : expr),
        alias,
      ];
    }
    return column;
  }
}
