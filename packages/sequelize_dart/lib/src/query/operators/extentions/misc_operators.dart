import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/typed_column.dart';

/// Miscellaneous operators for special use cases
///
/// See: https://sequelize.org/docs/v7/querying/operators/#misc-operators
extension MiscOperatorsExtension<T> on Column<T> {
  /// Column reference: compares one column to another
  ///
  /// Example:
  /// ```dart
  /// Post.columns.authorId.col('editor_id')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" = "editor_id";
  /// ```
  ///
  /// You can also reference columns from other tables:
  /// ```dart
  /// Post.columns.authorId.col('users.id')
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "posts" WHERE "authorId" = "users"."id";
  /// ```
  ComparisonOperator col(String columnReference) {
    return ComparisonOperator(
      column: name,
      value: {'\$col': columnReference},
    );
  }

  /// Text search match: `@@` tsquery (PostgreSQL only)
  ///
  /// Matches a tsvector against a tsquery for full-text search.
  ///
  /// Example:
  /// ```dart
  /// Document.columns.searchTsVector.match("to_tsquery('english', 'cat & rat')")
  /// ```
  ///
  /// Produces SQL:
  /// ```sql
  /// SELECT * FROM "documents" WHERE "searchTsVector" @@ to_tsquery('english', 'cat & rat');
  /// ```
  ///
  /// See: https://sequelize.org/docs/v7/querying/operators/#tsquery-matching-operator
  ComparisonOperator match(dynamic value) {
    return ComparisonOperator(
      column: name,
      value: {'\$match': value},
    );
  }
}
