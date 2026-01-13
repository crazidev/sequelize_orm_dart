import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/typed_column.dart';

/// Basic equality comparison operators
///
/// These operators perform simple equality checks.
///
/// See: https://sequelize.org/docs/v7/querying/operators/#equality-operator
extension BasicComparisonExtension<T> on Column<T> {
  /// Equal: `=` value
  ///
  /// Example:
  /// ```dart
  /// User.columns.authorId.eq(12)
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" = 12;
  /// ```
  ComparisonOperator eq(T? value) {
    return ComparisonOperator(
      column: name,
      value: {'\$eq': value},
    );
  }

  /// Not equal: `<>` value
  ///
  /// Example:
  /// ```dart
  /// User.columns.authorId.ne(12)
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" <> 12;
  /// ```
  ComparisonOperator ne(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$ne': value},
    );
  }
}
