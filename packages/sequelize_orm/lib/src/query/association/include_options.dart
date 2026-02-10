import 'package:sequelize_orm/src/model/model_interface.dart';
import 'package:sequelize_orm/src/query/operators/operators_interface.dart';
import 'package:sequelize_orm/src/query/query/query.dart';

/// Fluent API for building include configurations.
///
/// Provides a chainable interface as an alternative to passing many parameters.
///
/// Example usage:
/// ```dart
/// // Traditional approach with many parameters:
/// include.posts(
///   where: (c) => c.published.eq(true),
///   required: true,
///   limit: 10,
///   order: [['createdAt', 'DESC']],
/// )
///
/// // Fluent API approach:
/// include.posts()
///   .where((c) => c.published.eq(true))
///   .required()
///   .limit(10)
///   .orderBy([['createdAt', 'DESC']])
/// ```
class IncludeOptions<T> {
  final String _association;
  final ModelInterface _model;

  bool? _separate;
  bool? _required;
  bool? _right;
  QueryOperator? _where;
  QueryAttributes? _attributes;
  dynamic _order;
  dynamic _group;
  int? _limit;
  int? _offset;
  List<IncludeBuilder>? _include;
  Map<String, dynamic>? _through;
  bool? _duplicating;
  QueryOperator? _on;
  bool? _or;
  bool? _subQuery;

  IncludeOptions(this._association, this._model);

  /// Run a separate query for this association (useful for HasMany/BelongsToMany)
  IncludeOptions<T> separate([bool value = true]) {
    _separate = value;
    return this;
  }

  /// Perform INNER JOIN (only returns parent with matching associations)
  IncludeOptions<T> required([bool value = true]) {
    _required = value;
    return this;
  }

  /// Perform RIGHT OUTER JOIN
  IncludeOptions<T> right([bool value = true]) {
    _right = value;
    return this;
  }

  /// Filter conditions for the associated model
  IncludeOptions<T> where(QueryOperator condition) {
    _where = condition;
    return this;
  }

  /// Select specific attributes from the associated model
  IncludeOptions<T> attributes(QueryAttributes attrs) {
    _attributes = attrs;
    return this;
  }

  /// Order the associated records
  IncludeOptions<T> orderBy(dynamic order) {
    _order = order;
    return this;
  }

  /// Group the associated records
  IncludeOptions<T> groupBy(dynamic group) {
    _group = group;
    return this;
  }

  /// Limit the number of associated records
  IncludeOptions<T> limit(int value) {
    _limit = value;
    return this;
  }

  /// Offset for pagination
  IncludeOptions<T> offset(int value) {
    _offset = value;
    return this;
  }

  /// Nested includes
  IncludeOptions<T> include(List<IncludeBuilder> includes) {
    _include = includes;
    return this;
  }

  /// Options for BelongsToMany through models
  IncludeOptions<T> through(Map<String, dynamic> throughOptions) {
    _through = throughOptions;
    return this;
  }

  /// Mark the include as duplicating
  IncludeOptions<T> duplicating([bool value = true]) {
    _duplicating = value;
    return this;
  }

  /// Custom ON clause
  IncludeOptions<T> on(QueryOperator condition) {
    _on = condition;
    return this;
  }

  /// Bind ON and WHERE by OR instead of AND
  IncludeOptions<T> or([bool value = true]) {
    _or = value;
    return this;
  }

  /// Use sub queries
  IncludeOptions<T> subQuery([bool value = true]) {
    _subQuery = value;
    return this;
  }

  /// Convert to an IncludeBuilder for use in queries
  IncludeBuilder<T> build() {
    return IncludeBuilder<T>(
      association: _association,
      model: _model,
      separate: _separate,
      required: _required,
      right: _right,
      where: _where,
      attributes: _attributes,
      order: _order,
      group: _group,
      limit: _limit,
      offset: _offset,
      include: _include,
      through: _through,
      duplicating: _duplicating,
      on: _on,
      or: _or,
      subQuery: _subQuery,
    );
  }

  /// Implicit conversion to IncludeBuilder
  /// This allows using IncludeOptions directly where IncludeBuilder is expected
  IncludeBuilder<T> toIncludeBuilder() => build();
}

/// Extension to allow implicit conversion in lists
extension IncludeOptionsListExtension on List<IncludeOptions> {
  /// Convert all IncludeOptions to IncludeBuilders
  List<IncludeBuilder> toIncludeBuilders() {
    return map((opt) => opt.build()).toList();
  }
}
