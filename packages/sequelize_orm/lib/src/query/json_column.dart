import 'package:sequelize_orm/src/annotations.dart';
import 'package:sequelize_orm/src/query/operators/operators_interface.dart';
import 'package:sequelize_orm/src/query/typed_column.dart';

/// A column reference for JSON/JSONB typed columns.
///
/// Unlike regular [Column], this class does **not** extend `Column` so
/// only JSON-relevant methods appear in autocomplete:
/// - [key] – navigate to a key in the JSON object
/// - [at] – navigate to an array element by index
/// - [eq] / [ne] – compare the whole JSON value
/// - [isNull] / [isNotNull] – null checks
///
/// Use [key] or [at] to get a [JsonPath], then call operators or
/// [JsonPath.unquote] to get a [Column<String>] with full string operators.
///
/// Example:
/// ```dart
/// // Fluent API:
/// u.metadata.key('role').unquote().eq('admin')
/// u.tags.at(0).unquote().eq('dart')
/// ```
class JsonColumn<T> {
  final String name;
  final DataType? dataType;

  const JsonColumn(this.name, [this.dataType]);

  /// Navigate to a key in the JSON object.
  ///
  /// Produces the Sequelize dot-notation path: `column.key`
  /// which maps to SQL: `"column"->'key'`
  ///
  /// Example:
  /// ```dart
  /// u.metadata.key('role').unquote().eq('admin')
  /// ```
  JsonPath key(String key) => JsonPath('$name.$key');

  /// Navigate to an array index in the JSON column.
  ///
  /// Produces the Sequelize bracket notation: `column[index]`
  /// which maps to SQL: `"column"->index`
  ///
  /// Example:
  /// ```dart
  /// u.tags.at(0).unquote().eq('dart')
  /// ```
  JsonPath at(int index) => JsonPath('$name[$index]');

  /// Use `->>` (text extraction) on the whole JSON column.
  ///
  /// Useful in PostgreSQL where comparing JSON without unquote
  /// may fail. MySQL handles this implicitly.
  ///
  /// Example:
  /// ```dart
  /// u.metadata.unquote().eq('{"role": "admin"}')
  /// ```
  JsonText unquote() => JsonText('$name:unquote');

  /// Equal: compare the whole JSON value.
  ///
  /// The type parameter [T] enforces the correct Dart type at compile time.
  /// For example, `JsonColumn<List<String>>` expects a `List<String>`.
  ComparisonOperator eq(T value) {
    return ComparisonOperator(column: name, value: {'\$eq': value});
  }

  /// Not equal: compare the whole JSON value.
  ComparisonOperator ne(T value) {
    return ComparisonOperator(column: name, value: {'\$ne': value});
  }

  /// Contains: check if the JSON value contains the given value.
  ///
  /// **PostgreSQL JSONB only.** This operator is not supported on MySQL
  /// or PostgreSQL JSON columns — only JSONB.
  ///
  /// For cross-database array comparison, use [eq] instead:
  /// ```dart
  /// // PostgreSQL JSONB only:
  /// u.tags.contains(['dart'])
  ///
  /// // Cross-database alternative:
  /// u.tags.eq(['dart', 'flutter', 'sequelize'])
  /// ```
  ComparisonOperator contains(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$contains': value});
  }

  /// IS NULL check on the JSON column.
  ComparisonOperator isNull() {
    return ComparisonOperator(column: name, value: {'\$is': null});
  }

  /// IS NOT NULL check on the JSON column.
  ComparisonOperator isNotNull() {
    return ComparisonOperator(column: name, value: {'\$isNot': null});
  }
}

/// A chainable JSON path builder.
///
/// Returned by [JsonColumn.key] and [JsonColumn.at]. Provides navigation
/// methods, comparison operators that work on JSON values, and [unquote]
/// to switch to text extraction.
///
/// Only the operators that work on JSON paths are exposed — no `like`,
/// `in_`, `all`, `any`, `startsWith`, etc. cluttering autocomplete.
///
/// Call [unquote] to get a [Column<String>] with full string operators
/// (`.like()`, `.iLike()`, `.startsWith()`, etc.).
///
/// Example:
/// ```dart
/// // Without unquote (compares JSON values):
/// u.metadata.key('level').eq(5)
///
/// // With unquote (compares text values — enables string operators):
/// u.metadata.key('role').unquote().eq('admin')
/// u.metadata.key('role').unquote().like('%adm%')
/// ```
class JsonPath {
  final String name;

  JsonPath(this.name);

  // ── Navigation ──

  /// Navigate to a nested key in the JSON path.
  ///
  /// Example:
  /// ```dart
  /// u.metadata.key('address').key('city').unquote().eq('Berlin')
  /// ```
  JsonPath key(String key) => JsonPath('$name.$key');

  /// Navigate to an array index in the JSON path.
  ///
  /// Example:
  /// ```dart
  /// u.metadata.key('tags').at(0).unquote().eq('dart')
  /// ```
  JsonPath at(int index) => JsonPath('$name[$index]');

  /// Use `->>` (text extraction) instead of `->` (JSON extraction).
  ///
  /// Returns a [JsonText] with only the operators that work on
  /// extracted text: `.eq()`, `.like()`, `.iLike()`, `.startsWith()`, etc.
  ///
  /// Example:
  /// ```dart
  /// u.metadata.key('role').unquote().eq('admin')
  /// u.metadata.key('role').unquote().like('%adm%')
  /// ```
  JsonText unquote() => JsonText('$name:unquote');

  // ── Comparison operators ──

  /// Equal: `=` value
  ComparisonOperator eq(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$eq': value});
  }

  /// Not equal: `<>` value
  ComparisonOperator ne(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$ne': value});
  }

  /// Greater than: `>` value
  ComparisonOperator gt(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$gt': value});
  }

  /// Greater than or equal: `>=` value
  ComparisonOperator gte(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$gte': value});
  }

  /// Less than: `<` value
  ComparisonOperator lt(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$lt': value});
  }

  /// Less than or equal: `<=` value
  ComparisonOperator lte(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$lte': value});
  }

  // ── IS operators ──

  /// IS NULL check
  ComparisonOperator isNull() {
    return ComparisonOperator(column: name, value: {'\$is': null});
  }

  /// IS NOT NULL check
  ComparisonOperator isNotNull() {
    return ComparisonOperator(column: name, value: {'\$isNot': null});
  }
}

/// Extracted text value from a JSON path (after calling [JsonPath.unquote]).
///
/// Only exposes operators that work on text values — no `in_`, `all`,
/// `any`, `regexp`, `col`, `match`, etc. cluttering autocomplete.
///
/// Example:
/// ```dart
/// u.metadata.key('role').unquote().eq('admin')
/// u.metadata.key('role').unquote().like('%adm%')
/// u.metadata.key('address').key('city').unquote().startsWith('Ber')
/// ```
class JsonText {
  final String name;

  JsonText(this.name);

  // ── Comparison operators ──

  /// Equal: `=` value
  ComparisonOperator eq(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$eq': value});
  }

  /// Not equal: `<>` value
  ComparisonOperator ne(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$ne': value});
  }

  /// Greater than: `>` value
  ComparisonOperator gt(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$gt': value});
  }

  /// Greater than or equal: `>=` value
  ComparisonOperator gte(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$gte': value});
  }

  /// Less than: `<` value
  ComparisonOperator lt(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$lt': value});
  }

  /// Less than or equal: `<=` value
  ComparisonOperator lte(dynamic value) {
    return ComparisonOperator(column: name, value: {'\$lte': value});
  }

  // ── String operators ──

  /// Like: `LIKE` 'pattern'
  ComparisonOperator like(String pattern) {
    return ComparisonOperator(column: name, value: {'\$like': pattern});
  }

  /// Not like: `NOT LIKE` 'pattern'
  ComparisonOperator notLike(String pattern) {
    return ComparisonOperator(column: name, value: {'\$notLike': pattern});
  }

  /// Starts with: `LIKE` 'pattern%'
  ComparisonOperator startsWith(String pattern) {
    return ComparisonOperator(column: name, value: {'\$startsWith': pattern});
  }

  /// Ends with: `LIKE` '%pattern'
  ComparisonOperator endsWith(String pattern) {
    return ComparisonOperator(column: name, value: {'\$endsWith': pattern});
  }

  /// Substring: `LIKE` '%pattern%'
  ComparisonOperator substring(String pattern) {
    return ComparisonOperator(column: name, value: {'\$substring': pattern});
  }

  /// Case insensitive like: `ILIKE` 'pattern' (PostgreSQL only)
  ComparisonOperator iLike(String pattern) {
    return ComparisonOperator(column: name, value: {'\$ilike': pattern});
  }

  /// Case insensitive not like: `NOT ILIKE` 'pattern' (PostgreSQL only)
  ComparisonOperator notILike(String pattern) {
    return ComparisonOperator(column: name, value: {'\$notILike': pattern});
  }

  // ── IS operators ──

  /// IS NULL check
  ComparisonOperator isNull() {
    return ComparisonOperator(column: name, value: {'\$is': null});
  }

  /// IS NOT NULL check
  ComparisonOperator isNotNull() {
    return ComparisonOperator(column: name, value: {'\$isNot': null});
  }
}
