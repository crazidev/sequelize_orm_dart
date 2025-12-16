import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

// Export all operator extensions for convenience
export 'package:sequelize_dart/src/query/operators/extentions/extensions.dart';

/// Type-safe column reference for building queries
///
/// The [Column] class provides a type-safe way to reference database columns
/// in queries. All operators are implemented as extensions for cleaner organization.
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
