abstract class QueryOperator {
  Map<dynamic, dynamic> toJson();
}

class ComparisonOperator extends QueryOperator {
  final dynamic column;
  final dynamic value;

  ComparisonOperator({required this.column, required this.value});

  @override
  Map<dynamic, dynamic> toJson() {
    return {column: value};
  }
}

/// Logical operator (e.g., and, or, not)
class LogicalOperator extends QueryOperator {
  final dynamic operator;
  final List<QueryOperator> values;

  LogicalOperator(this.operator, this.values);

  @override
  Map<dynamic, dynamic> toJson() {
    return {
      operator: values.map((e) => e.toJson()).toList(),
    };
  }
}

