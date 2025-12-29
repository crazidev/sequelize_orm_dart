/// Base class for include helpers
///
/// Include helpers are generated per model and provide type-safe methods
/// for including associations. Each method returns an [IncludeBuilder] instance.
///
/// Example:
/// ```dart
/// Users.instance.findAll(
///   include: (include) => [
///     include.posts(
///       where: (postColumns) => and([postColumns.id.eq(1)]),
///     ),
///   ],
/// );
/// ```
abstract class IncludeHelper {
  const IncludeHelper();
}
