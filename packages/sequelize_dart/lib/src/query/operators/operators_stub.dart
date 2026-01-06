import 'package:sequelize_dart/src/query/operators/operators_interface.dart';

// ============================================================================
// Logical Operators
// ============================================================================

/// AND operator: (condition1) AND (condition2) AND ...
LogicalOperator and([List<QueryOperator> values = const []]) {
  throw UnimplementedError('and operator not implemented in stub');
}

/// OR operator: (condition1) OR (condition2) OR ...
LogicalOperator or([List<QueryOperator> values = const []]) {
  throw UnimplementedError('or operator not implemented in stub');
}

/// NOT operator: NOT (condition)
LogicalOperator not([List<QueryOperator> values = const []]) {
  throw UnimplementedError('not operator not implemented in stub');
}

// ============================================================================
// Basic Comparison Operators
// ============================================================================

/// Equal: = value
ComparisonOperator eq(String column, dynamic value) {
  throw UnimplementedError('eq operator not implemented in stub');
}

/// Not equal: != value
ComparisonOperator ne(String column, dynamic value) {
  throw UnimplementedError('ne operator not implemented in stub');
}

/// IS NULL
ComparisonOperator is_(String column, dynamic value) {
  throw UnimplementedError('is_ operator not implemented in stub');
}

/// IS NOT value
ComparisonOperator not_(String column, dynamic value) {
  throw UnimplementedError('not_ operator not implemented in stub');
}

// ============================================================================
// Number Comparison Operators
// ============================================================================

/// Greater than: > value
ComparisonOperator gt(String column, dynamic value) {
  throw UnimplementedError('gt operator not implemented in stub');
}

/// Greater than or equal: >= value
ComparisonOperator gte(String column, dynamic value) {
  throw UnimplementedError('gte operator not implemented in stub');
}

/// Less than: < value
ComparisonOperator lt(String column, dynamic value) {
  throw UnimplementedError('lt operator not implemented in stub');
}

/// Less than or equal: <= value
ComparisonOperator lte(String column, dynamic value) {
  throw UnimplementedError('lte operator not implemented in stub');
}

/// Between: BETWEEN value1 AND value2 (value should be List with 2 elements)
ComparisonOperator between(String column, List<dynamic> value) {
  throw UnimplementedError('between operator not implemented in stub');
}

/// Not between: NOT BETWEEN value1 AND value2 (value should be List with 2 elements)
ComparisonOperator notBetween(String column, List<dynamic> value) {
  throw UnimplementedError('notBetween operator not implemented in stub');
}

// ============================================================================
// List Operators
// ============================================================================

/// In: IN [value1, value2, ...]
ComparisonOperator in_(String column, List<dynamic> values) {
  throw UnimplementedError('in_ operator not implemented in stub');
}

/// Not in: NOT IN [value1, value2, ...]
ComparisonOperator notIn(String column, List<dynamic> values) {
  throw UnimplementedError('notIn operator not implemented in stub');
}

/// All: > ALL (SELECT ...)
ComparisonOperator all(String column, dynamic value) {
  throw UnimplementedError('all operator not implemented in stub');
}

/// Any: ANY (ARRAY[...]) (PostgreSQL only)
ComparisonOperator any(String column, List<dynamic> values) {
  throw UnimplementedError('any operator not implemented in stub');
}

// ============================================================================
// String Operators
// ============================================================================

/// Like: LIKE '%pattern%'
ComparisonOperator like(String column, String pattern) {
  throw UnimplementedError('like operator not implemented in stub');
}

/// Not like: NOT LIKE '%pattern%'
ComparisonOperator notLike(String column, String pattern) {
  throw UnimplementedError('notLike operator not implemented in stub');
}

/// Starts with: LIKE 'pattern%'
ComparisonOperator startsWith(String column, String pattern) {
  throw UnimplementedError('startsWith operator not implemented in stub');
}

/// Ends with: LIKE '%pattern'
ComparisonOperator endsWith(String column, String pattern) {
  throw UnimplementedError('endsWith operator not implemented in stub');
}

/// Substring: LIKE '%pattern%'
ComparisonOperator substring(String column, String pattern) {
  throw UnimplementedError('substring operator not implemented in stub');
}

/// Case insensitive like: ILIKE '%pattern%' (PostgreSQL only)
ComparisonOperator iLike(String column, String pattern) {
  throw UnimplementedError('iLike operator not implemented in stub');
}

/// Case insensitive not like: NOT ILIKE '%pattern%' (PostgreSQL only)
ComparisonOperator notILike(String column, String pattern) {
  throw UnimplementedError('notILike operator not implemented in stub');
}

// ============================================================================
// Regex Operators
// ============================================================================

/// Regex: REGEXP/~ 'pattern' (MySQL/PostgreSQL only)
ComparisonOperator regexp(String column, String pattern) {
  throw UnimplementedError('regexp operator not implemented in stub');
}

/// Not regex: NOT REGEXP/!~ 'pattern' (MySQL/PostgreSQL only)
ComparisonOperator notRegexp(String column, String pattern) {
  throw UnimplementedError('notRegexp operator not implemented in stub');
}

/// Case insensitive regex: ~* 'pattern' (PostgreSQL only)
ComparisonOperator iRegexp(String column, String pattern) {
  throw UnimplementedError('iRegexp operator not implemented in stub');
}

/// Case insensitive not regex: !~* 'pattern' (PostgreSQL only)
ComparisonOperator notIRegexp(String column, String pattern) {
  throw UnimplementedError('notIRegexp operator not implemented in stub');
}

// ============================================================================
// Other Operators
// ============================================================================

/// Column reference: = "table"."column"
ComparisonOperator col(String column, String columnReference) {
  throw UnimplementedError('col operator not implemented in stub');
}

/// Text search match: match text search (PostgreSQL only)
ComparisonOperator match(String column, dynamic value) {
  throw UnimplementedError('match operator not implemented in stub');
}

// ============================================================================
// Legacy/Compatibility Operators (for backward compatibility)
// ============================================================================

/// Equal (legacy alias for eq)
ComparisonOperator equal(String column, dynamic value) {
  throw UnimplementedError('equal operator not implemented in stub');
}

/// Not equal (legacy alias for ne)
ComparisonOperator notEqual(String column, dynamic value) {
  throw UnimplementedError('notEqual operator not implemented in stub');
}
