import 'operators_interface.dart';

LogicalOperator and(List<QueryOperator> values) {
  return LogicalOperator('\$and', values);
}

LogicalOperator or(List<QueryOperator> values) {
  return LogicalOperator('\$or', values);
}

LogicalOperator not(List<QueryOperator> values) {
  return LogicalOperator('\$not', values);
}

ComparisonOperator equal(String column, dynamic value) {
  return ComparisonOperator(column: column, value: value);
}

ComparisonOperator notEqual(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$ne': value},
  );
}
