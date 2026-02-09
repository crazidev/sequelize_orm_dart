part of '../../sequelize_model_generator.dart';

void _generateClassUpdate(
  StringBuffer buffer,
  String updateClassName,
  List<_FieldInfo> fields,
) {
  buffer.writeln('class $updateClassName {');
  // Add regular fields (omit primary keys and auto-increment — these identify the row and should not be updated)
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln('  final ${field.dartType}? ${field.fieldName};');
    }
  }

  buffer.writeln();
  final updateFields = fields
      .where((field) => !field.autoIncrement && !field.primaryKey)
      .toList();
  if (updateFields.isEmpty) {
    buffer.writeln('  $updateClassName();');
  } else {
    buffer.writeln('  $updateClassName({');
    for (var field in updateFields) {
      buffer.writeln('    this.${field.fieldName},');
    }
    buffer.writeln('  });');
  }
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
