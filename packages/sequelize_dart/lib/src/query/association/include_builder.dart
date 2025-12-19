import 'package:sequelize_dart/src/model/model_interface.dart';
import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/query/query.dart';

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
  final List<List<String>>? order;

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
    this.limit,
    this.offset,
    this.include,
    this.through,
  }) : assert(
         (all == true && association == null && model == null) ||
             ((all == null || all == false) &&
                 association != null &&
                 model != null),
         'When all is true, association and model must be null. '
         'When all is not true, association and model are required.',
       );

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

    if (where != null && all != true) {
      // where clause only makes sense for specific associations, not for all: true
      QueryOperator? whereOperator;

      if (where is QueryOperator) {
        whereOperator = where as QueryOperator;
      } else if (where is Function) {
        // Resolve the function by getting the query builder from the model
        final whereFunction = where as QueryOperator Function(dynamic);

        // Get the query builder by calling the model's findAll
        // We use dynamic to call findAll since Model is generic
        // Note: This will execute a query, but we only need the builder from the callback
        dynamic queryBuilder;
        bool builderCaptured = false;

        try {
          // Call findAll on the model (which is a Model<T> instance)
          // IMPORTANT: This will execute a query, but we need the query builder from the callback
          // The callback receives the query builder before the query executes
          // We return an empty query to minimize execution overhead
          (model as dynamic).findAll((builder) {
            queryBuilder = builder;
            builderCaptured = true;
            // Return an empty query - the query will still execute but we got the builder
            return Query();
          });
        } catch (e) {
          // If findAll throws during execution, we might still have captured the builder
          // The builder is captured in the callback before the query executes
          // So even if execution fails, we should have the builder
        }

        if (builderCaptured && queryBuilder != null) {
          // Resolve the function with the query builder
          whereOperator = whereFunction(queryBuilder);
        } else {
          throw StateError(
            'Failed to get query builder for association "$association". '
            'The where function requires a query builder instance. '
            'Make sure the model has a query builder class generated and the extensions are imported.',
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

    if (order != null) result['order'] = order;
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
        // Function that takes a query builder and returns List<IncludeBuilder>
        // Get the query builder from the model
        dynamic queryBuilder;
        bool builderCaptured = false;

        try {
          // Call findAll on the model to get the query builder instance
          (model as dynamic).findAll((builder) {
            queryBuilder = builder;
            builderCaptured = true;
            // Return an empty query - the query will execute but we got the builder
            return Query();
          });
        } catch (e) {
          // If findAll throws during execution, we might still have the builder
        }

        if (builderCaptured && queryBuilder != null) {
          // Call the function with the query builder to get the nested includes
          // The function returns a List that should contain IncludeBuilder instances
          final functionResult = (include as dynamic)(queryBuilder);
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
            'Failed to get query builder for association "$association". '
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

    return result;
  }
}
