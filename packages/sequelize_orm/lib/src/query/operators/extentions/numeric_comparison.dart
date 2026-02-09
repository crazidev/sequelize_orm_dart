import 'package:sequelize_orm/src/query/operators/operators_interface.dart';
import 'package:sequelize_orm/src/query/typed_column.dart';

/// Numeric comparison operators for range and ordering comparisons
///
/// `Op.gt`, `Op.gte`, `Op.lt`, `Op.lte` are the comparison operators.
///
/// See: https://sequelize.org/docs/v7/querying/operators/#comparison-operators
extension NumericComparisonExtension<T> on Column<T> {
  /// Greater than: `>` value
  ///
  /// Example:
  /// ```dart
  /// Post.columns.commentCount.gt(10)
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "commentCount" > 10;
  /// ```
  ComparisonOperator gt(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$gt': value},
    );
  }

  /// Greater than or equal: `>=` value
  ///
  /// Example:
  /// ```dart
  /// Post.columns.commentCount.gte(10)
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "commentCount" >= 10;
  /// ```
  ComparisonOperator gte(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$gte': value},
    );
  }

  /// Less than: `<` value
  ///
  /// Example:
  /// ```dart
  /// Post.columns.commentCount.lt(10)
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "commentCount" < 10;
  /// ```
  ComparisonOperator lt(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$lt': value},
    );
  }

  /// Less than or equal: `<=` value
  ///
  /// Example:
  /// ```dart
  /// Post.columns.commentCount.lte(10)
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "commentCount" <= 10;
  /// ```
  ComparisonOperator lte(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$lte': value},
    );
  }

  /// Between: `BETWEEN` value1 `AND` value2
  ///
  /// This operator takes a list of exactly two values (the lower and upper bounds).
  ///
  /// Example:
  /// ```dart
  /// Post.columns.commentCount.between([1, 10])
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "commentCount" BETWEEN 1 AND 10;
  /// ```
  ///
  /// See: https://sequelize.org/docs/v7/querying/operators/#between-operator
  ComparisonOperator between(List<T> value) {
    return ComparisonOperator(
      column: name,
      value: {'\$between': value},
    );
  }

  /// Not between: `NOT BETWEEN` value1 `AND` value2
  ///
  /// This operator takes a list of exactly two values (the lower and upper bounds).
  ///
  /// Example:
  /// ```dart
  /// Post.columns.commentCount.notBetween([1, 10])
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "commentCount" NOT BETWEEN 1 AND 10;
  /// ```
  ///
  /// See: https://sequelize.org/docs/v7/querying/operators/#between-operator
  ComparisonOperator notBetween(List<T> value) {
    return ComparisonOperator(
      column: name,
      value: {'\$notBetween': value},
    );
  }
}
