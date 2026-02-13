part of '../../sequelize_model_generator.dart';

/// Returns the name of the runtime parse helper function for a given Dart type.
/// These functions live in `package:sequelize_orm/src/utils/parse_helpers.dart`.
String _parserFunctionForType(String dartType) {
  switch (dartType) {
    case 'int':
      return 'parseIntValue';
    case 'SequelizeBigInt':
      return 'parseSequelizeBigIntValue';
    case 'double':
      return 'parseDoubleValue';
    case 'bool':
      return 'parseBoolValue';
    case 'DateTime':
      return 'parseDateTimeValue';
    case 'String':
      return 'parseStringValue';
    case 'Map<String, dynamic>':
      return 'parseMapValue';
    case 'List<int>':
      return 'parseBlobValue';
    default:
      // Fallback: pass through without parsing
      return '';
  }
}

/// Generates a single field expression for `fromJson`.
///
/// With the shared parse helpers, each field becomes a clean one-liner:
///   `_p('field_name', parseIntValue, 'int')`
///
/// For types without a dedicated parser (default case), falls back to raw access.
String _generateJsonValueParser(_FieldInfo field, {required String modelName}) {
  final parser = _parserFunctionForType(field.dartType);
  if (parser.isEmpty) {
    // No dedicated parser — pass through raw
    return "json['${field.name}']";
  }
  return "_p('${field.name}', $parser, '${field.dartType}')";
}
