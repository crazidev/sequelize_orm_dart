part of '../../sequelize_model_generator.dart';

void _generateInstanceMethods(
  StringBuffer buffer,
  String valuesClassName,
  String className,
  String generatedClassName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations,
  GeneratorNamingConfig namingConfig,
) {
  final columnsClassName = namingConfig.getModelColumnsClassName(className);
  final primaryKeys = fields.where((f) => f.primaryKey).toList();

  // Note: reload() is now provided by ReloadableMixin

  // Filter numeric fields (same as static method)
  final numericFields = fields.where((field) {
    final dartType = field.dartType;
    final isNumeric =
        dartType == 'int' || dartType == 'double' || dartType == 'num';
    final isNotPrimaryKey = !field.primaryKey;
    final isNotAutoIncrement = !field.autoIncrement;
    final isNotForeignKey = !field.name.toLowerCase().contains('_id') &&
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
      buffer.write('num? ${_toCamelCase(field.name)}, ');
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
      buffer.write('num? ${_toCamelCase(field.name)}, ');
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
    final updateableFields =
        fields.where((f) => !f.autoIncrement && !f.primaryKey).toList();
    buffer.writeln('  /// Saves all changes made to this instance');
    buffer.writeln(
      '  /// Returns the number of affected rows (0 if no changes, 1 if updated/created)',
    );
    buffer.writeln('  Future<int> save({List<String>? fields}) async {');
    buffer.writeln('    // Get current data from instance (before any reload)');
    buffer.writeln('    // This preserves user modifications');
    buffer.writeln('    final currentData = toJson();');
    buffer.writeln();
    buffer.writeln('    // Get primary key values');
    buffer.writeln(
      '    final pkValues = getPrimaryKeyMap() ?? <String, dynamic>{};',
    );
    buffer.writeln();
    buffer.writeln(
      '    // If we have a primary key but no previousData, reload to get full data from DB',
    );
    buffer.writeln(
      '    // This ensures foreign keys and other fields are preserved when saving',
    );
    buffer.writeln(
      '    // Note: currentData is captured before reload to preserve user modifications',
    );
    buffer.writeln(
      '    if (pkValues.isNotEmpty && previousDataValues == null) {',
    );
    buffer.writeln('      await reload();');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    // Get previous data values (null if new record)');
    buffer.writeln('    final previousData = previousDataValues;');
    buffer.writeln();
    buffer.writeln(
      '    // Merge previousData with currentData to preserve foreign keys and other fields',
    );
    buffer.writeln(
      '    // This ensures fields that exist in DB but are null in current instance are preserved',
    );
    buffer.writeln(
      '    // Start with previousData, then overlay non-null values from currentData',
    );
    buffer.writeln(
      '    final mergedData = <String, dynamic>{...?previousData};',
    );
    buffer.writeln('    for (final entry in currentData.entries) {');
    buffer.writeln(
      '      // Only update with non-null values from currentData',
    );
    buffer.writeln(
      '      // This preserves previousData values when currentData has null',
    );
    buffer.writeln('      if (entry.value != null) {');
    buffer.writeln('        mergedData[entry.key] = entry.value;');
    buffer.writeln('      }');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    // Filter to specified fields if provided');
    buffer.writeln(
      '    // Always include primary key fields even if not in fields list (required for UPDATE)',
    );
    buffer.writeln(
      '    final dataToSave = (fields != null && fields.isNotEmpty)',
    );
    buffer.writeln('        ? <String, dynamic>{');
    // Include primary key fields first (required for Sequelize to identify the record)
    for (final pk in primaryKeys) {
      buffer.writeln(
        '            \'${pk.name}\': mergedData[\'${pk.name}\'],',
      );
    }
    // Then include specified fields (excluding primary keys to avoid duplicates)
    buffer.writeln('            for (final f in fields)');
    buffer.writeln(
      '              if (mergedData[f] != null && !pkValues.containsKey(f))',
    );
    buffer.writeln('                f: mergedData[f]');
    buffer.writeln('          }');
    buffer.writeln('        : mergedData;');
    buffer.writeln();
    buffer.writeln('    // Call bridge save handler');
    buffer.writeln('    final result = await QueryEngine().save(');
    buffer.writeln('      modelName: $generatedClassName().modelName,');
    buffer.writeln('      currentData: dataToSave,');
    buffer.writeln('      previousData: previousData,');
    buffer.writeln('      primaryKeyValues: pkValues,');
    buffer.writeln('      sequelize: $generatedClassName().sequelizeInstance,');
    buffer.writeln('      model: $generatedClassName().sequelizeModel,');
    buffer.writeln('    );');
    buffer.writeln();
    buffer.writeln('    // Update instance fields from result');
    buffer.writeln(
      '    final updatedInstance = $valuesClassName.fromJson(result.data, operation: \'save\');',
    );
    buffer.writeln('    _updateFields(updatedInstance);');
    buffer.writeln();
    buffer.writeln('    // Update previous data snapshot');
    buffer.writeln('    setPreviousDataValues(toJson());');
    buffer.writeln();
    buffer.writeln('    return 1; // save() always returns 1 if successful');
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
      if (field.enumValues != null && field.enumValues!.isNotEmpty) {
        final enumName = _getEnumName(className, field.fieldName);
        buffer.writeln(
          "      ${field.fieldName}: $enumName.fromValue(data['${field.name}'] as String?),",
        );
      } else {
        buffer.writeln(
          "      ${field.fieldName}: data['${field.name}'] as ${field.dartType}?,",
        );
      }
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

    // Generate destroy() instance method
    buffer.writeln('  /// Destroys this instance (deletes from database)');
    buffer.writeln(
      '  /// For paranoid models, sets deletedAt unless force is true',
    );
    buffer.writeln('  Future<void> destroy({bool? force}) async {');
    buffer.writeln('    final pkValues = getPrimaryKeyMap();');
    buffer.writeln('    if (pkValues == null || pkValues.isEmpty) {');
    buffer.writeln(
      '      throw StateError(\'Cannot destroy: instance has no primary key values\');',
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    final options = <String, dynamic>{};');
    buffer.writeln('    if (force != null) options[\'force\'] = force;');
    buffer.writeln();
    buffer.writeln('    await QueryEngine().instanceDestroy(');
    buffer.writeln('      modelName: $generatedClassName().modelName,');
    buffer.writeln('      primaryKeyValues: pkValues,');
    buffer.writeln('      options: options,');
    buffer.writeln('      sequelize: $generatedClassName().sequelizeInstance,');
    buffer.writeln('      model: $generatedClassName().sequelizeModel,');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // Generate restore() instance method
    buffer.writeln(
      '  /// Restores this soft-deleted instance (for paranoid models)',
    );
    buffer.writeln('  Future<void> restore() async {');
    buffer.writeln('    final pkValues = getPrimaryKeyMap();');
    buffer.writeln('    if (pkValues == null || pkValues.isEmpty) {');
    buffer.writeln(
      '      throw StateError(\'Cannot restore: instance has no primary key values\');',
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    await QueryEngine().instanceRestore(');
    buffer.writeln('      modelName: $generatedClassName().modelName,');
    buffer.writeln('      primaryKeyValues: pkValues,');
    buffer.writeln('      sequelize: $generatedClassName().sequelizeInstance,');
    buffer.writeln('      model: $generatedClassName().sequelizeModel,');
    buffer.writeln('    );');
    buffer.writeln();
    buffer.writeln(
      '    // Reload to get updated values (deletedAt should be null)',
    );
    buffer.writeln('    await reload();');
    buffer.writeln('  }');
    buffer.writeln();
  }
}
