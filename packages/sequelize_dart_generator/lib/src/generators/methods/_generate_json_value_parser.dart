part of '../../sequelize_model_generator.dart';

String _generateJsonValueParser(_FieldInfo field) {
  final jsonKey = "json['${field.name}']";

  // Handle DateTime fields - parse string to DateTime
  if (field.dartType == 'DateTime') {
    return '$jsonKey != null ? ($jsonKey is DateTime ? $jsonKey : DateTime.parse($jsonKey as String)) : null';
  }

  // For all other types, just return the JSON value directly
  return jsonKey;
}
