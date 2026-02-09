import 'package:sequelize_orm/src/query/operators/operators_interface.dart';
import 'package:sequelize_orm/src/query/typed_column.dart';

/// List/Array operators for checking membership
///
/// The `Op.in` and `Op.notIn` operators are used to check if a value is in a list of values.
///
/// See: https://sequelize.org/docs/v7/querying/operators/#in-operator
extension ListOperatorsExtension<T> on Column<T> {
  /// In: `IN` (value1, value2, ...)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.authorId.in_([2, 3])
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" IN (2, 3);
  /// ```
  ComparisonOperator in_(List<T> values) {
    return ComparisonOperator(
      column: name,
      value: {'\$in': values},
    );
  }

  /// Not in: `NOT IN` (value1, value2, ...)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.authorId.notIn([2, 3])
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" NOT IN (2, 3);
  /// ```
  ComparisonOperator notIn(List<T> values) {
    return ComparisonOperator(
      column: name,
      value: {'\$notIn': values},
    );
  }

  /// All: `= ALL` (ARRAY[...])
  ///
  /// Can be combined with other operators. Checks all values in the array.
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.all(['%cat%', '%dog%'])
  /// ```
  ///
  /// Produces SQL (when combined with iLike):
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" ILIKE ALL (ARRAY['%cat%', '%dog%']::TEXT[]);
  /// ```
  ///
  /// See: https://sequelize.org/docs/v7/querying/operators/#all-any--values
  ComparisonOperator all(dynamic value) {
    return ComparisonOperator(
      column: name,
      value: {'\$all': value},
    );
  }

  /// Any: `= ANY` (ARRAY[...]) (PostgreSQL only)
  ///
  /// Can be combined with other operators. Checks if any value in the array matches.
  ///
  /// Example:
  /// ```dart
  /// Post.columns.authorId.any([12, 13])
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" = ANY (ARRAY[12, 13]::INTEGER[]);
  /// ```
  ///
  /// See: https://sequelize.org/docs/v7/querying/operators/#all-any--values
  ComparisonOperator any(List<T> values) {
    return ComparisonOperator(
      column: name,
      value: {'\$any': values},
    );
  }
}
