import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_js.dart';

// ============================================================================
// Logical Operators
// ============================================================================

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
// Basic Comparison Operators
// ============================================================================

ComparisonOperator eq(String column, dynamic value) {
  return ComparisonOperator(column: column, value: value);
}

ComparisonOperator ne(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.ne: value});
}

ComparisonOperator is_(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.isOp: value});
}

ComparisonOperator not_(String column, dynamic value) {
  // Op.not is for logical NOT, for IS NOT we use Op.is with negation
  // This is a workaround - Sequelize doesn't have a direct IS NOT operator
  return ComparisonOperator(column: column, value: {Op.not: value});
}

// ============================================================================
// Number Comparison Operators
// ============================================================================

ComparisonOperator gt(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.gt: value});
}

ComparisonOperator gte(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.gte: value});
}

ComparisonOperator lt(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.lt: value});
}

ComparisonOperator lte(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.lte: value});
}

ComparisonOperator between(String column, List<dynamic> value) {
  return ComparisonOperator(column: column, value: {Op.between: value});
}

ComparisonOperator notBetween(String column, List<dynamic> value) {
  return ComparisonOperator(column: column, value: {Op.notBetween: value});
}

// ============================================================================
// List Operators
// ============================================================================

ComparisonOperator in_(String column, List<dynamic> values) {
  return ComparisonOperator(column: column, value: {Op.inOp: values});
}

ComparisonOperator notIn(String column, List<dynamic> values) {
  return ComparisonOperator(column: column, value: {Op.notIn: values});
}

ComparisonOperator all(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.all: value});
}

ComparisonOperator any(String column, List<dynamic> values) {
  return ComparisonOperator(column: column, value: {Op.any: values});
}

// ============================================================================
// String Operators
// ============================================================================

ComparisonOperator like(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.like: pattern});
}

ComparisonOperator notLike(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.notLike: pattern});
}

ComparisonOperator startsWith(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.startsWith: pattern});
}

ComparisonOperator endsWith(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.endsWith: pattern});
}

ComparisonOperator substring(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.substring: pattern});
}

ComparisonOperator iLike(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.iLike: pattern});
}

ComparisonOperator notILike(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.notILike: pattern});
}

// ============================================================================
// Regex Operators
// ============================================================================

ComparisonOperator regexp(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.regexp: pattern});
}

ComparisonOperator notRegexp(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.notRegexp: pattern});
}

ComparisonOperator iRegexp(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.iRegexp: pattern});
}

ComparisonOperator notIRegexp(String column, String pattern) {
  return ComparisonOperator(column: column, value: {Op.notIRegexp: pattern});
}

// ============================================================================
// Other Operators
// ============================================================================

ComparisonOperator col(String column, String columnReference) {
  return ComparisonOperator(column: column, value: {Op.col: columnReference});
}

ComparisonOperator match(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {Op.match: value});
}

// ============================================================================
// Legacy/Compatibility Operators
// ============================================================================

ComparisonOperator equal(String column, dynamic value) => eq(column, value);

ComparisonOperator notEqual(String column, dynamic value) => ne(column, value);
