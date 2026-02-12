part of '../../sequelize_model_generator.dart';

void _generateClassValues(
  StringBuffer buffer,
  String valuesClassName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations, {
  required String className,
  required String generatedClassName,
  required GeneratorNamingConfig namingConfig,
}) {
  final primaryKeys = fields.where((f) => f.primaryKey).toList();
  final includeHelperClassName = namingConfig.getModelIncludeHelperClassName(
    className,
  );

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
    final modelValuesClassName = namingConfig.getModelValuesClassName(
      assoc.modelClassName,
    );
    if (assoc.associationType == 'hasOne' ||
        assoc.associationType == 'belongsTo') {
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
    buffer.writeln('  Query? originalQuery;');
  }
  buffer.writeln();

  // Store previous data snapshot for change tracking
  buffer.writeln('  Map<String, dynamic>? _previousDataValues;');
  buffer.writeln();
  buffer.writeln(
    '  /// Get the previous data snapshot (used for change tracking)',
  );
  buffer.writeln('  @protected');
  buffer.writeln(
    '  Map<String, dynamic>? get previousDataValues => _previousDataValues;',
  );
  buffer.writeln();
  buffer.writeln('  /// Set the previous data snapshot');
  buffer.writeln('  @protected');
  buffer.writeln('  void setPreviousDataValues(Map<String, dynamic>? data) {');
  buffer.writeln('    _previousDataValues = data;');
  buffer.writeln('  }');
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
    final modelValuesClassName = namingConfig.getModelValuesClassName(
      assoc.modelClassName,
    );
    final jsonKey = _getAssociationJsonKey(assoc.as, assoc.modelClassName);
    if (assoc.associationType == 'hasOne' ||
        assoc.associationType == 'belongsTo') {
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
    final serializedFieldValue = _toJsonFieldValueExpression(
      field,
      valueExpression: field.fieldName,
      alreadyNonNull: false,
    );
    buffer.writeln("      '${field.name}': $serializedFieldValue,");
  }
  for (var assoc in associations) {
    final jsonKey = _getAssociationJsonKey(assoc.as, assoc.modelClassName);
    if (assoc.associationType == 'hasOne' ||
        assoc.associationType == 'belongsTo') {
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

  // getPrimaryKeyMap() is provided by ReloadableMixin and calls getPrimaryKeyMap()
  // which we implement via where() in the mixin methods

  final columnsClassName = namingConfig.getModelColumnsClassName(className);
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
      namingConfig,
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
    namingConfig,
  );

  // NOTE:
  // BelongsTo instance methods (getX / setX / createX) will be enabled in a future
  // change-set. The generator implementation is kept below, but we intentionally
  // do not emit these methods yet while we focus on association wiring stability.

  buffer.writeln('}');
  buffer.writeln();
}

String _toJsonFieldValueExpression(
  _FieldInfo field, {
  required String valueExpression,
  required bool alreadyNonNull,
}) {
  if (field.dartType == 'DateTime') {
    return '$valueExpression?.toIso8601String()';
  }
  return valueExpression;
}

// ignore: unused_element
void _generateBelongsToInstanceMethods(
  StringBuffer buffer, {
  required String className,
  required String generatedClassName,
  required List<_AssociationInfo> associations,
  required GeneratorNamingConfig namingConfig,
  required bool hasPrimaryKey,
}) {
  final belongsToAssocs =
      associations.where((a) => a.associationType == 'belongsTo').toList();
  if (belongsToAssocs.isEmpty) return;

  // These methods require a primary key to locate the instance in JS.
  if (!hasPrimaryKey) return;

  buffer.writeln();

  for (final assoc in belongsToAssocs) {
    // Method names should be based on the field name (stable in Dart code),
    // while the underlying Sequelize method uses the association alias.
    final assocName = assoc.fieldName;
    final sequelizeAssociationName = assoc.as ?? assoc.fieldName;
    final targetModelClass = assoc.modelClassName;
    final targetValuesClassName = namingConfig.getModelValuesClassName(
      targetModelClass,
    );

    final cap = assocName.isEmpty
        ? assocName
        : '${assocName[0].toUpperCase()}${assocName.substring(1)}';

    // getX
    buffer.writeln('  /// BelongsTo getter for `$assocName`');
    buffer.writeln(
      '  Future<$targetValuesClassName?> get$cap({Map<String, dynamic>? options}) async {',
    );
    buffer.writeln('    final pk = getPrimaryKeyMap();');
    buffer.writeln('    if (pk == null || pk.isEmpty) {');
    buffer.writeln(
      "      throw StateError('Cannot call get$cap(): instance has no primary key values');",
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln(
      '    final result = await QueryEngine().belongsToGet(',
    );
    buffer.writeln('      sourceModel: $generatedClassName().modelName,');
    buffer.writeln('      primaryKeyValues: pk,');
    buffer.writeln("      associationName: '$sequelizeAssociationName',");
    buffer.writeln('      options: options,');
    buffer.writeln('      sequelize: $generatedClassName().sequelizeInstance,');
    buffer.writeln('      model: $generatedClassName().sequelizeModel,');
    buffer.writeln('    );');
    buffer.writeln('    if (result == null) return null;');
    buffer.writeln(
      '    return $targetValuesClassName.fromJson(result.data);',
    );
    buffer.writeln('  }');
    buffer.writeln();

    // setX
    buffer.writeln('  /// BelongsTo setter for `$assocName`');
    buffer.writeln(
      '  Future<void> set$cap(dynamic targetOrKey, {bool? save, Map<String, dynamic>? options}) async {',
    );
    buffer.writeln('    final pk = getPrimaryKeyMap();');
    buffer.writeln('    if (pk == null || pk.isEmpty) {');
    buffer.writeln(
      "      throw StateError('Cannot call set$cap(): instance has no primary key values');",
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    dynamic key = targetOrKey;');
    buffer.writeln(
      '    if (targetOrKey is $targetValuesClassName) {',
    );
    // Best-effort: default to id or targetKey if configured.
    final targetKeyExpr =
        assoc.targetKey != null ? "'${assoc.targetKey}'" : "'id'";
    buffer.writeln('      final json = targetOrKey.toJson();');
    buffer.writeln('      key = json[$targetKeyExpr] ?? json[\'id\'];');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    await QueryEngine().belongsToSet(');
    buffer.writeln('      sourceModel: $generatedClassName().modelName,');
    buffer.writeln('      primaryKeyValues: pk,');
    buffer.writeln("      associationName: '$sequelizeAssociationName',");
    buffer.writeln('      targetOrKey: key,');
    buffer.writeln('      save: save,');
    buffer.writeln('      options: options,');
    buffer.writeln('      sequelize: $generatedClassName().sequelizeInstance,');
    buffer.writeln('      model: $generatedClassName().sequelizeModel,');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // createX
    final targetCreateClassName = namingConfig.getModelCreateClassName(
      targetModelClass,
    );
    buffer.writeln('  /// BelongsTo creator for `$assocName`');
    buffer.writeln(
      '  Future<$targetValuesClassName> create$cap($targetCreateClassName data, {Map<String, dynamic>? options}) async {',
    );
    buffer.writeln('    final pk = getPrimaryKeyMap();');
    buffer.writeln('    if (pk == null || pk.isEmpty) {');
    buffer.writeln(
      "      throw StateError('Cannot call create$cap(): instance has no primary key values');",
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    final result = await QueryEngine().belongsToCreate(');
    buffer.writeln('      sourceModel: $generatedClassName().modelName,');
    buffer.writeln('      primaryKeyValues: pk,');
    buffer.writeln("      associationName: '$sequelizeAssociationName',");
    buffer.writeln('      data: data.toJson(),');
    buffer.writeln('      options: options,');
    buffer.writeln('      sequelize: $generatedClassName().sequelizeInstance,');
    buffer.writeln('      model: $generatedClassName().sequelizeModel,');
    buffer.writeln('    );');
    buffer.writeln('    return $targetValuesClassName.fromJson(result.data);');
    buffer.writeln('  }');
  }
}

/// Generates the mixin implementation methods for ReloadableMixin
void _generateMixinMethods(
  StringBuffer buffer,
  String valuesClassName,
  String className,
  String generatedClassName,
  List<_FieldInfo> primaryKeys,
  String includeHelperClassName,
  GeneratorNamingConfig namingConfig,
) {
  // Generate getPrimaryKeyMap (alias for where())
  buffer.writeln('  @override');
  buffer.writeln('  @protected');
  buffer.writeln('  Map<String, dynamic>? getPrimaryKeyMap() => where();');
  buffer.writeln();

  // Generate copyFieldsFrom (delegates to _updateFields)
  buffer.writeln('  @override');
  buffer.writeln('  @protected');
  buffer.writeln('  void copyFieldsFrom($valuesClassName source) =>');
  buffer.writeln('      _updateFields(source);');
  buffer.writeln();

  // Override reload() to also set previousDataValues after reloading
  buffer.writeln('  @override');
  buffer.writeln('  Future<$valuesClassName?> reload() async {');
  buffer.writeln('    final pk = getPrimaryKeyMap();');
  buffer.writeln('    if (pk == null || pk.isEmpty) {');
  buffer.writeln(
    '      throw StateError(\'Cannot reload: instance has no primary key values\');',
  );
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln(
    '    final result = await findByPrimaryKey(pk, originalQuery: originalQuery);',
  );
  buffer.writeln('    if (result == null) {');
  buffer.writeln('      return null;');
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln('    copyFieldsFrom(result);');
  buffer.writeln('    // Preserve original query for future reloads');
  buffer.writeln('    originalQuery = result.originalQuery ?? originalQuery;');
  buffer.writeln(
    '    // Update previousDataValues after reload to track current state',
  );
  buffer.writeln('    setPreviousDataValues(toJson());');
  buffer.writeln();
  buffer.writeln('    return this as $valuesClassName;');
  buffer.writeln('  }');
  buffer.writeln();

  final columnsClassName = namingConfig.getModelColumnsClassName(className);

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
  // TODO: Enable isNewRecord, changed & previous
  buffer.writeln('  }');
  buffer.writeln();
}
