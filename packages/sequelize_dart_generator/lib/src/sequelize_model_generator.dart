import 'package:analyzer/dart/element/element.dart';
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
    final tableName =
        annotation.peek('tableName')?.stringValue ?? 'unknown_table';
    final underscored = annotation.peek('underscored')?.boolValue ?? true;
    final timestamps = annotation.peek('timestamps')?.boolValue ?? true;

    final fields = _getFields(element);
    final generatedClassName = '\$$className';
    final valuesClassName = '\$${className}Values';
    final createClassName = '\$${className}Create';

    final buffer = StringBuffer();

    _generateClassDefinition(
      buffer,
      generatedClassName,
      className,
    );
    _generateDefineMethod(buffer, generatedClassName);
    _generateGetAttributesMethod(buffer, fields);
    _generateGetAttributesJsonMethod(buffer);
    _generateGetOptionsJsonMethod(
      buffer,
      tableName,
      underscored,
      timestamps,
    );
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

    buffer.writeln('}');
    buffer.writeln();

    _generateClassValues(buffer, valuesClassName, fields);
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
  ) {
    buffer.writeln('  @override');
    buffer.writeln(
      '  $generatedClassName define(String modelName, Object sequelize) {',
    );
    buffer.writeln('    super.define(modelName, sequelize);');
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
          field.autoIncrement || field.primaryKey || field.defaultValue != null;

      if (hasExtraProperties) {
        buffer.write('''      ModelAttributes(
        name: '${field.name}',
        type: DataType.${field.dataType},
''');
        if (field.autoIncrement) buffer.writeln('        autoIncrement: true,');
        if (field.primaryKey) buffer.writeln('        primaryKey: true,');
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
    buffer.writeln('          \'notNull\': item.notNull,');
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

  void _generateGetOptionsJsonMethod(
    StringBuffer buffer,
    String tableName,
    bool underscored,
    bool timestamps,
  ) {
    buffer.writeln('  @override');
    buffer.writeln('  Map<String, dynamic> getOptionsJson() {');
    buffer.writeln(
      "    return {'tableName': '$tableName', 'underscored': $underscored, 'timestamps': $timestamps};",
    );
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
      '  Future<List<$valuesClassName>> findAll(Query Function($queryBuilderClassName) builder) {',
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
      '  Future<$valuesClassName?> findOne(Query Function($queryBuilderClassName) builder) {',
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
  ) {
    buffer.writeln('class $valuesClassName {');
    for (var field in fields) {
      buffer.writeln('  final ${field.dartType} ${field.fieldName};');
    }
    buffer.writeln();
    buffer.writeln('  $valuesClassName({');
    for (var field in fields) {
      buffer.writeln('    required this.${field.fieldName},');
    }
    buffer.writeln('  });');
    buffer.writeln();
    buffer.writeln(
      '  factory $valuesClassName.fromJson(Map<String, dynamic> json) {',
    );
    buffer.writeln('    return $valuesClassName(');
    for (var field in fields) {
      buffer.writeln("      ${field.fieldName}: json['${field.name}'],");
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');
    for (var field in fields) {
      buffer.writeln("      '${field.name}': ${field.fieldName},");
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
        "  final ${field.fieldName} = TypedColumn<$dartType>('${field.name}', DataType.${field.dataType});",
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
  final Object? defaultValue;

  _FieldInfo({
    required this.fieldName,
    required this.name,
    required this.dataType,
    required this.dartType,
    this.autoIncrement = false,
    this.primaryKey = false,
    this.defaultValue,
  });
}
