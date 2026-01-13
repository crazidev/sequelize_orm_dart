part of '../../sequelize_model_generator.dart';

void _generateClassValues(
  StringBuffer buffer,
  String valuesClassName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations, {
  required String className,
  required String generatedClassName,
}) {
  final primaryKeys = fields.where((f) => f.primaryKey).toList();
  final includeHelperClassName = '\$${className}IncludeHelper';

  // Use ReloadableMixin if there are primary keys
  if (primaryKeys.isNotEmpty) {
    buffer.writeln(
      'class $valuesClassName with ReloadableMixin<$valuesClassName> {',
    );
  } else {
    buffer.writeln('class $valuesClassName {');
  }

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

  // Store original query for reload() method (override from mixin)
  if (primaryKeys.isNotEmpty) {
    buffer.writeln('  @override');
    buffer.writeln('  Query? originalQuery;');
  } else {
    buffer.writeln('  Query? _originalQuery;');
  }
  buffer.writeln();

  // Add Sequelize instance metadata fields
  buffer.writeln('  /// Previous values before any changes');
  buffer.writeln('  Map<String, dynamic> previous = {};');
  buffer.writeln();
  buffer.writeln('  /// List of changed field names');
  buffer.writeln('  List<String> changedFields = [];');
  buffer.writeln();
  buffer.writeln(
    '  /// True if this instance has not been persisted to the database',
  );
  buffer.writeln('  bool isNewRecord = false;');
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

  // Add changed() method that matches Sequelize.js behavior
  buffer.writeln(
    '  /// Returns false if no changes, or list of changed field names',
  );
  buffer.writeln(
    '  dynamic changed() => changedFields.isEmpty ? false : changedFields;',
  );
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

  // Generate where() method (also satisfies getPrimaryKeyMap from mixin)
  _generateWhereMethod(buffer, className, generatedClassName);

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

  // Generate _updateFields helper method (also satisfies copyFieldsFrom from mixin)
  _generateUpdateFieldsHelper(buffer, valuesClassName, fields, associations);

  // Generate mixin implementation methods if using ReloadableMixin
  if (primaryKeys.isNotEmpty) {
    _generateMixinMethods(
      buffer,
      valuesClassName,
      className,
      generatedClassName,
      primaryKeys,
      includeHelperClassName,
    );
  }

  // Generate instance methods (increment, decrement)
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

/// Generates the mixin implementation methods for ReloadableMixin
void _generateMixinMethods(
  StringBuffer buffer,
  String valuesClassName,
  String className,
  String generatedClassName,
  List<_FieldInfo> primaryKeys,
  String includeHelperClassName,
) {
  // Generate getPrimaryKeyMap (alias for where())
  buffer.writeln('  @override');
  buffer.writeln('  Map<String, dynamic>? getPrimaryKeyMap() => where();');
  buffer.writeln();

  // Generate copyFieldsFrom (delegates to _updateFields)
  buffer.writeln('  @override');
  buffer.writeln('  void copyFieldsFrom($valuesClassName source) =>');
  buffer.writeln('      _updateFields(source);');
  buffer.writeln();

  final columnsClassName = '\$${className}Columns';

  // Generate findByPrimaryKey
  buffer.writeln('  @override');
  buffer.writeln(
    '  Future<$valuesClassName?> findByPrimaryKey(Map<String, dynamic> pk, {Query? originalQuery}) async {',
  );

  // Build primary key where clause with explicit type
  buffer.writeln(
    '    QueryOperator pkWhere($columnsClassName c) => ',
  );
  if (primaryKeys.length == 1) {
    final key = primaryKeys.first.fieldName;
    buffer.writeln('        c.$key.eq(pk[\'$key\']);');
  } else {
    buffer.writeln('        and([');
    for (final pk in primaryKeys) {
      final key = pk.fieldName;
      buffer.writeln(
        '          if (pk[\'$key\'] != null) c.$key.eq(pk[\'$key\']),',
      );
    }
    buffer.writeln('        ]);');
  }

  buffer.writeln('    final q = originalQuery;');
  buffer.writeln('    return $generatedClassName().findOne(');
  buffer.writeln('      where: pkWhere,');
  buffer.writeln(
    '      include: q?.include != null ? ($includeHelperClassName _) => q!.include! : null,',
  );
  buffer.writeln(
    '      order: q?.order, group: q?.group, limit: q?.limit, offset: q?.offset, attributes: q?.attributes,',
  );
  buffer.writeln('    );');
  buffer.writeln('  }');
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
  // Also copy metadata fields
  buffer.writeln('    previous = source.previous;');
  buffer.writeln('    changedFields = source.changedFields;');
  buffer.writeln('    isNewRecord = source.isNewRecord;');
  buffer.writeln('  }');
  buffer.writeln();
}
