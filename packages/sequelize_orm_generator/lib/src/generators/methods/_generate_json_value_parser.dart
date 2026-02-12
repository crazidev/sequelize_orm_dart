part of '../../sequelize_model_generator.dart';

String _generateJsonValueParser(_FieldInfo field) {
  final jsonKey = "json['${field.name}']";

  // Handle DateTime fields from DB/JSON payloads.
  if (field.dartType == 'DateTime') {
    return '$jsonKey != null ? ($jsonKey is DateTime ? $jsonKey : ($jsonKey is int ? DateTime.fromMillisecondsSinceEpoch($jsonKey) : DateTime.parse($jsonKey.toString()))) : null';
  }

  // For all other types, just return the JSON value directly
  return jsonKey;
}
