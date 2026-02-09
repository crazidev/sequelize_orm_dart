import 'package:sequelize_orm/src/query/operators/operators_interface.dart';
import 'package:sequelize_orm/src/query/typed_column.dart';

/// String pattern matching operators
///
/// The `Op.like` and `Op.notLike` operators are used to check if a value matches a pattern.
/// In supported dialects, you can also use `Op.iLike` and `Op.notILike` to perform
/// case-insensitive matches.
///
/// See: https://sequelize.org/docs/v7/querying/operators/#like-operator
extension StringOperatorsExtension<T> on Column<T> {
  /// Like: `LIKE` 'pattern'
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.like('%The Fox & The Hound%')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" LIKE '%The Fox & The Hound%';
  /// ```
  ComparisonOperator like(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$like': pattern},
    );
  }

  /// Not like: `NOT LIKE` 'pattern'
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.notLike('%The Fox & The Hound%')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" NOT LIKE '%The Fox & The Hound%';
  /// ```
  ComparisonOperator notLike(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$notLike': pattern},
    );
  }

  /// Starts with: `LIKE` 'pattern%'
  ///
  /// Case-sensitive exact match for the beginning of a string.
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.startsWith('The Fox')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" LIKE 'The Fox%';
  /// ```
  ///
  /// See: https://sequelize.org/docs/v7/querying/operators/#starts--ends-with-operator
  ComparisonOperator startsWith(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$startsWith': pattern},
    );
  }

  /// Ends with: `LIKE` '%pattern'
  ///
  /// Case-sensitive exact match for the end of a string.
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.endsWith('Hound')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" LIKE '%Hound';
  /// ```
  ///
  /// See: https://sequelize.org/docs/v7/querying/operators/#starts--ends-with-operator
  ComparisonOperator endsWith(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$endsWith': pattern},
    );
  }

  /// Substring: `LIKE` '%pattern%'
  ///
  /// Case-sensitive exact match for a substring.
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.substring('Fox')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" LIKE '%Fox%';
  /// ```
  ///
  /// See: https://sequelize.org/docs/v7/querying/operators/#contains-string-operator
  ComparisonOperator substring(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$substring': pattern},
    );
  }

  /// Case insensitive like: `ILIKE` 'pattern' (PostgreSQL only)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.iLike('%The Fox & The Hound%')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" ILIKE '%The Fox & The Hound%';
  /// ```
  ComparisonOperator iLike(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$ilike': pattern},
    );
  }

  /// Case insensitive not like: `NOT ILIKE` 'pattern' (PostgreSQL only)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.notILike('%The Fox & The Hound%')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" NOT ILIKE '%The Fox & The Hound%';
  /// ```
  ComparisonOperator notILike(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$notILike': pattern},
    );
  }
}
