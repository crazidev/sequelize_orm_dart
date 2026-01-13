part of '../../sequelize_model_generator.dart';

void _generateInstanceMethods(
  StringBuffer buffer,
  String valuesClassName,
  String className,
  String generatedClassName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations,
) {
  final columnsClassName = '\$${className}Columns';
  final whereCallbackName = _toCamelCase(className);
  final includeHelperClassName = '\$${className}IncludeHelper';

  // Generate reload method (always available, not just for numeric fields)
  final primaryKeys = fields.where((f) => f.primaryKey).toList();
  if (primaryKeys.isNotEmpty) {
    buffer.writeln('  Future<$valuesClassName?> reload() async {');
    buffer.writeln('    // Get instance primary key WHERE clause');
    buffer.writeln('    final instanceWhereClause = this.where();');
    buffer.writeln('    if (instanceWhereClause == null) {');
    buffer.writeln(
      '      throw StateError(\'Cannot reload: instance has no primary key values\');',
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln(
      '    // Convert instance where() Map to QueryOperator function',
    );
    _generateMapToWhereClause(
      buffer,
      whereCallbackName,
      primaryKeys,
      'primaryKeyWhere',
      columnsClassName,
    );
    buffer.writeln();
    buffer.writeln(
      '    // If _originalQuery exists, use it; otherwise use only primary key WHERE',
    );
    buffer.writeln('    final result = await $generatedClassName().findOne(');
    buffer.writeln('      where: primaryKeyWhere,');
    buffer.writeln('      include: _originalQuery?.include != null');
    buffer.writeln(
      '          ? ($includeHelperClassName helper) => _originalQuery!.include!',
    );
    buffer.writeln('          : null,');
    buffer.writeln('      order: _originalQuery?.order,');
    buffer.writeln('      group: _originalQuery?.group,');
    buffer.writeln('      limit: _originalQuery?.limit,');
    buffer.writeln('      offset: _originalQuery?.offset,');
    buffer.writeln('      attributes: _originalQuery?.attributes,');
    buffer.writeln('    );');
    buffer.writeln();
    buffer.writeln('    if (result == null) {');
    buffer.writeln('      return null;');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    _updateFields(result);');
    buffer.writeln('    // Preserve original query for future reloads');
    buffer.writeln(
      '    _originalQuery = result._originalQuery ?? _originalQuery;',
    );
    buffer.writeln();
    buffer.writeln('    return this;');
    buffer.writeln('  }');
    buffer.writeln();
  }

  // Filter numeric fields (same as static method)
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
    return; // Don't generate methods if no numeric fields
  }

  // Generate increment method
  buffer.writeln('  Future<$valuesClassName?> increment(');
  buffer.writeln('    {');
  for (final field in numericFields) {
    final fieldName = field.name;
    final camelCaseName = _toCamelCase(fieldName);
    buffer.writeln('      int? $camelCaseName,');
  }
  buffer.writeln(
    '      QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln('    }');
  buffer.writeln('  ) async {');
  buffer.writeln('    final fields = <String, dynamic>{');
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
    '      throw ArgumentError(\'At least one field must be provided for increment\');',
  );
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln('    // Merge instance where() with optional where clause');
  buffer.writeln('    final finalWhere = _mergeWhere(where);');
  buffer.writeln();
  buffer.writeln('    // Call static increment method');
  buffer.writeln(
    '    final result = await $generatedClassName().increment(',
  );
  if (numericFields.isNotEmpty) {
    buffer.write('      ');
    for (var i = 0; i < numericFields.length; i++) {
      final field = numericFields[i];
      final camelCaseName = _toCamelCase(field.name);
      buffer.write('$camelCaseName: $camelCaseName');
      if (i < numericFields.length - 1) {
        buffer.write(',\n      ');
      }
    }
    buffer.writeln(',');
  }
  buffer.writeln('      where: finalWhere,');
  buffer.writeln('    );');
  buffer.writeln();
  buffer.writeln('    final updated = result.firstOrNull;');
  buffer.writeln('    if (updated == null) {');
  buffer.writeln('      return null;');
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln('    _updateFields(updated);');
  buffer.writeln('    return this;');
  buffer.writeln('  }');
  buffer.writeln();

  // Generate decrement method (same pattern as increment)
  buffer.writeln('  Future<$valuesClassName?> decrement(');
  buffer.writeln('    {');
  for (final field in numericFields) {
    final fieldName = field.name;
    final camelCaseName = _toCamelCase(fieldName);
    buffer.writeln('      int? $camelCaseName,');
  }
  buffer.writeln(
    '      QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln('    }');
  buffer.writeln('  ) async {');
  buffer.writeln('    final fields = <String, dynamic>{');
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
    '      throw ArgumentError(\'At least one field must be provided for decrement\');',
  );
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln('    // Merge instance where() with optional where clause');
  buffer.writeln('    final finalWhere = _mergeWhere(where);');
  buffer.writeln();
  buffer.writeln('    // Call static decrement method');
  buffer.writeln(
    '    final result = await $generatedClassName().decrement(',
  );
  if (numericFields.isNotEmpty) {
    buffer.write('      ');
    for (var i = 0; i < numericFields.length; i++) {
      final field = numericFields[i];
      final camelCaseName = _toCamelCase(field.name);
      buffer.write('$camelCaseName: $camelCaseName');
      if (i < numericFields.length - 1) {
        buffer.write(',\n      ');
      }
    }
    buffer.writeln(',');
  }
  buffer.writeln('      where: finalWhere,');
  buffer.writeln('    );');
  buffer.writeln();
  buffer.writeln('    final updated = result.firstOrNull;');
  buffer.writeln('    if (updated == null) {');
  buffer.writeln('      return null;');
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln('    _updateFields(updated);');
  buffer.writeln('    return this;');
  buffer.writeln('  }');
  buffer.writeln();
}

void _generateMapToWhereClause(
  StringBuffer buffer,
  String whereCallbackName,
  List<_FieldInfo> primaryKeys,
  String variableName,
  String columnsClassName,
) {
  if (primaryKeys.isEmpty) {
    buffer.writeln(
      '      $variableName = ($whereCallbackName) => throw ArgumentError(\'No primary keys found\');',
    );
    return;
  }

  buffer.writeln(
    '      QueryOperator Function($columnsClassName $whereCallbackName) $variableName;',
  );
  if (primaryKeys.length == 1) {
    final key = primaryKeys.first.fieldName;
    buffer.writeln('      final keyValue = instanceWhereClause[\'$key\'];');
    buffer.writeln(
      '      $variableName = ($whereCallbackName) => $whereCallbackName.$key.eq(keyValue);',
    );
  } else {
    buffer.writeln('      $variableName = ($whereCallbackName) {');
    buffer.writeln('        final conditions = <QueryOperator>[];');
    for (final pk in primaryKeys) {
      final key = pk.fieldName;
      final valueVar = '${key}Value';
      buffer.writeln(
        '        final $valueVar = instanceWhereClause[\'$key\'];',
      );
      buffer.writeln('        if ($valueVar != null) {');
      buffer.writeln(
        '          conditions.add($whereCallbackName.$key.eq($valueVar));',
      );
      buffer.writeln('        }');
    }
    buffer.writeln('        return and(conditions);');
    buffer.writeln('      };');
  }
}
