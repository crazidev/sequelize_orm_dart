part of '../../sequelize_model_generator.dart';

void _generateColumns(
  StringBuffer buffer,
  String className,
  List<_FieldInfo> fields,
) {
  final columnsClassName = '\$${className}Columns';

  buffer.writeln('/// Type-safe columns for $className');
  buffer.writeln(
    '/// Contains only column references for use in where clauses',
  );
  buffer.writeln('class $columnsClassName {');
  buffer.writeln('  const $columnsClassName();');
  buffer.writeln();

  // Generate column references as static const for efficiency
  for (var field in fields) {
    final dartType = _getDartTypeForQuery(field.dataType);
    buffer.writeln(
      "  final ${field.fieldName} = const Column<$dartType>('${field.name}', DataType.${field.dataType});",
    );
  }

  buffer.writeln('}');
  buffer.writeln();
}
