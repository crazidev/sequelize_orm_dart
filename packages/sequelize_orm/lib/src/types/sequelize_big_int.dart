/// A wrapper type for SQL BIGINT values.
///
/// Sequelize always returns BIGINT as a string to prevent precision loss
/// in JavaScript (which cannot represent integers beyond 2^53 safely).
/// This type preserves that string representation while providing
/// typed access and conversion utilities.
///
/// ```dart
/// final id = SequelizeBigInt('9223372036854775807');
/// print(id.value);      // "9223372036854775807"
/// print(id.toBigInt());  // 9223372036854775807
/// print(id.toJson());    // "9223372036854775807"
/// ```
class SequelizeBigInt {
  /// The raw string representation of the bigint value.
  final String value;

  /// Creates a [SequelizeBigInt] from a string value.
  const SequelizeBigInt(this.value);

  /// Creates a [SequelizeBigInt] from a Dart [BigInt].
  SequelizeBigInt.fromBigInt(BigInt v) : value = v.toString();

  /// Creates a [SequelizeBigInt] from a Dart [int].
  SequelizeBigInt.fromInt(int v) : value = v.toString();

  /// Converts to a Dart [BigInt] for arithmetic operations.
  BigInt toBigInt() => BigInt.parse(value);

  /// Converts to a Dart [int].
  ///
  /// Only safe for values that fit in a 64-bit signed integer.
  /// Throws [FormatException] if the value is too large.
  int toInt() => int.parse(value);

  /// Always serializes as a string for the JS bridge.
  String toJson() => value;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SequelizeBigInt && other.value == value);

  @override
  int get hashCode => value.hashCode;
}
