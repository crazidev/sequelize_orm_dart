part of '../../sequelize_model_generator.dart';

String _getModelUpdateClassName(String className) {
  return '\$${className}Update';
}

void _generateClassUpdate(
  StringBuffer buffer,
  String updateClassName,
  List<_FieldInfo> fields,
) {
  buffer.writeln('class $updateClassName {');
  // Add regular fields (same as Create - non-primary-key, non-auto-increment)
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln('  final ${field.dartType}? ${field.fieldName};');
    }
  }

  buffer.writeln();
  buffer.writeln('  $updateClassName({');
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln('    this.${field.fieldName},');
    }
  }
  buffer.writeln('  });');
  buffer.writeln();
  buffer.writeln('  Map<String, dynamic> toJson() {');
  buffer.writeln('    final result = <String, dynamic>{};');

  // Add regular fields
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln(
        "    if (${field.fieldName} != null) result['${field.name}'] = ${field.fieldName};",
      );
    }
  }

  buffer.writeln('    return result;');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();
}
