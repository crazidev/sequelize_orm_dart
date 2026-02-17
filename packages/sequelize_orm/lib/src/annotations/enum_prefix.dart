/// Configures the prefix for generated enum value accessors.
///
/// By default, enum values are generated using the raw value name.
/// Use this annotation to add a custom prefix for equality checks
/// and an optional prefix for negation checks.
///
/// {@category Models}
///
/// Example:
/// ```dart
/// // With 'is' and 'not' prefixes
/// @EnumPrefix('is', 'not')
/// DataType status = DataType.ENUM(['active', 'pending']);
/// // Generates:
/// // users.status.isActive -> users.status.eq.isActive
/// // users.status.notActive -> users.status.not.isActive
/// ```
class EnumPrefix {
  /// The prefix for equality checks (e.g., 'is').
  final String? prefix;

  /// The prefix for negation checks (e.g., 'not').
  final String? opposite;

  /// Creates an enum prefix annotation.
  ///
  /// [prefix] is used for equality accessors (e.g., isActive).
  /// [opposite] is used for negation accessors (e.g., notActive).
  const EnumPrefix([this.prefix, this.opposite]);
}
