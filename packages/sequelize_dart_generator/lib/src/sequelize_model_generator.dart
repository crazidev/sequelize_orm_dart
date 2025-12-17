import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';
import 'package:source_gen/source_gen.dart';

class SequelizeModelGenerator extends GeneratorForAnnotation<Table> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.displayName}`.',
      );
    }

    final className = element.name;
    final tableAnnotation = _extractTableAnnotation(annotation);

    final fields = _getFields(element);
    final associations = _getAssociations(element);
    final generatedClassName = '\$$className';
    final valuesClassName = '\$${className}Values';
    final createClassName = '\$${className}Create';

    final buffer = StringBuffer();

    _generateClassDefinition(
      buffer,
      generatedClassName,
      className,
    );
    _generateDefineMethod(buffer, generatedClassName, associations);
    _generateGetAttributesMethod(buffer, fields);
    _generateGetAttributesJsonMethod(buffer);
    _generateGetOptionsJsonMethod(buffer, tableAnnotation);
    _generateFindAllMethod(
      buffer,
      className ?? 'Unknown',
      valuesClassName,
    );
    _generateFindOneMethod(
      buffer,
      className ?? 'Unknown',
      valuesClassName,
    );
    _generateAssociateModelMethod(
      buffer,
      generatedClassName,
      associations,
    );

    buffer.writeln('}');
    buffer.writeln();

    _generateClassValues(
      buffer,
      valuesClassName,
      fields,
      associations,
    );
    _generateClassCreate(buffer, createClassName, fields);
    _generateQueryBuilder(buffer, className ?? 'Unknown', fields);

    return buffer.toString();
  }

  void _generateClassDefinition(
    StringBuffer buffer,
    String generatedClassName,
    String? className,
  ) {
    buffer.writeln('class $generatedClassName extends Model {');
    buffer.writeln(
      '  static final $generatedClassName _instance = $generatedClassName._internal();',
    );
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln("  String get name => '$className';");
    buffer.writeln();
    buffer.writeln('  $generatedClassName._internal();');
    buffer.writeln();
    buffer.writeln('  factory $generatedClassName() {');
    buffer.writeln('    return _instance;');
    buffer.writeln('  }');
    buffer.writeln();
  }

  void _generateDefineMethod(
    StringBuffer buffer,
    String generatedClassName,
    List<_AssociationInfo> associations,
  ) {
    buffer.writeln('  @override');
    buffer.writeln(
      '  $generatedClassName define(String modelName, Object sequelize) {',
    );
    buffer.writeln('    super.define(modelName, sequelize);');
    // Note: associateModel() is now called by Sequelize.initialize()
    // after all models are defined, so we don't call it here
    buffer.writeln('    return this;');
    buffer.writeln('  }');
    buffer.writeln();
  }

  void _generateGetAttributesMethod(
    StringBuffer buffer,
    List<_FieldInfo> fields,
  ) {
    buffer.writeln('  @override');
    buffer.writeln('  List<ModelAttributes> getAttributes() {');
    buffer.writeln('    return [');
    for (var field in fields) {
      final hasExtraProperties =
          field.autoIncrement ||
          field.primaryKey ||
          field.allowNull != null ||
          field.defaultValue != null;

      if (hasExtraProperties) {
        buffer.write('''      ModelAttributes(
        name: '${field.name}',
        type: DataType.${field.dataType},
''');
        if (field.autoIncrement) buffer.writeln('        autoIncrement: true,');
        if (field.primaryKey) buffer.writeln('        primaryKey: true,');
        if (field.allowNull != null) {
          buffer.writeln('        allowNull: ${field.allowNull},');
        }
        if (field.defaultValue != null) {
          buffer.writeln('        defaultValue: ${field.defaultValue},');
        }
        buffer.writeln('      ),');
      } else {
        buffer.writeln(
          "      ModelAttributes(name: '${field.name}', type: DataType.${field.dataType}),",
        );
      }
    }
    buffer.writeln('    ];');
    buffer.writeln('  }');
    buffer.writeln();
  }

  void _generateGetAttributesJsonMethod(StringBuffer buffer) {
    buffer.writeln('  @override');
    buffer.writeln('  Map<String, Map<String, dynamic>> getAttributesJson() {');
    buffer.writeln('    final map = {');
    buffer.writeln('      for (var item in getAttributes())');
    buffer.writeln('        item.name: {');
    buffer.writeln("          'type': item.type.name,");
    buffer.writeln('          \'allowNull\': item.allowNull,');
    buffer.writeln('          \'primaryKey\': item.primaryKey,');
    buffer.writeln('          \'autoIncrement\': item.autoIncrement,');
    buffer.writeln('          \'defaultValue\': item.defaultValue,');
    buffer.writeln('        },');
    buffer.writeln('    };');
    buffer.writeln();
    buffer.writeln('    return map;');
    buffer.writeln('  }');
    buffer.writeln();
  }

  Map<String, dynamic> _extractTableAnnotation(ConstantReader annotation) {
    final result = <String, dynamic>{};

    // Required field
    result['tableName'] =
        annotation.peek('tableName')?.stringValue ?? 'unknown_table';

    // Optional fields
    if (annotation.peek('omitNull')?.isNull == false) {
      result['omitNull'] = annotation.peek('omitNull')?.boolValue;
    }
    if (annotation.peek('noPrimaryKey')?.isNull == false) {
      result['noPrimaryKey'] = annotation.peek('noPrimaryKey')?.boolValue;
    }
    if (annotation.peek('timestamps')?.isNull == false) {
      result['timestamps'] = annotation.peek('timestamps')?.boolValue;
    }
    if (annotation.peek('paranoid')?.isNull == false) {
      result['paranoid'] = annotation.peek('paranoid')?.boolValue;
    }
    if (annotation.peek('underscored')?.isNull == false) {
      result['underscored'] = annotation.peek('underscored')?.boolValue;
    }
    if (annotation.peek('hasTrigger')?.isNull == false) {
      result['hasTrigger'] = annotation.peek('hasTrigger')?.boolValue;
    }
    if (annotation.peek('freezeTableName')?.isNull == false) {
      result['freezeTableName'] = annotation.peek('freezeTableName')?.boolValue;
    }
    if (annotation.peek('modelName')?.isNull == false) {
      result['modelName'] = annotation.peek('modelName')?.stringValue;
    }
    if (annotation.peek('schema')?.isNull == false) {
      result['schema'] = annotation.peek('schema')?.stringValue;
    }
    if (annotation.peek('schemaDelimiter')?.isNull == false) {
      result['schemaDelimiter'] = annotation
          .peek('schemaDelimiter')
          ?.stringValue;
    }
    if (annotation.peek('engine')?.isNull == false) {
      result['engine'] = annotation.peek('engine')?.stringValue;
    }
    if (annotation.peek('charset')?.isNull == false) {
      result['charset'] = annotation.peek('charset')?.stringValue;
    }
    if (annotation.peek('comment')?.isNull == false) {
      result['comment'] = annotation.peek('comment')?.stringValue;
    }
    if (annotation.peek('collate')?.isNull == false) {
      result['collate'] = annotation.peek('collate')?.stringValue;
    }
    if (annotation.peek('initialAutoIncrement')?.isNull == false) {
      result['initialAutoIncrement'] = annotation
          .peek('initialAutoIncrement')
          ?.stringValue;
    }

    // Complex types - extract their values
    final nameAnnotation = annotation.peek('name');
    if (nameAnnotation != null && nameAnnotation.isNull == false) {
      final singular = nameAnnotation.peek('singular')?.stringValue;
      final plural = nameAnnotation.peek('plural')?.stringValue;
      if (singular != null && plural != null) {
        result['name'] = {'singular': singular, 'plural': plural};
      }
    }

    final createdAtAnnotation = annotation.peek('createdAt');
    if (createdAtAnnotation != null && createdAtAnnotation.isNull == false) {
      final enable = createdAtAnnotation.peek('enable')?.boolValue;
      final columnName = createdAtAnnotation.peek('columnName')?.stringValue;
      if (enable != null || columnName != null) {
        result['createdAt'] = {'enable': enable, 'columnName': columnName};
      }
    }

    final deletedAtAnnotation = annotation.peek('deletedAt');
    if (deletedAtAnnotation != null && deletedAtAnnotation.isNull == false) {
      final enable = deletedAtAnnotation.peek('enable')?.boolValue;
      final columnName = deletedAtAnnotation.peek('columnName')?.stringValue;
      if (enable != null || columnName != null) {
        result['deletedAt'] = {'enable': enable, 'columnName': columnName};
      }
    }

    final updatedAtAnnotation = annotation.peek('updatedAt');
    if (updatedAtAnnotation != null && updatedAtAnnotation.isNull == false) {
      final enable = updatedAtAnnotation.peek('enable')?.boolValue;
      final columnName = updatedAtAnnotation.peek('columnName')?.stringValue;
      if (enable != null || columnName != null) {
        result['updatedAt'] = {'enable': enable, 'columnName': columnName};
      }
    }

    final versionAnnotation = annotation.peek('version');
    if (versionAnnotation != null && versionAnnotation.isNull == false) {
      final version = versionAnnotation.peek('version')?.stringValue;
      if (version != null) {
        result['version'] = {'version': version};
      }
    }

    return result;
  }

  void _generateGetOptionsJsonMethod(
    StringBuffer buffer,
    Map<String, dynamic> tableAnnotation,
  ) {
    buffer.writeln('  @override');
    buffer.writeln('  Map<String, dynamic> getOptionsJson() {');
    buffer.writeln('    final table = Table(');

    // Write tableName (required)
    buffer.writeln("      tableName: '${tableAnnotation['tableName']}',");

    // Write all optional parameters
    final optionalParams = <String, dynamic>{...tableAnnotation};
    optionalParams.remove('tableName');

    for (final entry in optionalParams.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) continue;

      if (key == 'name' && value is Map) {
        buffer.writeln(
          "      name: ModelNameOption(singular: '${value['singular']}', plural: '${value['plural']}'),",
        );
      } else if (key == 'createdAt' && value is Map) {
        final enable = value['enable'];
        final columnName = value['columnName'];
        if (enable == false) {
          buffer.writeln('      createdAt: TimestampOption.disabled(),');
        } else if (columnName != null) {
          buffer.writeln(
            "      createdAt: TimestampOption.custom('$columnName'),",
          );
        } else if (enable == true) {
          buffer.writeln('      createdAt: TimestampOption.enabled(),');
        }
      } else if (key == 'deletedAt' && value is Map) {
        final enable = value['enable'];
        final columnName = value['columnName'];
        if (enable == false) {
          buffer.writeln('      deletedAt: TimestampOption.disabled(),');
        } else if (columnName != null) {
          buffer.writeln(
            "      deletedAt: TimestampOption.custom('$columnName'),",
          );
        } else if (enable == true) {
          buffer.writeln('      deletedAt: TimestampOption.enabled(),');
        }
      } else if (key == 'updatedAt' && value is Map) {
        final enable = value['enable'];
        final columnName = value['columnName'];
        if (enable == false) {
          buffer.writeln('      updatedAt: TimestampOption.disabled(),');
        } else if (columnName != null) {
          buffer.writeln(
            "      updatedAt: TimestampOption.custom('$columnName'),",
          );
        } else if (enable == true) {
          buffer.writeln('      updatedAt: TimestampOption.enabled(),');
        }
      } else if (key == 'version' && value is Map) {
        final version = value['version'];
        if (version != null) {
          buffer.writeln("      version: VersionOption.custom('$version'),");
        } else {
          buffer.writeln('      version: VersionOption.disabled(),');
        }
      } else if (value is bool) {
        buffer.writeln('      $key: $value,');
      } else if (value is String) {
        buffer.writeln("      $key: '$value',");
      }
    }

    buffer.writeln('    );');
    buffer.writeln('    return table.toJson();');
    buffer.writeln('  }');
    buffer.writeln();
  }

  void _generateFindAllMethod(
    StringBuffer buffer,
    String className,
    String valuesClassName,
  ) {
    final queryBuilderClassName = '\$${className}Query';

    buffer.writeln('  @override');
    buffer.writeln(
      '  Future<List<$valuesClassName>> findAll(Query Function($queryBuilderClassName ${className.toLowerCase()}) builder) {',
    );
    buffer.writeln('    final query = builder($queryBuilderClassName());');
    buffer.writeln('    return QueryEngine().findAll(');
    buffer.writeln('      modelName: name,');
    buffer.writeln('      query: query,');
    buffer.writeln('      sequelize: sequelizeInstance,');
    buffer.writeln('      model: sequelizeModel,');
    buffer.writeln('    ).then((data) =>');
    buffer.writeln(
      '      data.map((value) => $valuesClassName.fromJson(value)).toList()',
    );
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
  }

  void _generateFindOneMethod(
    StringBuffer buffer,
    String className,
    String valuesClassName,
  ) {
    final queryBuilderClassName = '\$${className}Query';

    buffer.writeln('  @override');
    buffer.writeln(
      '  Future<$valuesClassName?> findOne(Query Function($queryBuilderClassName ${className.toLowerCase()}) builder) {',
    );
    buffer.writeln('    final query = builder($queryBuilderClassName());');
    buffer.writeln('    return QueryEngine().findOne(');
    buffer.writeln('      modelName: name,');
    buffer.writeln('      query: query,');
    buffer.writeln('      sequelize: sequelizeInstance,');
    buffer.writeln('      model: sequelizeModel,');
    buffer.writeln('    ).then((data) =>');
    buffer.writeln(
      '      data != null ? $valuesClassName.fromJson(data) : null',
    );
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
  }

  void _generateClassValues(
    StringBuffer buffer,
    String valuesClassName,
    List<_FieldInfo> fields,
    List<_AssociationInfo> associations,
  ) {
    buffer.writeln('class $valuesClassName {');
    for (var field in fields) {
      buffer.writeln('  final ${field.dartType}? ${field.fieldName};');
    }
    // Add association fields
    for (var assoc in associations) {
      final modelValuesClassName = _getModelValuesClassName(
        assoc.modelClassName,
      );
      if (assoc.associationType == 'hasOne') {
        buffer.writeln('  final $modelValuesClassName? ${assoc.fieldName};');
      } else {
        buffer.writeln(
          '  final List<$modelValuesClassName>? ${assoc.fieldName};',
        );
      }
    }
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
    buffer.writeln('}');
    buffer.writeln();
  }

  void _generateClassCreate(
    StringBuffer buffer,
    String createClassName,
    List<_FieldInfo> fields,
  ) {
    buffer.writeln('class $createClassName {');
    for (var field in fields) {
      if (!field.autoIncrement && !field.primaryKey) {
        buffer.writeln('  final ${field.dartType} ${field.fieldName};');
      }
    }
    buffer.writeln();
    buffer.writeln('  $createClassName({');
    for (var field in fields) {
      if (!field.autoIncrement && !field.primaryKey) {
        buffer.writeln('    required this.${field.fieldName},');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');
    for (var field in fields) {
      if (!field.autoIncrement && !field.primaryKey) {
        buffer.writeln("      '${field.name}': ${field.fieldName},");
      }
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();
  }

  void _generateQueryBuilder(
    StringBuffer buffer,
    String className,
    List<_FieldInfo> fields,
  ) {
    final queryBuilderClassName = '\$${className}Query';

    buffer.writeln('/// Type-safe query builder for $className');
    buffer.writeln('class $queryBuilderClassName {');
    buffer.writeln('  $queryBuilderClassName();'); // Constructor
    buffer.writeln();

    for (var field in fields) {
      final dartType = _getDartTypeForQuery(field.dataType);
      buffer.writeln(
        "  final ${field.fieldName} = Column<$dartType>('${field.name}', DataType.${field.dataType});",
      );
    }

    buffer.writeln('}');
    buffer.writeln();
  }

  String _getDartTypeForQuery(String dataType) {
    switch (dataType) {
      case 'INTEGER':
      case 'BIGINT':
      case 'TINYINT':
      case 'SMALLINT':
      case 'MEDIUMINT':
        return 'int';
      case 'FLOAT':
      case 'DOUBLE':
      case 'DECIMAL':
        return 'double';
      case 'BOOLEAN':
        return 'bool';
      case 'DATE':
      case 'DATEONLY':
        return 'DateTime';
      case 'JSON':
      case 'JSONB':
        return 'Map<String, dynamic>';
      default:
        return 'String';
    }
  }

  void _generateAssociateModelMethod(
    StringBuffer buffer,
    String generatedClassName,
    List<_AssociationInfo> associations,
  ) {
    // Always generate the method with @override annotation
    buffer.writeln('  @override');
    buffer.writeln('  Future<void> associateModel() async {');

    if (associations.isEmpty) {
      buffer.writeln('    // No associations defined');
    } else {
      for (var assoc in associations) {
        final modelInstanceName = '${assoc.modelClassName}.instance';
        if (assoc.associationType == 'hasOne') {
          buffer.write('    await hasOne(');
        } else {
          buffer.write('    await hasMany(');
        }
        buffer.write(modelInstanceName);
        if (assoc.foreignKey != null ||
            assoc.as != null ||
            assoc.sourceKey != null) {
          buffer.write(',');
          buffer.writeln();
          if (assoc.foreignKey != null) {
            buffer.writeln("      foreignKey: '${assoc.foreignKey}',");
          }
          if (assoc.as != null) {
            buffer.writeln("      as: '${assoc.as}',");
          }
          if (assoc.sourceKey != null) {
            buffer.writeln("      sourceKey: '${assoc.sourceKey}',");
          }
          buffer.write('    ');
        }
        buffer.writeln(');');
      }
    }

    buffer.writeln('  }');
    buffer.writeln();
  }

  List<_AssociationInfo> _getAssociations(ClassElement element) {
    final associations = <_AssociationInfo>[];
    const hasOneChecker = TypeChecker.fromUrl(
      'package:sequelize_dart_annotations/src/has_one.dart#HasOne',
    );
    const hasManyChecker = TypeChecker.fromUrl(
      'package:sequelize_dart_annotations/src/has_many.dart#HasMany',
    );

    for (var field in element.fields) {
      if (hasOneChecker.hasAnnotationOfExact(field)) {
        final annotation = hasOneChecker.firstAnnotationOfExact(field);
        if (annotation != null) {
          final reader = ConstantReader(annotation);
          // Read the model type from the positional parameter
          final modelType = reader.read('model').typeValue;
          final modelClassName = _getModelClassName(modelType);
          final fieldName = field.name ?? 'unknown_field';
          final foreignKey = reader.peek('foreignKey')?.stringValue;
          final as = reader.peek('as')?.stringValue;
          final sourceKey = reader.peek('sourceKey')?.stringValue;

          associations.add(
            _AssociationInfo(
              associationType: 'hasOne',
              modelClassName: modelClassName,
              fieldName: fieldName,
              foreignKey: foreignKey,
              as: as,
              sourceKey: sourceKey,
            ),
          );
        }
      } else if (hasManyChecker.hasAnnotationOfExact(field)) {
        final annotation = hasManyChecker.firstAnnotationOfExact(field);
        if (annotation != null) {
          final reader = ConstantReader(annotation);
          // Read the model type from the positional parameter
          final modelType = reader.read('model').typeValue;
          final modelClassName = _getModelClassName(modelType);
          final fieldName = field.name ?? 'unknown_field';
          final foreignKey = reader.peek('foreignKey')?.stringValue;
          final as = reader.peek('as')?.stringValue;
          final sourceKey = reader.peek('sourceKey')?.stringValue;

          associations.add(
            _AssociationInfo(
              associationType: 'hasMany',
              modelClassName: modelClassName,
              fieldName: fieldName,
              foreignKey: foreignKey,
              as: as,
              sourceKey: sourceKey,
            ),
          );
        }
      }
    }
    return associations;
  }

  String _getModelClassName(DartType type) {
    final element = type.element;
    if (element is ClassElement) {
      return element.name ?? 'Unknown';
    }
    return type.toString().replaceAll('*', '').trim();
  }

  String _getModelValuesClassName(String className) {
    return '\$${className}Values';
  }

  String _getAssociationJsonKey(String? as, String modelClassName) {
    if (as != null && as.isNotEmpty) {
      return as;
    }
    return _toCamelCase(modelClassName);
  }

  String _toCamelCase(String str) {
    if (str.isEmpty) return str;
    return str[0].toLowerCase() + str.substring(1);
  }

  String _generateJsonValueParser(_FieldInfo field) {
    final jsonKey = "json['${field.name}']";

    // Handle DateTime fields - parse string to DateTime
    if (field.dartType == 'DateTime') {
      return '$jsonKey != null ? ($jsonKey is DateTime ? $jsonKey : DateTime.parse($jsonKey as String)) : null';
    }

    // For all other types, just return the JSON value directly
    return jsonKey;
  }

  List<_FieldInfo> _getFields(ClassElement element) {
    final fields = <_FieldInfo>[];
    const modelAttributesChecker = TypeChecker.fromUrl(
      'package:sequelize_dart_annotations/src/model_attribute.dart#ModelAttributes',
    );

    for (var field in element.fields) {
      if (modelAttributesChecker.hasAnnotationOfExact(field)) {
        final annotation = modelAttributesChecker.firstAnnotationOfExact(field);
        if (annotation != null) {
          final reader = ConstantReader(annotation);
          final fieldName = field.name ?? 'unknown_field';
          final name = reader.peek('name')?.stringValue ?? fieldName;
          final typeObj = reader.peek('type')?.objectValue;

          String dataType = 'STRING';
          if (typeObj != null) {
            final typeField = typeObj.variable;
            if (typeField != null) {
              dataType = typeField.name ?? 'STRING';
            }
          }

          final autoIncrement =
              reader.peek('autoIncrement')?.boolValue ?? false;
          final primaryKey = reader.peek('primaryKey')?.boolValue ?? false;
          final allowNull = reader.peek('allowNull')?.boolValue;
          final defaultValue = reader.peek('defaultValue')?.literalValue;

          String dartType = 'String';
          switch (dataType) {
            case 'INTEGER':
            case 'BIGINT':
            case 'TINYINT':
            case 'SMALLINT':
            case 'MEDIUMINT':
              dartType = 'int';
              break;
            case 'FLOAT':
            case 'DOUBLE':
            case 'DECIMAL':
              dartType = 'double';
              break;
            case 'BOOLEAN':
              dartType = 'bool';
              break;
            case 'DATE':
            case 'DATEONLY':
              dartType = 'DateTime';
              break;
            case 'JSON':
            case 'JSONB':
              dartType = 'Map<String, dynamic>';
              break;
            default:
              dartType = 'String';
          }

          fields.add(
            _FieldInfo(
              fieldName: fieldName,
              name: name,
              dataType: dataType,
              dartType: dartType,
              autoIncrement: autoIncrement,
              primaryKey: primaryKey,
              allowNull: allowNull,
              defaultValue: defaultValue,
            ),
          );
        }
      }
    }
    return fields;
  }
}

class _FieldInfo {
  final String fieldName;
  final String name;
  final String dataType;
  final String dartType;
  final bool autoIncrement;
  final bool primaryKey;
  final bool? allowNull;
  final Object? defaultValue;

  _FieldInfo({
    required this.fieldName,
    required this.name,
    required this.dataType,
    required this.dartType,
    this.autoIncrement = false,
    this.primaryKey = false,
    this.allowNull,
    this.defaultValue,
  });
}

class _AssociationInfo {
  final String associationType; // 'hasOne' or 'hasMany'
  final String modelClassName;
  final String fieldName;
  final String? foreignKey;
  final String? as;
  final String? sourceKey;

  _AssociationInfo({
    required this.associationType,
    required this.modelClassName,
    required this.fieldName,
    this.foreignKey,
    this.as,
    this.sourceKey,
  });
}
