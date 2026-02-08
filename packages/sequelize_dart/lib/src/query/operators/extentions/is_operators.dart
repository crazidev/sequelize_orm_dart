import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/typed_column.dart';

/// IS operators for NULL and boolean checks
///
/// The `Op.is` and `Op.isNot` operators are used to check for `NULL` and boolean values.
///
/// See: https://sequelize.org/docs/v7/querying/operators/#is-operator
extension IsOperatorsExtension<T> on Column<T> {
  /// IS NULL check
  ///
  /// Example:
  /// ```dart
  /// Post.columns.authorId.isNull()
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" IS NULL;
  /// ```
  ComparisonOperator isNull() {
    return ComparisonOperator(
      column: name,
      value: {'\$is': null},
    );
  }

  /// IS NOT NULL check
  ///
  /// Example:
  /// ```dart
  /// Post.columns.authorId.isNotNull()
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" IS NOT NULL;
  /// ```
  ComparisonOperator isNotNull() {
    return ComparisonOperator(
      column: name,
      value: {'\$isNot': null},
    );
  }

  /// IS TRUE check (PostgreSQL only)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.isActive.isTrue()
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "isActive" IS TRUE;
  /// ```
  ComparisonOperator isTrue() {
    return ComparisonOperator(
      column: name,
      value: {'\$is': true},
    );
  }

  /// IS FALSE check (PostgreSQL only)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.isActive.isFalse()
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "isActive" IS FALSE;
  /// ```
  ComparisonOperator isFalse() {
    return ComparisonOperator(
      column: name,
      value: {'\$isNot': false},
    );
  }

  /// IS NOT TRUE check (PostgreSQL only)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.isActive.isNotTrue()
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "isActive" IS NOT TRUE;
  /// ```
  ComparisonOperator isNotTrue() {
    return ComparisonOperator(
      column: name,
      value: {'\$isNot': true},
    );
  }

  /// IS NOT FALSE check (PostgreSQL only)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.isActive.isNotFalse()
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "isActive" IS NOT FALSE;
  /// ```
  ComparisonOperator isNotFalse() {
    return ComparisonOperator(
      column: name,
      value: {'\$isNot': false},
    );
  }
}
