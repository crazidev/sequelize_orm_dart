part of '../../sequelize_model_generator.dart';

void _generateClassCreate(
  StringBuffer buffer,
  String createClassName,
  List<_FieldInfo> fields,
) {
  buffer.writeln('class $createClassName {');
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln('  final ${field.dartType} ${field.fieldName};');
    }
  }
  buffer.writeln();
  buffer.writeln('  $createClassName({');
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln('    required this.${field.fieldName},');
    }
  }
  buffer.writeln('  });');
  buffer.writeln();
  buffer.writeln('  Map<String, dynamic> toJson() {');
  buffer.writeln('    return {');
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln("      '${field.name}': ${field.fieldName},");
    }
  }
  buffer.writeln('    };');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();
}
