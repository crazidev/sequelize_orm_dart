import 'package:sequelize_dart_annotations/src/datatype.dart';

/// Attribute class for model field definitions
///
/// Used in model definitions like:
/// ```dart
/// @NotNull
/// Attribute firstName = Attribute(DataType.STRING);
/// ```
///
/// The generator will convert this to ColumnDefinition in the generated code.
class Attribute {
  /// The data type for this attribute
  final DataType type;

  const Attribute(this.type);
}
