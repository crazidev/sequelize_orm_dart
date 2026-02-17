part of '../../sequelize_model_generator.dart';

String _toCamelCase(String str) {
  if (str.isEmpty) return str;
  // Basic snake_case to camelCase conversion
  final parts = str.split('_');
  if (parts.length == 1) return str[0].toLowerCase() + str.substring(1);

  final buffer = StringBuffer(parts[0].toLowerCase());
  for (var i = 1; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    buffer
        .write(parts[i][0].toUpperCase() + parts[i].substring(1).toLowerCase());
  }
  return buffer.toString();
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

/// Handle Dart reserved words by prefixing with $
String _sanitizeIdentifier(String name) {
  const dartKeywords = {
    'assert',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'else',
    'enum',
    'extends',
    'false',
    'final',
    'finally',
    'for',
    'if',
    'in',
    'is',
    'new',
    'null',
    'rethrow',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'while',
    'with',
  };

  if (dartKeywords.contains(name)) {
    return '\$$name';
  }
  return name;
}

/// Sanitizes an enum value to a valid Dart identifier and applies prefix
String _sanitizeEnumAccessor(String enumValue, String prefix) {
  // Convert to camelCase
  String sanitized = _toCamelCase(enumValue);

  // Apply prefix if provided
  if (prefix.isNotEmpty) {
    sanitized = prefix + _capitalize(sanitized);
  }

  return _sanitizeIdentifier(sanitized);
}

String _getEnumName(String className, String fieldName) {
  return '$className${_capitalize(fieldName)}';
}
