import 'package:sequelize_orm/src/query/typed_column.dart';

/// A column reference for JSON/JSONB typed columns.
///
/// Provides a fluent API for building JSON path queries instead of
/// writing raw path strings.
///
/// Example:
/// ```dart
/// // Before (raw string):
/// const Column('metadata.tags[0]:unquote').like('dart')
///
/// // After (fluent API):
/// postDetails.metadata.key('tags').at(0).unquote().like('dart')
/// ```
class JsonColumn extends Column<Map<String, dynamic>> {
  const JsonColumn(super.name, [super.dataType]);

  /// Navigate to a key in the JSON object.
  ///
  /// Produces the Sequelize dot-notation path: `column.key`
  /// which maps to SQL: `"column"->'key'`
  ///
  /// Example:
  /// ```dart
  /// postDetails.metadata.key('source').eq('"seeder"')
  /// ```
  JsonPath key(String key) => JsonPath('$name.$key');

  /// Navigate to an array index in the JSON column.
  ///
  /// Produces the Sequelize bracket notation: `column[index]`
  /// which maps to SQL: `"column"->index`
  ///
  /// Example:
  /// ```dart
  /// postDetails.metadata.key('tags').at(0).unquote().eq('dart')
  /// ```
  JsonPath at(int index) => JsonPath('$name[$index]');
}

/// A chainable JSON path builder.
///
/// Extends [Column<dynamic>] so all existing operator extensions
/// (`.eq()`, `.like()`, `.gt()`, etc.) are available directly on
/// the path without needing `:unquote`.
///
/// Use [unquote] to switch from `->` (JSON extraction) to `->>`
/// (text extraction) and get a `Column<String>` for type-safe
/// string operations.
///
/// Example:
/// ```dart
/// // Without unquote (compares JSON values):
/// postDetails.metadata.key('source').eq('"seeder"')
///
/// // With unquote (compares text values):
/// postDetails.metadata.key('source').unquote().eq('seeder')
/// ```
class JsonPath extends Column<dynamic> {
  JsonPath(super.name);

  /// Navigate to a nested key in the JSON path.
  ///
  /// Appends `.key` to the current path.
  ///
  /// Example:
  /// ```dart
  /// postDetails.metadata.key('author').key('name').unquote().eq('John')
  /// ```
  JsonPath key(String key) => JsonPath('$name.$key');

  /// Navigate to an array index in the JSON path.
  ///
  /// Appends `[index]` to the current path.
  ///
  /// Example:
  /// ```dart
  /// postDetails.metadata.key('tags').at(0).unquote().eq('dart')
  /// ```
  JsonPath at(int index) => JsonPath('$name[$index]');

  /// Use `->>` (text extraction) instead of `->` (JSON extraction).
  ///
  /// Returns a [Column<String>] so string operators like `.like()`,
  /// `.startsWith()`, `.iLike()` are type-safe.
  ///
  /// Example:
  /// ```dart
  /// postDetails.metadata.key('tags').at(0).unquote().like('%dart%')
  /// ```
  Column<String> unquote() => Column<String>('$name:unquote');
}
