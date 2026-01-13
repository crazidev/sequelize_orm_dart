import 'package:sequelize_dart/src/query/query/query.dart';

/// Base class for generated $ModelValues classes.
/// Provides common functionality for instance methods like reload(), increment(), decrement().
///
/// Subclasses must implement:
/// - [toJson] - Convert instance to JSON
/// - [getPrimaryKeyValues] - Get primary key column names and their values
/// - [findOneByPrimaryKey] - Find one record using primary keys with original query options
/// - [updateFieldsFrom] - Update instance fields from another instance
abstract class ModelValuesBase<T extends ModelValuesBase<T>> {
  /// Stores the original query for reload() method
  Query? originalQuery;

  /// Convert instance to JSON representation
  Map<String, dynamic> toJson();

  /// Get primary key column names and their current values
  /// Returns a map like {'id': 1} or {'id': 1, 'tenant_id': 'abc'} for composite keys
  Map<String, dynamic>? getPrimaryKeyValues();

  /// Find one record using primary keys, optionally with original query options
  /// This should call the static findOne method with the primary key where clause
  Future<T?> findOneByPrimaryKey({bool useOriginalQuery});

  /// Update all instance fields from another instance (Sequelize.js behavior)
  void updateFieldsFrom(T source);

  /// Get primary key where clause as a Map
  /// Returns null if no primary key values are set
  Map<String, dynamic>? where() => getPrimaryKeyValues();

  /// Reload the instance from database
  /// Returns this instance with updated fields, or null if not found
  Future<T?> reload() async {
    final pkValues = getPrimaryKeyValues();
    if (pkValues == null || pkValues.isEmpty) {
      throw StateError('Cannot reload: instance has no primary key values');
    }

    final result = await findOneByPrimaryKey(useOriginalQuery: true);
    if (result == null) {
      return null;
    }

    updateFieldsFrom(result);
    // Preserve original query for future reloads
    originalQuery = result.originalQuery ?? originalQuery;

    return this as T;
  }
}
