import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

/// Type-safe column reference for building queries
class TypedColumn<T> {
  final String name;
  final DataType dataType;

  const TypedColumn(this.name, this.dataType);

  // ============================================================================
  // Basic Comparison Operators
  // ============================================================================

  /// Equal: = value
  ComparisonOperator eq(T value) {
    return ComparisonOperator(column: name, value: value);
  }

  /// Not equal: != value
  ComparisonOperator ne(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$ne': value},
    );
  }

  /// IS NULL
  ComparisonOperator is_(T? value) {
    return ComparisonOperator(
      column: name,
      value: {'\$is': value},
    );
  }

  /// IS NOT value
  ComparisonOperator not_(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$not': value},
    );
  }

  // ============================================================================
  // Number Comparison Operators
  // ============================================================================

  /// Greater than: > value
  ComparisonOperator gt(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$gt': value},
    );
  }

  /// Greater than or equal: >= value
  ComparisonOperator gte(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$gte': value},
    );
  }

  /// Less than: < value
  ComparisonOperator lt(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$lt': value},
    );
  }

  /// Less than or equal: <= value
  ComparisonOperator lte(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$lte': value},
    );
  }

  /// Between: BETWEEN value1 AND value2
  ComparisonOperator between(List<T> value) {
    return ComparisonOperator(
      column: name,
      value: {'\$between': value},
    );
  }

  /// Not between: NOT BETWEEN value1 AND value2
  ComparisonOperator notBetween(List<T> value) {
    return ComparisonOperator(
      column: name,
      value: {'\$notBetween': value},
    );
  }

  // ============================================================================
  // List Operators
  // ============================================================================

  /// In: IN [value1, value2, ...]
  ComparisonOperator in_(List<T> values) {
    return ComparisonOperator(
      column: name,
      value: {'\$in': values},
    );
  }

  /// Not in: NOT IN [value1, value2, ...]
  ComparisonOperator notIn(List<T> values) {
    return ComparisonOperator(
      column: name,
      value: {'\$notIn': values},
    );
  }

  /// All: > ALL (SELECT ...)
  ComparisonOperator all(dynamic value) {
    return ComparisonOperator(
      column: name,
      value: {'\$all': value},
    );
  }

  /// Any: ANY (ARRAY[...]) (PostgreSQL only)
  ComparisonOperator any(List<T> values) {
    return ComparisonOperator(
      column: name,
      value: {'\$any': values},
    );
  }

  // ============================================================================
  // String Operators
  // ============================================================================

  /// Like: LIKE '%pattern%'
  ComparisonOperator like(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$like': pattern},
    );
  }

  /// Not like: NOT LIKE '%pattern%'
  ComparisonOperator notLike(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$notLike': pattern},
    );
  }

  /// Starts with: LIKE 'pattern%'
  ComparisonOperator startsWith(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$startsWith': pattern},
    );
  }

  /// Ends with: LIKE '%pattern'
  ComparisonOperator endsWith(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$endsWith': pattern},
    );
  }

  /// Substring: LIKE '%pattern%'
  ComparisonOperator substring(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$substring': pattern},
    );
  }

  /// Case insensitive like: ILIKE '%pattern%' (PostgreSQL only)
  ComparisonOperator iLike(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$ilike': pattern},
    );
  }

  /// Case insensitive not like: NOT ILIKE '%pattern%' (PostgreSQL only)
  ComparisonOperator notILike(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$notILike': pattern},
    );
  }

  // ============================================================================
  // Regex Operators
  // ============================================================================

  /// Regex: REGEXP/~ 'pattern' (MySQL/PostgreSQL only)
  ComparisonOperator regexp(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$regexp': pattern},
    );
  }

  /// Not regex: NOT REGEXP/!~ 'pattern' (MySQL/PostgreSQL only)
  ComparisonOperator notRegexp(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$notRegexp': pattern},
    );
  }

  /// Case insensitive regex: ~* 'pattern' (PostgreSQL only)
  ComparisonOperator iRegexp(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$iRegexp': pattern},
    );
  }

  /// Case insensitive not regex: !~* 'pattern' (PostgreSQL only)
  ComparisonOperator notIRegexp(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$notIRegexp': pattern},
    );
  }

  // ============================================================================
  // Other Operators
  // ============================================================================

  /// Column reference: = "table"."column"
  ComparisonOperator col(String columnReference) {
    return ComparisonOperator(
      column: name,
      value: {'\$col': columnReference},
    );
  }

  /// Text search match: match text search (PostgreSQL only)
  ComparisonOperator match(dynamic value) {
    return ComparisonOperator(
      column: name,
      value: {'\$match': value},
    );
  }

  // ============================================================================
  // Legacy/Compatibility Operators (for backward compatibility)
  // ============================================================================

  /// Equal (legacy alias for eq)
  ComparisonOperator equal(T value) => eq(value);

  /// Not equal (legacy alias for ne)
  ComparisonOperator not(T value) => ne(value);

  /// Greater than (legacy alias for gt)
  ComparisonOperator greaterThan(T value) => gt(value);

  /// Less than (legacy alias for lt)
  ComparisonOperator lessThan(T value) => lt(value);

  /// Greater than or equal (legacy alias for gte)
  ComparisonOperator greaterThanOrEqual(T value) => gte(value);

  /// Less than or equal (legacy alias for lte)
  ComparisonOperator lessThanOrEqual(T value) => lte(value);

  /// Like (legacy alias for like)
  ComparisonOperator like_(String pattern) => like(pattern);
}
