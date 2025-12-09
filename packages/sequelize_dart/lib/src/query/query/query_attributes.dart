import 'package:sequelize_dart/src/query/typed_column.dart';

enum QueryAttributesType { include, exclude }

class QueryAttributes {
  final List<Column> columns;
  final bool isExclude;

  QueryAttributes({
    required this.columns,
    this.isExclude = false,
  });

  Map<String, dynamic> toJson() {
    if (!isExclude) {
      return {
        'value': columns.map((e) => e.name).toList(),
      };
    } else {
      return {
        'value': {
          'exclude': columns.map((e) => e.name).toList(),
        },
      };
    }
  }
}
