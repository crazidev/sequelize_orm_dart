import 'package:sequelize_dart/src/query/operators/operators_interface.dart';

// ============================================================================
// Logical Operators
// ============================================================================

LogicalOperator and(List<QueryOperator> values) {
  return LogicalOperator('\$and', values);
}

LogicalOperator or(List<QueryOperator> values) {
  return LogicalOperator('\$or', values);
}

LogicalOperator not(List<QueryOperator> values) {
  return LogicalOperator('\$not', values);
}

// ============================================================================
// Basic Comparison Operators
// ============================================================================

ComparisonOperator eq(String column, dynamic value) {
  return ComparisonOperator(column: column, value: value);
}

ComparisonOperator ne(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$ne': value},
  );
}

ComparisonOperator is_(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$is': value},
  );
}

ComparisonOperator not_(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$not': value},
  );
}

// ============================================================================
// Number Comparison Operators
// ============================================================================

ComparisonOperator gt(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$gt': value},
  );
}

ComparisonOperator gte(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$gte': value},
  );
}

ComparisonOperator lt(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$lt': value},
  );
}

ComparisonOperator lte(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$lte': value},
  );
}

ComparisonOperator between(String column, List<dynamic> value) {
  return ComparisonOperator(
    column: column,
    value: {'\$between': value},
  );
}

ComparisonOperator notBetween(String column, List<dynamic> value) {
  return ComparisonOperator(
    column: column,
    value: {'\$notBetween': value},
  );
}

// ============================================================================
// List Operators
// ============================================================================

ComparisonOperator in_(String column, List<dynamic> values) {
  return ComparisonOperator(
    column: column,
    value: {'\$in': values},
  );
}

ComparisonOperator notIn(String column, List<dynamic> values) {
  return ComparisonOperator(
    column: column,
    value: {'\$notIn': values},
  );
}

ComparisonOperator all(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$all': value},
  );
}

ComparisonOperator any(String column, List<dynamic> values) {
  return ComparisonOperator(
    column: column,
    value: {'\$any': values},
  );
}

// ============================================================================
// String Operators
// ============================================================================

ComparisonOperator like(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$like': pattern},
  );
}

ComparisonOperator notLike(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$notLike': pattern},
  );
}

ComparisonOperator startsWith(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$startsWith': pattern},
  );
}

ComparisonOperator endsWith(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$endsWith': pattern},
  );
}

ComparisonOperator substring(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$substring': pattern},
  );
}

ComparisonOperator iLike(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$ilike': pattern},
  );
}

ComparisonOperator notILike(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$notILike': pattern},
  );
}

// ============================================================================
// Regex Operators
// ============================================================================

ComparisonOperator regexp(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$regexp': pattern},
  );
}

ComparisonOperator notRegexp(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$notRegexp': pattern},
  );
}

ComparisonOperator iRegexp(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$iRegexp': pattern},
  );
}

ComparisonOperator notIRegexp(String column, String pattern) {
  return ComparisonOperator(
    column: column,
    value: {'\$notIRegexp': pattern},
  );
}

// ============================================================================
// Other Operators
// ============================================================================

ComparisonOperator col(String column, String columnReference) {
  return ComparisonOperator(
    column: column,
    value: {'\$col': columnReference},
  );
}

ComparisonOperator match(String column, dynamic value) {
  return ComparisonOperator(
    column: column,
    value: {'\$match': value},
  );
}

// ============================================================================
// Legacy/Compatibility Operators
// ============================================================================

ComparisonOperator equal(String column, dynamic value) => eq(column, value);

ComparisonOperator notEqual(String column, dynamic value) => ne(column, value);
