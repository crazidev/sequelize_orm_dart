import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/typed_column.dart';

/// Legacy/Compatibility operators for backward compatibility
///
/// These are aliases for the new operator methods. Use the new methods instead.
///
/// | Legacy Method         | New Method |
/// |-----------------------|------------|
/// | `equal()`             | `eq()`     |
/// | `not()`               | `ne()`     |
/// | `greaterThan()`       | `gt()`     |
/// | `lessThan()`          | `lt()`     |
/// | `greaterThanOrEqual()`| `gte()`    |
/// | `lessThanOrEqual()`   | `lte()`    |
/// | `like_()`             | `like()`   |
extension LegacyOperatorsExtension<T> on Column<T> {
  /// Equal (legacy alias for [eq])
  ///
  /// @Deprecated('Use eq() instead')
  ComparisonOperator equal(T value) => eq(value);

  /// Not equal (legacy alias for [ne])
  ///
  /// @Deprecated('Use ne() instead')
  ComparisonOperator not(T value) => ne(value);

  /// Greater than (legacy alias for [gt])
  ///
  /// @Deprecated('Use gt() instead')
  ComparisonOperator greaterThan(T value) => gt(value);

  /// Less than (legacy alias for [lt])
  ///
  /// @Deprecated('Use lt() instead')
  ComparisonOperator lessThan(T value) => lt(value);

  /// Greater than or equal (legacy alias for [gte])
  ///
  /// @Deprecated('Use gte() instead')
  ComparisonOperator greaterThanOrEqual(T value) => gte(value);

  /// Less than or equal (legacy alias for [lte])
  ///
  /// @Deprecated('Use lte() instead')
  ComparisonOperator lessThanOrEqual(T value) => lte(value);

  /// Like (legacy alias for [like])
  ///
  /// @Deprecated('Use like() instead')
  ComparisonOperator like_(String pattern) => like(pattern);
}
