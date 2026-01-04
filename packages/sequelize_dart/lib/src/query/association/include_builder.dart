import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/query/query.dart';
import 'package:sequelize_dart/src/query/sql.dart';

/// Builder for creating type-safe include configurations
///
/// This class provides a type-safe way to configure includes with all Sequelize options.
class IncludeBuilder<T> {
  /// The association name (null when all: true)
  final String? association;

  /// The associated model instance (null when all: true)
  final ModelInterface? model;

  /// If true, includes all associations of the model
  final bool? all;

  /// If true, includes all nested associations recursively (requires all: true)
  final bool? nested;

  /// If true, runs a separate query (useful for HasMany/BelongsToMany)
  final bool? separate;

  /// If true, performs INNER JOIN (only returns parent with matching associations)
  final bool? required;

  /// If true, performs RIGHT OUTER JOIN (requires required: false)
  final bool? right;

  /// Filter conditions for the associated model
  /// Can be a QueryOperator directly or a function that will be resolved later
  final dynamic where;

  /// Select specific attributes from the associated model
  final QueryAttributes? attributes;

  /// Order the associated records
  final dynamic order;

  /// Group the associated records
  final dynamic group;

  /// Limit the number of associated records (requires separate: true)
  final int? limit;

  /// Offset for pagination (requires separate: true)
  final int? offset;

  /// Nested includes (associations of the associated model)
  /// Can be a `List<IncludeBuilder>` or a function that returns `List<IncludeBuilder>`
  /// Supports infinite levels of nesting - each IncludeBuilder can contain more IncludeBuilders
  final dynamic include;

  /// Options for BelongsToMany through models
  final Map<String, dynamic>? through;

  /// Mark the include as duplicating, will prevent a subquery from being used
  final bool? duplicating;

  /// Custom `ON` clause, overrides default
  final dynamic on;

  /// Whether to bind the ON and WHERE clause together by OR instead of AND
  /// @default false
  final bool? or;

  /// Use sub queries. This should only be used if you know for sure the query does not result in a cartesian product
  final bool? subQuery;

  IncludeBuilder({
    this.association,
    this.model,
    this.all,
    this.nested,
    this.separate = false,
    this.required,
    this.right,
    this.where,
    this.attributes,
    this.order,
    this.group,
    this.limit,
    this.offset,
    this.include,
    this.through,
    this.duplicating,
    this.on,
    this.or,
    this.subQuery,
  }) : assert(
         (all == true && association == null && model == null) ||
             ((all == null || all == false) &&
                 association != null &&
                 model != null),
         'When all is true, association and model must be null. '
         'When all is not true, association and model are required.',
       );

  /// Create a copy of this [IncludeBuilder] with the given fields replaced.
  IncludeBuilder<T> copyWith({
    String? association,
    ModelInterface? model,
    bool? all,
    bool? nested,
    bool? separate,
    bool? required,
    bool? right,
    dynamic where,
    QueryAttributes? attributes,
    dynamic order,
    dynamic group,
    int? limit,
    int? offset,
    dynamic include,
    Map<String, dynamic>? through,
    bool? duplicating,
    dynamic on,
    bool? or,
    bool? subQuery,
  }) {
    return IncludeBuilder<T>(
      association: association ?? this.association,
      model: model ?? this.model,
      all: all ?? this.all,
      nested: nested ?? this.nested,
      separate: separate ?? this.separate,
      required: required ?? this.required,
      right: right ?? this.right,
      where: where ?? this.where,
      attributes: attributes ?? this.attributes,
      order: order ?? this.order,
      group: group ?? this.group,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      include: include ?? this.include,
      through: through ?? this.through,
      duplicating: duplicating ?? this.duplicating,
      on: on ?? this.on,
      or: or ?? this.or,
      subQuery: subQuery ?? this.subQuery,
    );
  }

  dynamic _serializeExpression(dynamic expr) {
    if (expr is SqlExpression) {
      return expr.toJson();
    } else if (expr is List) {
      return expr.map(_serializeExpression).toList();
    } else if (expr is Map) {
      return expr.map(
        (key, value) => MapEntry(key, _serializeExpression(value)),
      );
    }
    return expr;
  }

  /// Convert the include builder to JSON format for Sequelize
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    // When all is true, only output {all: true, nested: true} format
    // Sequelize doesn't allow other options with all: true (except nested)
    if (all == true) {
      result['all'] = true;
      if (nested == true) {
        result['nested'] = true;
      }
      // Don't include any other options (separate, required, right, etc.)
      // Sequelize throws an error if extra options are included with all: true
      return result;
    }

    // Normal include format: {association: 'name', ...}
    result['association'] = association;

    if (separate != null) result['separate'] = separate;
    if (required != null) result['required'] = required;
    if (right != null) result['right'] = right;
    if (duplicating != null) result['duplicating'] = duplicating;
    if (or != null) result['or'] = or;
    if (subQuery != null) result['subQuery'] = subQuery;

    if (where != null && all != true) {
      // where clause only makes sense for specific associations, not for all: true
      QueryOperator? whereOperator;

      if (where is QueryOperator) {
        whereOperator = where as QueryOperator;
      } else if (where is Function) {
        // Resolve the function - it should receive columns instance
        // The include helper generator will pass the columns instance when creating IncludeBuilder
        // For now, we try to get it from the model's query builder and extract columns
        final whereFunction = where as QueryOperator Function(dynamic);

        dynamic columns;
        bool columnsCaptured = false;

        try {
          // Get the query builder from the model and extract columns
          // The columns will be resolved by the include helper generator
          final queryBuilder = model?.getQueryBuilder();
          if (queryBuilder != null) {
            // Try to get columns property if it exists (for backward compatibility)
            // In the new API, columns will be passed directly
            try {
              columns = (queryBuilder as dynamic).columns;
              if (columns != null) {
                columnsCaptured = true;
              }
            } catch (_) {
              // If columns property doesn't exist, use query builder itself for backward compatibility
              columns = queryBuilder;
              columnsCaptured = true;
            }
          }
        } catch (e) {
          // Fallback or error handling
          print('Warning: Failed to get columns: $e');
        }

        if (columnsCaptured && columns != null) {
          // Resolve the function with the columns
          whereOperator = whereFunction(columns);
        } else {
          throw StateError(
            'Failed to get columns for association "$association". '
            'Make sure the model has a columns class generated.',
          );
        }
      }

      if (whereOperator != null) {
        result['where'] = whereOperator.toJson();
      }
    }

    if (attributes != null) {
      final attrsJson = attributes!.toJson();
      result['attributes'] = attrsJson['value'];
    }

    if (order != null) result['order'] = _serializeExpression(order);
    if (group != null) result['group'] = _serializeExpression(group);
    if (limit != null) result['limit'] = limit;
    if (offset != null) result['offset'] = offset;

    if (include != null && all != true) {
      // include only makes sense for specific associations, not for all: true
      // (nested includes are handled by nested: true for all: true)
      List<IncludeBuilder> resolvedIncludes;

      if (include is List<IncludeBuilder>) {
        // Already a list of IncludeBuilders
        resolvedIncludes = include as List<IncludeBuilder>;
      } else if (include is Function) {
        // Function that takes an include helper and returns List<IncludeBuilder>
        // The include helper will be resolved by the include helper generator
        dynamic includeHelper;
        bool includeHelperCaptured = false;

        try {
          // Get the query builder from the model and extract include helper
          // The include helper will be passed directly in the new API
          final queryBuilder = model?.getQueryBuilder();
          if (queryBuilder != null) {
            // Try to get include property if it exists (for new API)
            try {
              includeHelper = (queryBuilder as dynamic).include;
              if (includeHelper != null) {
                includeHelperCaptured = true;
              }
            } catch (_) {
              // If include property doesn't exist, this is an error in new API
              throw StateError(
                'Include helper not found. Make sure the model has an include helper generated.',
              );
            }
          }
        } catch (e) {
          print('Warning: Failed to get include helper: $e');
        }

        if (includeHelperCaptured && includeHelper != null) {
          // Call the function with the include helper to get the nested includes
          // The function returns a List that should contain IncludeBuilder instances
          final functionResult = (include as dynamic)(includeHelper);
          if (functionResult is List) {
            // Convert the list to List<IncludeBuilder>
            resolvedIncludes = functionResult
                .map((item) => item as IncludeBuilder)
                .toList();
          } else {
            throw ArgumentError(
              'Include function must return a List<IncludeBuilder>.',
            );
          }
        } else {
          throw StateError(
            'Failed to get include helper for association "$association". '
            'Cannot resolve nested includes function.',
          );
        }
      } else {
        throw ArgumentError(
          'Include must be either List<IncludeBuilder> or '
          'List<IncludeBuilder> Function(dynamic).',
        );
      }

      // Recursively convert nested includes - supports infinite nesting levels
      result['include'] = resolvedIncludes.map((inc) => inc.toJson()).toList();
    }

    if (through != null) result['through'] = through;

    // Handle 'on' clause (custom ON condition)
    if (on != null && all != true) {
      QueryOperator? onOperator;

      if (on is QueryOperator) {
        onOperator = on as QueryOperator;
      } else if (on is Function) {
        // Resolve the function - similar to where clause
        final onFunction = on as QueryOperator Function(dynamic);

        dynamic columns;
        bool columnsCaptured = false;

        try {
          final queryBuilder = model?.getQueryBuilder();
          if (queryBuilder != null) {
            try {
              columns = (queryBuilder as dynamic).columns;
              if (columns != null) {
                columnsCaptured = true;
              }
            } catch (_) {
              columns = queryBuilder;
              columnsCaptured = true;
            }
          }
        } catch (e) {
          print('Warning: Failed to get columns for ON clause: $e');
        }

        if (columnsCaptured && columns != null) {
          onOperator = onFunction(columns);
        } else {
          throw StateError(
            'Failed to get columns for ON clause in association "$association". '
            'Make sure the model has a columns class generated.',
          );
        }
      }

      if (onOperator != null) {
        result['on'] = onOperator.toJson();
      }
    }

    return result;
  }
}
