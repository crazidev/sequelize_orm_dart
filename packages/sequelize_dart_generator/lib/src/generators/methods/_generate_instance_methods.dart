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
