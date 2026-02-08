part of '../../sequelize_model_generator.dart';

void _generateIncrementMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
  String whereCallbackName,
  List<_FieldInfo> fields,
  GeneratorNamingConfig namingConfig,
) {
  _generateNumericOperationMethod(
    buffer,
    className,
    valuesClassName,
    whereCallbackName,
    fields,
    'increment',
    namingConfig,
  );
}

void _generateDecrementMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
  String whereCallbackName,
  List<_FieldInfo> fields,
  GeneratorNamingConfig namingConfig,
) {
  _generateNumericOperationMethod(
    buffer,
    className,
    valuesClassName,
    whereCallbackName,
    fields,
    'decrement',
    namingConfig,
  );
}

void _generateNumericOperationMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
  String whereCallbackName,
  List<_FieldInfo> fields,
  String operation,
  GeneratorNamingConfig namingConfig,
) {
  final columnsClassName = namingConfig.getModelColumnsClassName(className);

  // Filter numeric fields (int, double, num) but exclude primary keys, auto-increment, and foreign key fields
  final numericFields = fields.where((field) {
    final dartType = field.dartType;
    final isNumeric =
        dartType == 'int' || dartType == 'double' || dartType == 'num';
    final isNotPrimaryKey = !field.primaryKey;
    final isNotAutoIncrement = !field.autoIncrement;
    final isNotForeignKey =
        !field.name.toLowerCase().contains('_id') &&
        !field.name.toLowerCase().endsWith('_id');
    return isNumeric &&
        isNotPrimaryKey &&
        isNotAutoIncrement &&
        isNotForeignKey;
  }).toList();

  if (numericFields.isEmpty) {
    return; // Don't generate method if no numeric fields
  }

  buffer.writeln('  @override');
  buffer.writeln('  Future<List<$valuesClassName>> $operation(');

  // Generate named parameters for each numeric field
  buffer.writeln('    {');
  for (final field in numericFields) {
    final fieldName = field.name;
    final camelCaseName = _toCamelCase(fieldName);
    buffer.writeln('      num? $camelCaseName,');
  }
  buffer.writeln(
    '      QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln('    }');

  buffer.writeln('  ) {');
  buffer.writeln('    final fields = <String, dynamic>{');

  // Add field assignments
  for (final field in numericFields) {
    final fieldName = field.name;
    final camelCaseName = _toCamelCase(fieldName);
    buffer.writeln(
      '      if ($camelCaseName != null) \'$fieldName\': $camelCaseName,',
    );
  }

  buffer.writeln('    };');
  buffer.writeln();
  buffer.writeln('    if (fields.isEmpty) {');
  buffer.writeln(
    '      throw ArgumentError(\'At least one field must be provided for $operation\');',
  );
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln('    if (where == null) {');
  buffer.writeln(
    '      throw ArgumentError(\'Where clause is required for $operation\');',
  );
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      columns: const $columnsClassName(),');
  buffer.writeln('    );');
  buffer.writeln();
  buffer.writeln('    return QueryEngine().$operation(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      fields: fields,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    ).then((results) =>');
  buffer.writeln('      results.map((result) {');
  buffer.writeln(
    '        final instance = $valuesClassName.fromJson(result.data);',
  );
  // TODO: Enable isNewRecord, changed & previous
  buffer.writeln('        return instance;');
  buffer.writeln('      }).toList()');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
