import 'package:sequelize_orm/src/annotations.dart';

// Export all operator extensions for convenience
export 'package:sequelize_orm/src/query/operators/extentions/extensions.dart';

// Export JSON column types for fluent JSON path queries
export 'package:sequelize_orm/src/query/json_column.dart';

/// Type-safe column reference for building queries.
///
/// The [Column] class provides a type-safe way to reference database columns
/// in queries. All operators are implemented as extensions for cleaner organization.
///
/// {@category Querying}
///
/// Available operator extensions:
/// - [BasicComparisonExtension] - eq, ne (equality)
/// - [NumericComparisonExtension] - gt, gte, lt, lte, between, notBetween
/// - [ListOperatorsExtension] - in_, notIn, all, any
/// - [StringOperatorsExtension] - like, notLike, startsWith, endsWith, substring, iLike, notILike
/// - [IsOperatorsExtension] - isNull, isNotNull, isTrue, isFalse, isNotTrue, isNotFalse
/// - [RegexOperatorsExtension] - regexp, notRegexp, iRegexp, notIRegexp
/// - [MiscOperatorsExtension] - col, match
/// - [LegacyOperatorsExtension] - backward compatibility aliases
class Column<T> {
  final String name;
  final DataType? dataType;

  const Column(this.name, [this.dataType]);
}
