import 'package:sequelize_dart/src/query/query/query.dart';

/// Mixin that provides reload functionality for model value classes.
///
/// This mixin provides a generic [reload] implementation that can be used by
/// generated model value classes to reduce code duplication.
///
/// Example usage in generated code:
/// ```dart
/// class $UserValues with ReloadableMixin<$UserValues> {
///   @override
///   Map<String, dynamic>? getPrimaryKeyMap() => {'id': id};
///
///   @override
///   Future<$UserValues?> findByPrimaryKey(Map<String, dynamic> pk) async {
///     return $User().findOne(where: (c) => c.id.eq(pk['id']));
///   }
///
///   @override
///   void copyFieldsFrom($UserValues source) {
///     id = source.id;
///     name = source.name;
///   }
/// }
/// ```
mixin ReloadableMixin<T extends ReloadableMixin<T>> {
  /// The original query used when this instance was fetched.
  /// Used by [reload] to preserve include, order, etc.
  Query? get originalQuery;

  /// Sets the original query. Called after fetching.
  set originalQuery(Query? query);

  /// Returns a map of primary key column names to their current values.
  /// Returns null if no primary keys are set.
  ///
  /// Example: `{'id': 1}` or `{'id': 1, 'tenant_id': 'abc'}` for composite keys
  Map<String, dynamic>? getPrimaryKeyMap();

  /// Finds a record by primary key, optionally using the original query options.
  /// This should call the model's findOne method with appropriate parameters.
  Future<T?> findByPrimaryKey(
    Map<String, dynamic> primaryKey, {
    Query? originalQuery,
  });

  /// Copies all fields from [source] to this instance.
  void copyFieldsFrom(T source);

  /// Reloads this instance from the database.
  ///
  /// Uses the primary key to fetch the latest data. If [originalQuery] is set,
  /// preserves the original include, order, group, limit, offset, and attributes.
  ///
  /// Returns this instance with updated fields, or null if the record was deleted.
  ///
  /// Throws [StateError] if the instance has no primary key values.
  Future<T?> reload() async {
    final pk = getPrimaryKeyMap();
    if (pk == null || pk.isEmpty) {
      throw StateError('Cannot reload: instance has no primary key values');
    }

    final result = await findByPrimaryKey(pk, originalQuery: originalQuery);
    if (result == null) {
      return null;
    }

    copyFieldsFrom(result);
    // Preserve original query for future reloads
    originalQuery = result.originalQuery ?? originalQuery;

    return this as T;
  }
}
