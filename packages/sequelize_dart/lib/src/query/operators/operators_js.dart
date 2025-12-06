import 'package:sequelize_dart/src/sequelize/sequelize_js.dart';
import 'operators_interface.dart';

LogicalOperator and(List<QueryOperator> values) {
  return LogicalOperator(Op.and, values);
}

LogicalOperator or(List<QueryOperator> values) {
  return LogicalOperator(Op.or, values);
}

LogicalOperator not(List<QueryOperator> values) {
  return LogicalOperator(Op.not, values);
}

// ============================================================================
// Comparison Operators
// ============================================================================

ComparisonOperator equal(String column, dynamic value) {
  return ComparisonOperator(column: column, value: value);
}

ComparisonOperator notEqual(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.ne: value});
}
