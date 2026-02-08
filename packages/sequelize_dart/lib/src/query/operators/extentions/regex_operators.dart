import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/typed_column.dart';

/// Regular expression pattern matching operators
///
/// The `Op.regexp` and `Op.notRegexp` operators are used to check if a value
/// matches a regular expression. In supported dialects, you can also use
/// `Op.iRegexp` and `Op.notIRegexp` to perform case-insensitive matches.
///
/// See: https://sequelize.org/docs/v7/querying/operators/#regexp-operator
extension RegexOperatorsExtension<T> on Column<T> {
  /// Regex: `~` 'pattern' (PostgreSQL) / `REGEXP` 'pattern' (MySQL)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.regexp('^The Fox')
  /// ```
  ///
  /// Produces SQL (PostgreSQL):
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" ~ '^The Fox';
  /// ```
  ///
  /// Produces SQL (MySQL):
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" REGEXP '^The Fox';
  /// ```
  ComparisonOperator regexp(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$regexp': pattern},
    );
  }

  /// Not regex: `!~` 'pattern' (PostgreSQL) / `NOT REGEXP` 'pattern' (MySQL)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.notRegexp('^The Fox')
  /// ```
  ///
  /// Produces SQL (PostgreSQL):
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" !~ '^The Fox';
  /// ```
  ///
  /// Produces SQL (MySQL):
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" NOT REGEXP '^The Fox';
  /// ```
  ComparisonOperator notRegexp(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$notRegexp': pattern},
    );
  }

  /// Case insensitive regex: `~*` 'pattern' (PostgreSQL only)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.iRegexp('^The Fox')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" ~* '^The Fox';
  /// ```
  ComparisonOperator iRegexp(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$iRegexp': pattern},
    );
  }

  /// Case insensitive not regex: `!~*` 'pattern' (PostgreSQL only)
  ///
  /// Example:
  /// ```dart
  /// Post.columns.title.notIRegexp('^The Fox')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "title" !~* '^The Fox';
  /// ```
  ComparisonOperator notIRegexp(String pattern) {
    return ComparisonOperator(
      column: name,
      value: {'\$notIRegexp': pattern},
    );
  }
}
