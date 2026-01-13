part of '../../sequelize_model_generator.dart';

void _generateQueryBuilder(
  StringBuffer buffer,
  String className,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations,
) {
  final queryBuilderClassName = '\$${className}Query';
  final columnsClassName = '\$${className}Columns';

  buffer.writeln('/// Type-safe query builder for $className');
  buffer.writeln(
    '/// Extends $columnsClassName to provide column access plus associations',
  );
  buffer.writeln('class $queryBuilderClassName extends $columnsClassName {');

  // Can't use const if we have associations (AssociationReference uses .instance which isn't const)
  if (associations.isEmpty) {
    buffer.writeln('  const $queryBuilderClassName();');
  } else {
    buffer.writeln('  $queryBuilderClassName();');
  }

  // Generate association references (columns are inherited from $columnsClassName)
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
