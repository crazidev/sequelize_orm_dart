part of '../../sequelize_model_generator.dart';

void _generateClassValues(
  StringBuffer buffer,
  String valuesClassName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations, {
  required String className,
  required String generatedClassName,
}) {
  buffer.writeln('class $valuesClassName {');
  for (var field in fields) {
    buffer.writeln('  ${field.dartType}? ${field.fieldName};');
  }
  // Add association fields
  for (var assoc in associations) {
    final modelValuesClassName = _getModelValuesClassName(
      assoc.modelClassName,
    );
    if (assoc.associationType == 'hasOne') {
      buffer.writeln('  $modelValuesClassName? ${assoc.fieldName};');
    } else {
      buffer.writeln(
        '  List<$modelValuesClassName>? ${assoc.fieldName};',
      );
    }
  }
  // Store original query for reload() method
  buffer.writeln('  Query? _originalQuery;');
  buffer.writeln();
  buffer.writeln('  $valuesClassName({');
  for (var field in fields) {
    // Nullable fields should be optional, not required
    // This allows fromJson() to pass null when keys are missing
    buffer.writeln('    this.${field.fieldName},');
  }
  for (var assoc in associations) {
    buffer.writeln('    this.${assoc.fieldName},');
  }
  buffer.writeln('  });');
  buffer.writeln();
  buffer.writeln(
    '  factory $valuesClassName.fromJson(Map<String, dynamic> json) {',
  );
  buffer.writeln('    return $valuesClassName(');
  for (var field in fields) {
    final jsonValue = _generateJsonValueParser(field);
    buffer.writeln('      ${field.fieldName}: $jsonValue,');
  }
  // Add association parsing
  for (var assoc in associations) {
    final modelValuesClassName = _getModelValuesClassName(
      assoc.modelClassName,
    );
    final jsonKey = _getAssociationJsonKey(assoc.as, assoc.modelClassName);
    if (assoc.associationType == 'hasOne') {
      buffer.writeln(
        "      ${assoc.fieldName}: json['$jsonKey'] != null ? $modelValuesClassName.fromJson(json['$jsonKey'] as Map<String, dynamic>) : null,",
      );
    } else {
      buffer.writeln(
        "      ${assoc.fieldName}: (json['$jsonKey'] as List?)?.map((e) => $modelValuesClassName.fromJson(e as Map<String, dynamic>)).toList(),",
      );
    }
  }
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  Map<String, dynamic> toJson() {');
  buffer.writeln('    return {');
  for (var field in fields) {
    buffer.writeln("      '${field.name}': ${field.fieldName},");
  }
  for (var assoc in associations) {
    final jsonKey = _getAssociationJsonKey(assoc.as, assoc.modelClassName);
    if (assoc.associationType == 'hasOne') {
      buffer.writeln(
        "      '$jsonKey': ${assoc.fieldName}?.toJson(),",
      );
    } else {
      buffer.writeln(
        "      '$jsonKey': ${assoc.fieldName}?.map((e) => e.toJson()).toList(),",
      );
    }
  }
  buffer.writeln('    };');
  buffer.writeln('  }');
  buffer.writeln();

  // Generate where() method
  _generateWhereMethod(buffer, className, generatedClassName);

  // Get primary keys for helper method
  final primaryKeys = fields.where((f) => f.primaryKey).toList();
  final columnsClassName = '\$${className}Columns';
  final whereCallbackName = _toCamelCase(className);

  // Generate merge where helper method
  _generateMergeWhereHelper(
    buffer,
    columnsClassName,
    whereCallbackName,
    generatedClassName,
    primaryKeys,
  );

  // Generate _updateFields helper method
  _generateUpdateFieldsHelper(buffer, valuesClassName, fields, associations);

  // Generate instance methods
  _generateInstanceMethods(
    buffer,
    valuesClassName,
    className,
    generatedClassName,
    fields,
    associations,
  );

  buffer.writeln('}');
  buffer.writeln();
}

/// Generates the _updateFields helper method that updates all instance fields
/// from another instance. Used by reload(), increment(), decrement().
void _generateUpdateFieldsHelper(
  StringBuffer buffer,
  String valuesClassName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations,
) {
  buffer.writeln(
    '  /// Updates all instance fields from another instance (Sequelize.js behavior)',
  );
  buffer.writeln('  void _updateFields($valuesClassName source) {');
  for (final field in fields) {
    final fieldName = field.fieldName;
    buffer.writeln('    $fieldName = source.$fieldName;');
  }
  for (final assoc in associations) {
    final assocFieldName = assoc.fieldName;
    buffer.writeln('    $assocFieldName = source.$assocFieldName;');
  }
  buffer.writeln('  }');
  buffer.writeln();
}
