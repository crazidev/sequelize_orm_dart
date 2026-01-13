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
  final primaryKeys = fields.where((f) => f.primaryKey).toList();

  // Note: reload() is now provided by ReloadableMixin

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

  // Generate increment/decrement methods only if there are numeric fields
  if (numericFields.isNotEmpty) {
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
    buffer.writeln();
  }

  // Generate save() and update() methods if there are primary keys
  if (primaryKeys.isNotEmpty) {
    final updateableFields = fields
        .where((f) => !f.autoIncrement && !f.primaryKey)
        .toList();
    buffer.writeln('  /// Saves all changes made to this instance');
    buffer.writeln(
      '  /// Returns the number of affected rows (0 if no changes, 1 if updated)',
    );
    buffer.writeln('  Future<int> save({List<String>? fields}) async {');
    buffer.writeln('    final pkValues = getPrimaryKeyMap();');
    buffer.writeln('    if (pkValues == null || pkValues.isEmpty) {');
    buffer.writeln(
      '      throw StateError(\'Cannot save: instance has no primary key values\');',
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    // Build update data from current instance');
    buffer.writeln('    final data = toJson();');
    buffer.writeln('    // Remove primary keys from update data');
    for (final pk in primaryKeys) {
      buffer.writeln('    data.remove(\'${pk.name}\');');
    }
    buffer.writeln('    // Remove association fields from update data');
    for (final assoc in associations) {
      buffer.writeln('    data.remove(\'${assoc.as}\');');
    }
    buffer.writeln();
    buffer.writeln('    // Filter to specified fields if provided');
    buffer.writeln('    if (fields != null && fields.isNotEmpty) {');
    buffer.writeln('      final filteredData = <String, dynamic>{};');
    buffer.writeln('      for (final field in fields) {');
    buffer.writeln('        if (data.containsKey(field)) {');
    buffer.writeln('          filteredData[field] = data[field];');
    buffer.writeln('        }');
    buffer.writeln('      }');
    buffer.writeln('      data.clear();');
    buffer.writeln('      data.addAll(filteredData);');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    if (data.isEmpty) {');
    buffer.writeln('      // No changes to save');
    buffer.writeln('      return 0;');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    // Build primary key where clause');
    buffer.writeln('    final pkWhere = ($columnsClassName c) => ');
    if (primaryKeys.length == 1) {
      final key = primaryKeys.first.fieldName;
      buffer.writeln(
        '        c.$key.eq(pkValues[\'${primaryKeys.first.name}\']);',
      );
    } else {
      buffer.writeln('        and([');
      for (final pk in primaryKeys) {
        buffer.writeln(
          '          c.${pk.fieldName}.eq(pkValues[\'${pk.name}\']),',
        );
      }
      buffer.writeln('        ]);');
    }
    buffer.writeln();
    buffer.writeln('    // Extract values from data map for named parameters');
    buffer.write(
      '    final affectedRows = await $generatedClassName().update(',
    );
    buffer.writeln();
    // Generate named parameters by extracting from data map
    for (final field in updateableFields) {
      buffer.writeln(
        '      ${field.fieldName}: data[\'${field.name}\'] as ${field.dartType}?,',
      );
    }
    buffer.writeln('      where: pkWhere,');
    buffer.writeln('    );');
    buffer.writeln();
    buffer.writeln('    // Reload to get updated values from database');
    buffer.writeln('    if (affectedRows > 0) {');
    buffer.writeln('      await reload();');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    return affectedRows;');
    buffer.writeln('  }');
    buffer.writeln();

    // Generate update() instance method
    buffer.writeln('  /// Updates this instance with the provided data');
    buffer.writeln(
      '  /// Returns the number of affected rows (0 if not found, 1 if updated)',
    );
    buffer.writeln('  Future<int> update(Map<String, dynamic> data) async {');
    buffer.writeln('    if (data.isEmpty) {');
    buffer.writeln(
      '      throw ArgumentError(\'Data cannot be empty for update\');',
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    final pkValues = getPrimaryKeyMap();');
    buffer.writeln('    if (pkValues == null || pkValues.isEmpty) {');
    buffer.writeln(
      '      throw StateError(\'Cannot update: instance has no primary key values\');',
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    // Build primary key where clause');
    buffer.writeln('    final pkWhere = ($columnsClassName c) => ');
    if (primaryKeys.length == 1) {
      final key = primaryKeys.first.fieldName;
      buffer.writeln(
        '        c.$key.eq(pkValues[\'${primaryKeys.first.name}\']);',
      );
    } else {
      buffer.writeln('        and([');
      for (final pk in primaryKeys) {
        buffer.writeln(
          '          c.${pk.fieldName}.eq(pkValues[\'${pk.name}\']),',
        );
      }
      buffer.writeln('        ]);');
    }
    buffer.writeln();
    buffer.writeln('    // Extract values from data map for named parameters');
    buffer.write(
      '    final affectedRows = await $generatedClassName().update(',
    );
    buffer.writeln();
    // Generate named parameters by extracting from data map
    for (final field in updateableFields) {
      buffer.writeln(
        '      ${field.fieldName}: data[\'${field.name}\'] as ${field.dartType}?,',
      );
    }
    buffer.writeln('      where: pkWhere,');
    buffer.writeln('    );');
    buffer.writeln();
    buffer.writeln('    // Update local instance fields from provided data');
    buffer.writeln('    if (affectedRows > 0) {');
    buffer.writeln('      // Reload to get all updated values from database');
    buffer.writeln('      await reload();');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    return affectedRows;');
    buffer.writeln('  }');
    buffer.writeln();
  }
}
