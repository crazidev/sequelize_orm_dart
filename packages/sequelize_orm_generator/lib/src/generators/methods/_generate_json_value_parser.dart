part of '../../sequelize_model_generator.dart';

/// Returns the name of the runtime parse helper function for a given Dart type.
/// These functions live in `package:sequelize_orm/src/utils/parse_helpers.dart`.
///
/// When [isJsonColumn] is true, List/Map types use the JSON-aware parsers
/// (which handle String → jsonDecode from the bridge) instead of the BLOB parser.
String _parserFunctionForType(String dartType, {bool isJsonColumn = false}) {
  // JSON List types — emit generic tear-off: parseJsonList<InnerType>
  if (dartType.startsWith('List<') &&
      (isJsonColumn || dartType != 'List<int>')) {
    final inner = dartType.substring(5, dartType.length - 1);
    return 'parseJsonList<$inner>';
  }

  // JSON Map types — emit generic tear-off: parseJsonMap<ValueType>
  if (dartType.startsWith('Map<String, ')) {
    final inner = dartType.substring(12, dartType.length - 1);
    return 'parseJsonMap<$inner>';
  }

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
  final baseType = field.dataType.contains('(')
      ? field.dataType.split('(')[0]
      : field.dataType;
  final isJson = baseType == 'JSON' || baseType == 'JSONB';
  final isEnum = baseType == 'ENUM';

  if (isEnum && field.enumValues != null && field.enumValues!.isNotEmpty) {
    // Enum parsing: EnumName.fromValue(_p('key', parseStringValue, 'String'))
    final enumName = _getEnumName(modelName, field.fieldName);
    return "$enumName.fromValue(_p('${field.name}', parseStringValue, 'String'))";
  }

  final parser = _parserFunctionForType(field.dartType, isJsonColumn: isJson);
  if (parser.isEmpty) {
    // No dedicated parser — pass through raw
    return "json['${field.name}']";
  }
  return "_p('${field.name}', $parser, '${field.dartType}')";
}
