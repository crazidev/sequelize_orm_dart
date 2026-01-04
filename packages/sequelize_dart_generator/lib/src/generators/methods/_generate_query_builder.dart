part of '../../sequelize_model_generator.dart';

void _generateQueryBuilder(
  StringBuffer buffer,
  String className,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations,
) {
  final queryBuilderClassName = '\$${className}Query';

  buffer.writeln('/// Type-safe query builder for $className');
  buffer.writeln('class $queryBuilderClassName {');
  buffer.writeln('  $queryBuilderClassName();'); // Constructor
  buffer.writeln();

  // Generate column references
  for (var field in fields) {
    final dartType = _getDartTypeForQuery(field.dataType);
    buffer.writeln(
      "  final ${field.fieldName} = Column<$dartType>('${field.name}', DataType.${field.dataType});",
    );
  }

  // Generate association references
  if (associations.isNotEmpty) {
    buffer.writeln();
    for (var assoc in associations) {
      final modelClassName = assoc.modelClassName;
      final associationName = assoc.as ?? assoc.fieldName;
      buffer.writeln(
        "  final ${assoc.fieldName} = AssociationReference<$modelClassName>('$associationName', $modelClassName.instance);",
      );
    }
  }

  // Generate include helper property
  if (associations.isNotEmpty) {
    final helperClassName = '\$${className}IncludeHelper';
    buffer.writeln();
    buffer.writeln('  final include = const $helperClassName();');
  }

  buffer.writeln();
  buffer.writeln(
    '  IncludeBuilder<$className> includeAll({bool nested = false}) {',
  );
  buffer.writeln(
    '    return IncludeBuilder<$className>(all: true, nested: nested);',
  );
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();
}
