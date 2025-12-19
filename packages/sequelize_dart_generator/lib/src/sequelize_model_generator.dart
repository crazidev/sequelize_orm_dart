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
    _generateQueryBuilder(buffer, className ?? 'Unknown', fields, associations);
    _generateIncludeExtension(
      buffer,
      className ?? 'Unknown',
    );

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
          field.defaultValue != null ||
          field.validateCode != null;

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
        if (field.validateCode != null) {
          buffer.writeln('        validate: ${field.validateCode},');
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
    buffer.writeln(
      '    return AttributeConverter.convertAttributesToJson(getAttributes());',
    );
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
    List<_AssociationInfo> associations,
  ) {
    final queryBuilderClassName = '\$${className}Query';

    buffer.writeln('/// Type-safe query builder for $className');
    buffer.writeln('class $queryBuilderClassName {');
    buffer.writeln('  $queryBuilderClassName();'); // Constructor
    buffer.writeln();
    // Import ModelInterface for type casting
    if (associations.isNotEmpty) {
      // Note: ModelInterface is already imported via sequelize_dart package
    }

    // Generate column references
    for (var field in fields) {
      final dartType = _getDartTypeForQuery(field.dataType);
      buffer.writeln(
        "  final ${field.fieldName} = Column<$dartType>('${field.name}', DataType.${field.dataType});",
      );
    }

    // Generate association references
    if (associations.isNotEmpty) {
      buffer.writeln();
      for (var assoc in associations) {
        final modelClassName = assoc.modelClassName;
        final associationName = assoc.as ?? assoc.fieldName;
        buffer.writeln(
          "  final ${assoc.fieldName} = AssociationReference<$modelClassName>('$associationName', $modelClassName.instance);",
        );
      }
    }

    buffer.writeln();
    buffer.writeln(
      '  IncludeBuilder<$className> includeAll({bool nested = false}) {',
    );
    buffer.writeln(
      '    return IncludeBuilder<$className>(all: true, nested: nested);',
    );
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();
  }

  void _generateIncludeExtension(
    StringBuffer buffer,
    String className,
  ) {
    final queryBuilderClassName = '\$${className}Query';
    final extensionName = '${className}Include';

    buffer.writeln('/// Type-safe include extension for $className');
    buffer.writeln(
      'extension $extensionName on AssociationReference<$className> {',
    );
    buffer.writeln('  /// Type-safe include with nested includes');
    buffer.writeln(
      '  /// The [include] function receives a `$queryBuilderClassName` instance for type-safe nested includes',
    );
    buffer.writeln('  IncludeBuilder<$className> include({');
    buffer.writeln('    bool? separate,');
    buffer.writeln('    bool? required,');
    buffer.writeln('    bool? right,');
    buffer.writeln(
      '    QueryOperator Function($queryBuilderClassName ${_toCamelCase(className)})? where,',
    );
    buffer.writeln('    QueryAttributes? attributes,');
    buffer.writeln('    List<List<String>>? order,');
    buffer.writeln('    int? limit,');
    buffer.writeln('    int? offset,');
    buffer.writeln(
      '    List<IncludeBuilder> Function($queryBuilderClassName ${_toCamelCase(className)})? include,',
    );
    buffer.writeln('    Map<String, dynamic>? through,');
    buffer.writeln('  }) {');
    buffer.writeln(
      '    return IncludeBuilder<$className>(',
    );
    buffer.writeln('      association: name,');
    buffer.writeln('      model: model,');
    buffer.writeln('      separate: separate,');
    buffer.writeln('      required: required,');
    buffer.writeln('      right: right,');
    buffer.writeln(
      '      where: where != null ? (dynamic qb) => where(qb as \$${className}Query) : null,',
    );
    buffer.writeln('      attributes: attributes,');
    buffer.writeln('      order: order,');
    buffer.writeln('      limit: limit,');
    buffer.writeln('      offset: offset,');
    buffer.writeln(
      '      include: include != null ? (dynamic qb) => include(qb as \$${className}Query) : (_) => <IncludeBuilder>[],',
    );
    buffer.writeln('      through: through,');
    buffer.writeln('    );');
    buffer.writeln('  }');
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

  /// Extracts validate option from annotation and generates code
  String? _extractValidateCode(ConstantReader? validateReader) {
    if (validateReader == null || validateReader.isNull) return null;

    final validators = <String>[];

    // Boolean validators
    _extractBooleanValidator(validateReader, 'isEmail', 'IsEmail', validators);
    _extractBooleanValidator(validateReader, 'isUrl', 'IsUrl', validators);
    _extractBooleanValidator(validateReader, 'isIP', 'IsIP', validators);
    _extractBooleanValidator(validateReader, 'isIPv4', 'IsIPv4', validators);
    _extractBooleanValidator(validateReader, 'isIPv6', 'IsIPv6', validators);
    _extractBooleanValidator(validateReader, 'isAlpha', 'IsAlpha', validators);
    _extractBooleanValidator(
      validateReader,
      'isAlphanumeric',
      'IsAlphanumeric',
      validators,
    );
    _extractBooleanValidator(
      validateReader,
      'isNumeric',
      'IsNumeric',
      validators,
    );
    _extractBooleanValidator(validateReader, 'isInt', 'IsInt', validators);
    _extractBooleanValidator(validateReader, 'isFloat', 'IsFloat', validators);
    _extractBooleanValidator(
      validateReader,
      'isDecimal',
      'IsDecimal',
      validators,
    );
    _extractBooleanValidator(
      validateReader,
      'isLowercase',
      'IsLowercase',
      validators,
    );
    _extractBooleanValidator(
      validateReader,
      'isUppercase',
      'IsUppercase',
      validators,
    );
    _extractBooleanValidator(
      validateReader,
      'notEmpty',
      'NotEmpty',
      validators,
    );
    _extractBooleanValidator(validateReader, 'isArray', 'IsArray', validators);
    _extractBooleanValidator(
      validateReader,
      'isCreditCard',
      'IsCreditCard',
      validators,
    );
    _extractBooleanValidator(validateReader, 'isDate', 'IsDate', validators);

    // Pattern validators (is_, not_)
    _extractPatternValidator(validateReader, 'is_', 'Is', validators);
    _extractPatternValidator(validateReader, 'not_', 'Not', validators);

    // String validators
    _extractStringValidator(validateReader, 'equals', 'Equals', validators);
    _extractStringValidator(validateReader, 'contains', 'Contains', validators);
    _extractStringValidator(validateReader, 'isAfter', 'IsAfter', validators);
    _extractStringValidator(validateReader, 'isBefore', 'IsBefore', validators);

    // Number validators
    _extractNumberValidator(validateReader, 'max', 'Max', validators);
    _extractNumberValidator(validateReader, 'min', 'Min', validators);
    _extractNumberValidator(validateReader, 'isUUID', 'IsUUID', validators);

    // Range validator (len)
    _extractLenValidator(validateReader, validators);

    // List validators
    _extractListValidator(validateReader, 'isIn', 'IsIn', validators);
    _extractListValidator(validateReader, 'notIn', 'NotIn', validators);
    _extractNotContainsValidator(validateReader, validators);

    if (validators.isEmpty) return null;

    return 'ValidateOption(${validators.join(', ')})';
  }

  void _extractBooleanValidator(
    ConstantReader reader,
    String fieldName,
    String className,
    List<String> validators,
  ) {
    final validatorReader = reader.peek(fieldName);
    if (validatorReader == null || validatorReader.isNull) return;

    final obj = validatorReader.objectValue;
    final msgReader = ConstantReader(obj).peek('msg');

    if (msgReader != null && !msgReader.isNull) {
      final msg = msgReader.stringValue;
      validators.add("$fieldName: $className.withMsg('$msg')");
    } else {
      validators.add('$fieldName: $className()');
    }
  }

  void _extractPatternValidator(
    ConstantReader reader,
    String fieldName,
    String className,
    List<String> validators,
  ) {
    final validatorReader = reader.peek(fieldName);
    if (validatorReader == null || validatorReader.isNull) return;

    final obj = validatorReader.objectValue;
    final patternReader = ConstantReader(obj).peek('pattern');
    final flagsReader = ConstantReader(obj).peek('flags');
    final msgReader = ConstantReader(obj).peek('msg');

    if (patternReader == null || patternReader.isNull) return;

    final pattern = patternReader.stringValue;
    final escapedPattern = pattern
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'");
    final flags = flagsReader?.isNull == false
        ? flagsReader?.stringValue
        : null;
    final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

    if (msg != null && flags != null) {
      validators.add(
        "$fieldName: $className.full(r'$escapedPattern', flags: '$flags', msg: '$msg')",
      );
    } else if (msg != null) {
      validators.add(
        "$fieldName: $className.withMsg(r'$escapedPattern', msg: '$msg')",
      );
    } else if (flags != null) {
      validators.add(
        "$fieldName: $className.withFlags(r'$escapedPattern', '$flags')",
      );
    } else {
      validators.add("$fieldName: $className(r'$escapedPattern')");
    }
  }

  void _extractStringValidator(
    ConstantReader reader,
    String fieldName,
    String className,
    List<String> validators,
  ) {
    final validatorReader = reader.peek(fieldName);
    if (validatorReader == null || validatorReader.isNull) return;

    final obj = validatorReader.objectValue;

    // Check if it has 'value' field (for Equals, Contains) or 'date' field (for IsAfter, IsBefore)
    final valueReader = ConstantReader(obj).peek('value');
    final dateReader = ConstantReader(obj).peek('date');
    final msgReader = ConstantReader(obj).peek('msg');

    final stringValue = valueReader?.isNull == false
        ? valueReader?.stringValue
        : dateReader?.isNull == false
        ? dateReader?.stringValue
        : null;

    if (stringValue == null) return;

    final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

    if (msg != null) {
      validators.add(
        "$fieldName: $className.withMsg('$stringValue', msg: '$msg')",
      );
    } else {
      validators.add("$fieldName: $className('$stringValue')");
    }
  }

  void _extractNumberValidator(
    ConstantReader reader,
    String fieldName,
    String className,
    List<String> validators,
  ) {
    final validatorReader = reader.peek(fieldName);
    if (validatorReader == null || validatorReader.isNull) return;

    final obj = validatorReader.objectValue;
    final valueReader = ConstantReader(obj).peek('value');
    final versionReader = ConstantReader(obj).peek('version'); // for IsUUID
    final msgReader = ConstantReader(obj).peek('msg');

    final numValue = valueReader?.isNull == false
        ? valueReader?.literalValue
        : versionReader?.isNull == false
        ? versionReader?.intValue
        : null;

    if (numValue == null) return;

    final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

    if (msg != null) {
      validators.add("$fieldName: $className.withMsg($numValue, msg: '$msg')");
    } else {
      validators.add('$fieldName: $className($numValue)');
    }
  }

  void _extractLenValidator(ConstantReader reader, List<String> validators) {
    final validatorReader = reader.peek('len');
    if (validatorReader == null || validatorReader.isNull) return;

    final obj = validatorReader.objectValue;
    final minReader = ConstantReader(obj).peek('min');
    final maxReader = ConstantReader(obj).peek('max');
    final msgReader = ConstantReader(obj).peek('msg');

    if (minReader == null ||
        minReader.isNull ||
        maxReader == null ||
        maxReader.isNull)
      return;

    final min = minReader.intValue;
    final max = maxReader.intValue;
    final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

    if (msg != null) {
      validators.add("len: Len.withMsg($min, $max, msg: '$msg')");
    } else {
      validators.add('len: Len($min, $max)');
    }
  }

  void _extractListValidator(
    ConstantReader reader,
    String fieldName,
    String className,
    List<String> validators,
  ) {
    final validatorReader = reader.peek(fieldName);
    if (validatorReader == null || validatorReader.isNull) return;

    final obj = validatorReader.objectValue;
    final valuesReader = ConstantReader(obj).peek('values');
    final msgReader = ConstantReader(obj).peek('msg');

    if (valuesReader == null || valuesReader.isNull) return;

    final values = valuesReader.listValue;
    final valueStrings = values
        .map((v) {
          final reader = ConstantReader(v);
          if (reader.isString) return "'${reader.stringValue}'";
          if (reader.isInt) return '${reader.intValue}';
          if (reader.isDouble) return '${reader.doubleValue}';
          if (reader.isBool) return '${reader.boolValue}';
          return 'null';
        })
        .join(', ');

    final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

    if (msg != null) {
      validators.add(
        "$fieldName: $className.withMsg([$valueStrings], msg: '$msg')",
      );
    } else {
      validators.add('$fieldName: $className([$valueStrings])');
    }
  }

  void _extractNotContainsValidator(
    ConstantReader reader,
    List<String> validators,
  ) {
    final validatorReader = reader.peek('notContains');
    if (validatorReader == null || validatorReader.isNull) return;

    final obj = validatorReader.objectValue;
    final valueReader = ConstantReader(obj).peek('value');
    final msgReader = ConstantReader(obj).peek('msg');

    if (valueReader == null || valueReader.isNull) return;

    String valueCode;
    if (valueReader.isString) {
      valueCode = "'${valueReader.stringValue}'";
    } else if (valueReader.isList) {
      final values = valueReader.listValue;
      final valueStrings = values
          .map((v) => "'${ConstantReader(v).stringValue}'")
          .join(', ');
      valueCode = '[$valueStrings]';
    } else {
      return;
    }

    final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

    if (msg != null) {
      validators.add(
        "notContains: NotContains.withMsg($valueCode, msg: '$msg')",
      );
    } else {
      validators.add('notContains: NotContains($valueCode)');
    }
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

          // Extract validate option
          final validateCode = _extractValidateCode(reader.peek('validate'));

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
              validateCode: validateCode,
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
  final String? validateCode; // Generated code for ValidateOption

  _FieldInfo({
    required this.fieldName,
    required this.name,
    required this.dataType,
    required this.dartType,
    this.autoIncrement = false,
    this.primaryKey = false,
    this.allowNull,
    this.defaultValue,
    this.validateCode,
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
