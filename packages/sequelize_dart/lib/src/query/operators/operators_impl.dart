import 'package:sequelize_dart/src/query/operators/operators_interface.dart';

// ============================================================================
// Logical Operators
// ============================================================================

/// AND operator: (condition1) AND (condition2) AND ...
LogicalOperator and(List<QueryOperator> values) {
  return LogicalOperator('\$and', values);
}

/// OR operator: (condition1) OR (condition2) OR ...
LogicalOperator or(List<QueryOperator> values) {
  return LogicalOperator('\$or', values);
}

/// NOT operator: NOT (condition)
LogicalOperator not(List<QueryOperator> values) {
  return LogicalOperator('\$not', values);
}

// ============================================================================
// Basic Comparison Operators
// ============================================================================

/// Equal: = value
ComparisonOperator eq(String column, dynamic value) {
  return ComparisonOperator(column: column, value: value);
}

/// Not equal: != value
ComparisonOperator ne(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$ne': value});
}

/// IS NULL
ComparisonOperator is_(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$is': value});
}

/// IS NOT value
ComparisonOperator not_(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$not': value});
}

// ============================================================================
// Number Comparison Operators
// ============================================================================

/// Greater than: > value
ComparisonOperator gt(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$gt': value});
}

/// Greater than or equal: >= value
ComparisonOperator gte(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$gte': value});
}

/// Less than: < value
ComparisonOperator lt(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$lt': value});
}

/// Less than or equal: <= value
ComparisonOperator lte(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$lte': value});
}

/// Between: BETWEEN value1 AND value2
ComparisonOperator between(String column, List<dynamic> value) {
  return ComparisonOperator(column: column, value: {'\$between': value});
}

/// Not between: NOT BETWEEN value1 AND value2
ComparisonOperator notBetween(String column, List<dynamic> value) {
  return ComparisonOperator(column: column, value: {'\$notBetween': value});
}

// ============================================================================
// List Operators
// ============================================================================

/// In: IN [value1, value2, ...]
ComparisonOperator in_(String column, List<dynamic> values) {
  return ComparisonOperator(column: column, value: {'\$in': values});
}

/// Not in: NOT IN [value1, value2, ...]
ComparisonOperator notIn(String column, List<dynamic> values) {
  return ComparisonOperator(column: column, value: {'\$notIn': values});
}

/// All: > ALL (SELECT ...)
ComparisonOperator all(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$all': value});
}

/// Any: ANY (ARRAY[...]) (PostgreSQL only)
ComparisonOperator any(String column, List<dynamic> values) {
  return ComparisonOperator(column: column, value: {'\$any': values});
}

// ============================================================================
// String Operators
// ============================================================================

/// Like: LIKE '%pattern%'
ComparisonOperator like(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$like': pattern});
}

/// Not like: NOT LIKE '%pattern%'
ComparisonOperator notLike(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$notLike': pattern});
}

/// Starts with: LIKE 'pattern%'
ComparisonOperator startsWith(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$startsWith': pattern});
}

/// Ends with: LIKE '%pattern'
ComparisonOperator endsWith(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$endsWith': pattern});
}

/// Substring: LIKE '%pattern%'
ComparisonOperator substring(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$substring': pattern});
}

/// Case insensitive like: ILIKE '%pattern%' (PostgreSQL only)
ComparisonOperator iLike(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$iLike': pattern});
}

/// Case insensitive not like: NOT ILIKE '%pattern%' (PostgreSQL only)
ComparisonOperator notILike(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$notILike': pattern});
}

// ============================================================================
// Regex Operators
// ============================================================================

/// Regex: REGEXP/~ 'pattern' (MySQL/PostgreSQL only)
ComparisonOperator regexp(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$regexp': pattern});
}

/// Not regex: NOT REGEXP/!~ 'pattern' (MySQL/PostgreSQL only)
ComparisonOperator notRegexp(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$notRegexp': pattern});
}

/// Case insensitive regex: ~* 'pattern' (PostgreSQL only)
ComparisonOperator iRegexp(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$iRegexp': pattern});
}

/// Case insensitive not regex: !~* 'pattern' (PostgreSQL only)
ComparisonOperator notIRegexp(String column, String pattern) {
  return ComparisonOperator(column: column, value: {'\$notIRegexp': pattern});
}

// ============================================================================
// Other Operators
// ============================================================================

/// Column reference: = "table"."column"
ComparisonOperator col(String column, String columnReference) {
  return ComparisonOperator(column: column, value: {'\$col': columnReference});
}

/// Text search match: match text search (PostgreSQL only)
ComparisonOperator match(String column, dynamic value) {
  return ComparisonOperator(column: column, value: {'\$match': value});
}

// ============================================================================
// Legacy/Compatibility Operators
// ============================================================================

/// Equal (legacy alias for eq)
ComparisonOperator equal(String column, dynamic value) => eq(column, value);

/// Not equal (legacy alias for ne)
ComparisonOperator notEqual(String column, dynamic value) => ne(column, value);
