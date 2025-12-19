import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart/src/query/query/query.dart';

/// Type-safe reference to a model association
///
/// This class provides a type-safe way to reference associations in queries.
/// Association references are generated automatically in query builder classes.
///
/// Example:
/// ```dart
/// Users.instance.findAll((users) => Query(
///   include: [
///     users.posts.include(), // Basic include
///     users.posts.include(separate: true), // With options
///   ],
/// ));
/// ```
class AssociationReference<T> {
  /// The association name (as defined in the model annotation)
  final String name;

  /// The associated model instance
  final ModelInterface model;

  const AssociationReference(this.name, this.model);

  /// Include all associations of this model
  ///
  /// [nested] - If true, also includes nested associations (associations of associations)
  ///   This recursively includes all associations at all levels
  ///
  /// Note: Sequelize only allows `nested` as an additional option with `all: true`.
  /// Other options like `separate`, `required`, `right` are not supported with `all: true`.
  /// If you need those options, use `include()` with specific associations instead.
  IncludeBuilder<T> includeAll({
    bool nested = false,
  }) {
    return IncludeBuilder<T>(
      all: true,
      nested: nested,
    );
  }

  /// Get a column reference string for referencing columns from this association
  /// in parent where clauses
  ///
  /// Example:
  /// ```dart
  /// Users.instance.findAll((users) => Query(
  ///   where: and([
  ///     users.id.eq(1),
  ///     users.posts.col('title').eq('My Post'),
  ///   ]),
  /// ));
  /// ```
  ///
  /// This creates a reference to the 'title' column of the 'posts' association,
  /// which can be used with the Column.col() operator.
  String col(String columnName) {
    return '$name.$columnName';
  }
}
