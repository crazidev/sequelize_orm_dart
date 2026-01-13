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
  final includeHelperClassName = '\$${className}IncludeHelper';

  // Generate reload method (always available, not just for numeric fields)
  final primaryKeys = fields.where((f) => f.primaryKey).toList();
  if (primaryKeys.isNotEmpty) {
    buffer.writeln('  /// Reloads this instance from the database');
    buffer.writeln('  Future<$valuesClassName?> reload() async {');
    buffer.writeln('    final pk = this.where();');
    buffer.writeln(
      '    if (pk == null) throw StateError(\'Cannot reload: no primary key\');',
    );

    // Generate primary key where builder (compact)
    if (primaryKeys.length == 1) {
      final key = primaryKeys.first.fieldName;
      buffer.writeln('    final pkWhere = (c) => c.$key.eq(pk[\'$key\']);');
    } else {
      buffer.writeln('    final pkWhere = (c) => and([');
      for (final pk in primaryKeys) {
        final key = pk.fieldName;
        buffer.writeln(
          '      if (pk[\'$key\'] != null) c.$key.eq(pk[\'$key\']),',
        );
      }
      buffer.writeln('    ]);');
    }

    buffer.writeln('    final q = _originalQuery;');
    buffer.writeln('    final result = await $generatedClassName().findOne(');
    buffer.writeln('      where: pkWhere,');
    buffer.writeln(
      '      include: q?.include != null ? ($includeHelperClassName _) => q!.include! : null,',
    );
    buffer.writeln(
      '      order: q?.order, group: q?.group, limit: q?.limit, offset: q?.offset, attributes: q?.attributes,',
    );
    buffer.writeln('    );');
    buffer.writeln('    if (result == null) return null;');
    buffer.writeln('    _updateFields(result);');
    buffer.writeln('    _originalQuery = result._originalQuery ?? q;');
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

  if (numericFields.isEmpty) return;

  // Generate increment method (compact)
  buffer.writeln('  /// Increments numeric fields and updates this instance');
  buffer.write('  Future<$valuesClassName?> increment({');
  for (final field in numericFields) {
    buffer.write('int? ${_toCamelCase(field.name)}, ');
  }
  buffer.writeln(
    'QueryOperator Function($columnsClassName c)? where}) async {',
  );

  // Build fields map inline
  buffer.write('    final fields = {');
  for (var i = 0; i < numericFields.length; i++) {
    final camelName = _toCamelCase(numericFields[i].name);
    buffer.write(
      "if ($camelName != null) '${numericFields[i].name}': $camelName",
    );
    if (i < numericFields.length - 1) buffer.write(', ');
  }
  buffer.writeln('};');
  buffer.writeln(
    '    if (fields.isEmpty) throw ArgumentError(\'At least one field required\');',
  );

  // Call static method with all field params
  buffer.write('    final result = await $generatedClassName().increment(');
  for (final field in numericFields) {
    final camelName = _toCamelCase(field.name);
    buffer.write('$camelName: $camelName, ');
  }
  buffer.writeln('where: _mergeWhere(where));');

  buffer.writeln('    final updated = result.firstOrNull;');
  buffer.writeln('    if (updated == null) return null;');
  buffer.writeln('    _updateFields(updated);');
  buffer.writeln('    return this;');
  buffer.writeln('  }');
  buffer.writeln();

  // Generate decrement method (compact)
  buffer.writeln('  /// Decrements numeric fields and updates this instance');
  buffer.write('  Future<$valuesClassName?> decrement({');
  for (final field in numericFields) {
    buffer.write('int? ${_toCamelCase(field.name)}, ');
  }
  buffer.writeln(
    'QueryOperator Function($columnsClassName c)? where}) async {',
  );

  // Build fields map inline
  buffer.write('    final fields = {');
  for (var i = 0; i < numericFields.length; i++) {
    final camelName = _toCamelCase(numericFields[i].name);
    buffer.write(
      "if ($camelName != null) '${numericFields[i].name}': $camelName",
    );
    if (i < numericFields.length - 1) buffer.write(', ');
  }
  buffer.writeln('};');
  buffer.writeln(
    '    if (fields.isEmpty) throw ArgumentError(\'At least one field required\');',
  );

  // Call static method with all field params
  buffer.write('    final result = await $generatedClassName().decrement(');
  for (final field in numericFields) {
    final camelName = _toCamelCase(field.name);
    buffer.write('$camelName: $camelName, ');
  }
  buffer.writeln('where: _mergeWhere(where));');

  buffer.writeln('    final updated = result.firstOrNull;');
  buffer.writeln('    if (updated == null) return null;');
  buffer.writeln('    _updateFields(updated);');
  buffer.writeln('    return this;');
  buffer.writeln('  }');
}
