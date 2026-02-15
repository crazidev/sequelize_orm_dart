part of '../../sequelize_model_generator.dart';

void _generateColumns(
  StringBuffer buffer,
  String className,
  List<_FieldInfo> fields,
  GeneratorNamingConfig namingConfig,
) {
  final columnsClassName = namingConfig.getModelColumnsClassName(className);

  buffer.writeln('/// Type-safe columns for $className');
  buffer.writeln(
    '/// Contains only column references for use in where clauses',
  );
  buffer.writeln('class $columnsClassName {');
  buffer.writeln('  const $columnsClassName();');
  buffer.writeln();

  // Generate column references as static const for efficiency
  for (var field in fields) {
    final dartType = _getDartTypeForQuery(field.dataType, jsonDartTypeHint: field.jsonDartTypeHint);

    final typeExpression = _getDataTypeExpression(field);

    // Use JsonColumn for JSON/JSONB columns to enable fluent JSON path queries
    final baseType =
        field.dataType.contains('(')
            ? field.dataType.split('(')[0]
            : field.dataType;
    final isJson = baseType == 'JSON' || baseType == 'JSONB';

    if (isJson) {
      // Determine the generic type for JsonColumn based on jsonDartTypeHint
      final jsonTypeParam =
          (field.jsonDartTypeHint != null &&
                  field.jsonDartTypeHint!.startsWith('List<'))
              ? field.jsonDartTypeHint!
              : 'dynamic';
      buffer.writeln(
        "  final ${field.fieldName} = const JsonColumn<$jsonTypeParam>('${field.name}', $typeExpression);",
      );
    } else {
      buffer.writeln(
        "  final ${field.fieldName} = const Column<$dartType>('${field.name}', $typeExpression);",
      );
    }
  }

  buffer.writeln('}');
  buffer.writeln();
}
