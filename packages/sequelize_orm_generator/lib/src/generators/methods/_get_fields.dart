part of '../../sequelize_model_generator.dart';

Future<List<_FieldInfo>> _getFields(
  ClassElement element,
  InitializerSourceProvider initializerSourceProvider,
) async {
  final fields = <_FieldInfo>[];
  const columnDefinitionChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/model_attribute.dart#ColumnDefinition',
  );

  // Decorator checkers
  const primaryKeyChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/table.dart#PrimaryKey',
  );
  const validatorChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/model_attribute.dart#Validator',
  );
  const autoIncrementChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/table.dart#AutoIncrement',
  );
  const notNullChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/table.dart#NotNull',
  );
  const columnNameChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/table.dart#ColumnName',
  );
  const defaultChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/table.dart#Default',
  );
  const commentChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/table.dart#Comment',
  );
  const uniqueChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/table.dart#Unique',
  );
  const indexChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/table.dart#Index',
  );
  const enumPrefixChecker = TypeChecker.fromUrl(
    'package:sequelize_orm/src/annotations/enum_prefix.dart#EnumPrefix',
  );

  for (var field in element.fields) {
    if (field.name == null) continue;

    // Pattern 1: @ColumnDefinition annotation (legacy)
    if (columnDefinitionChecker.hasAnnotationOfExact(field)) {
      final annotation = columnDefinitionChecker.firstAnnotationOfExact(field);
      if (annotation != null) {
        final reader = ConstantReader(annotation);
        final fieldName = field.name ?? 'unknown_field';
        final name = reader.peek('name')?.stringValue ?? fieldName;
        final typeObj = reader.peek('type')?.objectValue;

        String dataType = 'STRING';
        bool unsigned = false;
        bool zerofill = false;
        bool binary = false;
        String? jsonDartTypeHint;
        List<String>? enumValues;

        if (typeObj != null) {
          final typeReader = ConstantReader(typeObj);
          final nameValue = typeReader.peek('name')?.stringValue;
          if (nameValue != null) {
            dataType = nameValue;

            // Check for JSON dart type hint
            final jsonDartTypeValue = typeReader.peek('dartType')?.stringValue;
            if (jsonDartTypeValue != null) {
              jsonDartTypeHint = jsonDartTypeValue;
            }

            // Check for additional parameters (length, scale, variant)
            final lengthValue = typeReader.peek('length')?.intValue;
            final scaleValue = typeReader.peek('scale')?.intValue;
            final variantValue = typeReader.peek('variant')?.stringValue;

            // Check for chained properties
            unsigned = typeReader.peek('unsigned')?.boolValue ?? false;
            zerofill = typeReader.peek('zerofill')?.boolValue ?? false;
            binary = typeReader.peek('binary')?.boolValue ?? false;

            // ENUM: read values list
            final valuesObj = typeReader.peek('values');
            if (nameValue == 'ENUM' && valuesObj != null && !valuesObj.isNull) {
              final listValue = valuesObj.listValue;
              if (listValue.isNotEmpty) {
                enumValues = listValue
                    .map((c) => ConstantReader(c).stringValue)
                    .whereType<String>()
                    .toList();
              }
            }

            // Construct the full dataType representation
            if (variantValue != null) {
              // e.g., TEXT('tiny')
              dataType = "$dataType('$variantValue')";
            } else if (enumValues != null && enumValues.isNotEmpty) {
              dataType = 'ENUM';
            } else if (scaleValue != null && lengthValue != null) {
              // e.g., DECIMAL(10, 2)
              dataType = '$dataType($lengthValue, $scaleValue)';
            } else if (lengthValue != null) {
              // e.g., TINYINT(2), STRING(255)
              dataType = '$dataType($lengthValue)';
            }
          } else {
            final typeField = typeObj.variable;
            if (typeField != null) {
              dataType = typeField.name ?? 'STRING';
            }
          }
        }

        final autoIncrement = reader.peek('autoIncrement')?.boolValue ?? false;
        final primaryKey = reader.peek('primaryKey')?.boolValue ?? false;
        final allowNull = reader.peek('allowNull')?.boolValue;
        final defaultValue = reader.peek('defaultValue')?.literalValue;
        final columnName = reader.peek('columnName')?.stringValue;
        final comment = reader.peek('comment')?.stringValue;
        final autoIncrementIdentity =
            reader.peek('autoIncrementIdentity')?.boolValue;

        // Extract unique
        Object? unique;
        final uniqueReader = reader.peek('unique');
        if (uniqueReader != null && !uniqueReader.isNull) {
          if (uniqueReader.isBool) {
            unique = uniqueReader.boolValue;
          } else if (uniqueReader.isString) {
            unique = uniqueReader.stringValue;
          }
        }

        // Extract index
        Object? index;
        final indexReader = reader.peek('index');
        if (indexReader != null && !indexReader.isNull) {
          if (indexReader.isBool) {
            index = indexReader.boolValue;
          } else if (indexReader.isString) {
            index = indexReader.stringValue;
          }
        }

        // Extract validate option
        final validateCode = _extractValidateCode(reader.peek('validate'));

        final dartType =
            _getDartTypeForQuery(dataType, jsonDartTypeHint: jsonDartTypeHint);

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
            columnName: columnName,
            comment: comment,
            unique: unique,
            index: index,
            autoIncrementIdentity: autoIncrementIdentity,
            unsigned: unsigned,
            zerofill: zerofill,
            binary: binary,
            jsonDartTypeHint: jsonDartTypeHint,
            enumValues: enumValues,
          ),
        );
        continue;
      }
    }

    // Pattern 2: Attribute field (new syntax: Attribute firstName = Attribute(DataType.STRING))
    final fieldType = field.type;
    if (fieldType.element != null &&
        fieldType.element!.name == 'Attribute' &&
        fieldType.element!.library?.identifier ==
            'package:sequelize_orm/src/annotations/attribute.dart') {
      final fieldInfo = await _extractFromAttributeField(
        field,
        initializerSourceProvider,
        primaryKeyChecker,
        autoIncrementChecker,
        notNullChecker,
        columnNameChecker,
        defaultChecker,
        commentChecker,
        uniqueChecker,
        indexChecker,
        validatorChecker,
        enumPrefixChecker,
      );
      if (fieldInfo != null) {
        fields.add(fieldInfo);
      }
      continue;
    }

    // Pattern 3: DataType field (simpler syntax: DataType firstName = DataType.STRING)
    if (fieldType.element != null &&
        fieldType.element!.name == 'DataType' &&
        fieldType.element!.library?.identifier ==
            'package:sequelize_orm/src/annotations/datatype.dart') {
      final fieldInfo = await _extractFromDataTypeField(
        field,
        initializerSourceProvider,
        primaryKeyChecker,
        autoIncrementChecker,
        notNullChecker,
        columnNameChecker,
        defaultChecker,
        commentChecker,
        uniqueChecker,
        indexChecker,
        validatorChecker,
        enumPrefixChecker,
      );
      if (fieldInfo != null) {
        fields.add(fieldInfo);
      }
    }
  }
  return fields;
}

String? _extractDefaultAnnotationSource(FieldElement field) {
  for (final meta in field.metadata.annotations) {
    final annotationElement = meta.element;
    final enclosing = annotationElement?.enclosingElement;
    if (enclosing?.name != 'Default') continue;

    final source = meta.toSource().trim();
    final start = source.indexOf('(');
    final end = source.lastIndexOf(')');
    if (start == -1 || end <= start) return null;

    final valueSource = source.substring(start + 1, end).trim();
    if (valueSource.isEmpty) return null;
    return valueSource;
  }
  return null;
}

Future<_FieldInfo?> _extractFromAttributeField(
  FieldElement field,
  InitializerSourceProvider initializerSourceProvider,
  TypeChecker primaryKeyChecker,
  TypeChecker autoIncrementChecker,
  TypeChecker notNullChecker,
  TypeChecker columnNameChecker,
  TypeChecker defaultChecker,
  TypeChecker commentChecker,
  TypeChecker uniqueChecker,
  TypeChecker indexChecker,
  TypeChecker validatorChecker,
  TypeChecker enumPrefixChecker,
) async {
  final fieldName = field.name ?? 'unknown_field';

  // Extract DataType from Attribute initializer
  String dataType = 'STRING';
  bool unsigned = false;
  bool zerofill = false;
  bool binary = false;
  String? jsonDartTypeHint;
  List<String>? enumValues;

  // Try to get constant value from field first (works if field is const)
  final constantValue = field.computeConstantValue();

  // If the field is not const, try to get the constant value from the initializer
  if (constantValue == null) {
    try {
      final String? source = await initializerSourceProvider(field);
      if (source != null && source.contains('DataType.')) {
        // Match patterns like:
        // - DataType.STRING
        // - DataType.TINYINT_length(2)
        // - DataType.DECIMAL_precision(10, 2)
        final match = RegExp(
          r'DataType\.([a-zA-Z0-9_]+)\s*(\([^)]*\))?',
        ).firstMatch(source);
        if (match != null) {
          final typeName = match.group(1)!;
          final params = match.group(2);

          // Match patterns like:
          // - DataType.STRING
          // - DataType.INTEGER(10)
          // - DataType.DECIMAL(10, 2)
          if (params != null) {
            final paramValues = params.substring(1, params.length - 1);
            final baseType = typeName.split('_')[0];

            // JSON/JSONB with type: parameter — extract Dart type hint
            if ((baseType == 'JSON' || baseType == 'JSONB') &&
                paramValues.contains('type:')) {
              dataType = baseType;
              final typeMatch = RegExp(r'type:\s*(.+)').firstMatch(paramValues);
              if (typeMatch != null) {
                jsonDartTypeHint = typeMatch.group(1)!.trim();
              }
            } else if (baseType == 'ENUM') {
              dataType = 'ENUM';
              enumValues = _parseEnumValues(paramValues);
            } else {
              dataType = '$baseType($paramValues)';
            }
          } else {
            dataType = typeName;
          }
        }

        // Extract chained properties from source like .UNSIGNED.ZEROFILL
        if (source.contains('.UNSIGNED')) unsigned = true;
        if (source.contains('.ZEROFILL')) zerofill = true;
        if (source.contains('.BINARY')) binary = true;

        // Handle TEXT variants from getters like .long, .medium, .tiny
        if (dataType == 'TEXT') {
          if (source.contains('.tiny')) dataType = "TEXT('tiny')";
          if (source.contains('.medium')) dataType = "TEXT('medium')";
          if (source.contains('.long')) dataType = "TEXT('long')";
        }
      }
    } catch (e) {
      // Ignore errors during constant evaluation
    }
  }

  if (constantValue != null) {
    // Attribute(DataType.STRING) - extract the type argument
    final typeObj = ConstantReader(constantValue).peek('type')?.objectValue;
    if (typeObj != null) {
      final typeReader = ConstantReader(typeObj);
      final nameValue = typeReader.peek('name')?.stringValue;
      if (nameValue != null) {
        dataType = nameValue;

        // Check for JSON dart type hint
        final jsonDartTypeValue = typeReader.peek('dartType')?.stringValue;
        if (jsonDartTypeValue != null) {
          jsonDartTypeHint = jsonDartTypeValue;
        }

        // Check for additional parameters (length, scale, variant)
        final lengthValue = typeReader.peek('length')?.intValue;
        final scaleValue = typeReader.peek('scale')?.intValue;
        final variantValue = typeReader.peek('variant')?.stringValue;

        // ENUM: read values list
        final valuesObj = typeReader.peek('values');
        if (nameValue == 'ENUM' && valuesObj != null && !valuesObj.isNull) {
          final listValue = valuesObj.listValue;
          if (listValue.isNotEmpty) {
            enumValues = listValue
                .map((c) => ConstantReader(c).stringValue)
                .whereType<String>()
                .toList();
          }
        }

        // Check for chained properties
        unsigned = typeReader.peek('unsigned')?.boolValue ?? false;
        zerofill = typeReader.peek('zerofill')?.boolValue ?? false;
        binary = typeReader.peek('binary')?.boolValue ?? false;

        // Construct the full dataType representation
        if (variantValue != null) {
          // e.g., TEXT('tiny')
          dataType = "$dataType('$variantValue')";
        } else if (enumValues != null && enumValues.isNotEmpty) {
          dataType = 'ENUM';
        } else if (scaleValue != null && lengthValue != null) {
          // e.g., DECIMAL(10, 2)
          dataType = '$dataType($lengthValue, $scaleValue)';
        } else if (lengthValue != null) {
          // e.g., TINYINT(2), STRING(255)
          dataType = '$dataType($lengthValue)';
        }
      } else {
        // Fallback to the variable name if name field is missing
        final typeField = typeObj.variable;
        if (typeField != null) {
          dataType = typeField.name ?? 'STRING';
        }
      }
    }
  }

  // Extract decorators using TypeChecker
  bool primaryKey = false;
  bool autoIncrement = false;
  bool? allowNull;
  Object? defaultValue;
  String? columnName;
  String? comment;
  Object? unique;
  Object? index;
  bool? autoIncrementIdentity;

  if (primaryKeyChecker.hasAnnotationOfExact(field)) {
    primaryKey = true;
  }
  if (autoIncrementChecker.hasAnnotationOfExact(field)) {
    autoIncrement = true;
  }
  if (notNullChecker.hasAnnotationOfExact(field)) {
    allowNull = false; // @NotNull means allowNull = false
  }
  if (columnNameChecker.hasAnnotationOfExact(field)) {
    final annotation = columnNameChecker.firstAnnotationOfExact(field);
    if (annotation != null) {
      final reader = ConstantReader(annotation);
      columnName = reader.peek('name')?.stringValue;
    }
  }
  if (defaultChecker.hasAnnotationOfExact(field)) {
    final annotation = defaultChecker.firstAnnotationOfExact(field);
    if (annotation != null) {
      final reader = ConstantReader(annotation);
      defaultValue = reader.peek('value')?.literalValue;
      // TODO: Handle Default.uniqid(), Default.now(), Default.fn()
    }
  }
  if (commentChecker.hasAnnotationOfExact(field)) {
    final annotation = commentChecker.firstAnnotationOfExact(field);
    if (annotation != null) {
      final reader = ConstantReader(annotation);
      comment = reader.peek('comment')?.stringValue;
    }
  }
  if (uniqueChecker.hasAnnotationOfExact(field)) {
    final annotation = uniqueChecker.firstAnnotationOfExact(field);
    if (annotation != null) {
      final reader = ConstantReader(annotation);
      final value = reader.peek('value');
      if (value != null && !value.isNull) {
        if (value.isString) {
          unique = value.stringValue;
        } else {
          unique = true;
        }
      } else {
        unique = true;
      }
    }
  }
  if (indexChecker.hasAnnotationOfExact(field)) {
    final annotation = indexChecker.firstAnnotationOfExact(field);
    if (annotation != null) {
      final reader = ConstantReader(annotation);
      final value = reader.peek('value');
      if (value != null && !value.isNull) {
        if (value.isString) {
          index = value.stringValue;
        } else {
          index = true;
        }
      } else {
        index = true;
      }
    }
  }

  // Default to nullable (allowNull = null) if no @NotNull decorator

  final dartType =
      _getDartTypeForQuery(dataType, jsonDartTypeHint: jsonDartTypeHint);

  // Use columnName if provided, otherwise use fieldName (will be converted to snake_case)
  final name = columnName ?? fieldName;

  // Extract validators
  final validateCode = _extractValidators(field, validatorChecker);

  // Extract enum prefix from @EnumPrefix annotation
  String? enumPrefix;
  String? enumOpposite;
  if (enumPrefixChecker.hasAnnotationOfExact(field)) {
    final annotation = enumPrefixChecker.firstAnnotationOfExact(field);
    if (annotation != null) {
      final reader = ConstantReader(annotation);
      enumPrefix = reader.peek('prefix')?.stringValue;
      enumOpposite = reader.peek('opposite')?.stringValue;
    }
  }

  return _FieldInfo(
    fieldName: fieldName,
    name: name,
    dataType: dataType,
    dartType: dartType,
    autoIncrement: autoIncrement,
    primaryKey: primaryKey,
    allowNull: allowNull,
    defaultValue: defaultValue,
    defaultValueSource: _extractDefaultAnnotationSource(field),
    validateCode: validateCode,
    columnName: columnName,
    comment: comment,
    unique: unique,
    index: index,
    autoIncrementIdentity: autoIncrementIdentity,
    unsigned: unsigned,
    zerofill: zerofill,
    binary: binary,
    jsonDartTypeHint: jsonDartTypeHint,
    enumValues: enumValues,
    enumPrefix: enumPrefix,
    enumOpposite: enumOpposite,
  );
}

/// Extract validator annotations and merge them into a ValidateOption string
String? _extractValidators(FieldElement field, TypeChecker validatorChecker) {
  final validatorSpecs = <String, String>{};

  for (var meta in field.metadata.annotations) {
    final constant = meta.computeConstantValue();
    if (constant == null) continue;

    final type = constant.type;
    if (type == null) continue;

    if (validatorChecker.isAssignableFromType(type)) {
      // It's a validator!
      String source = meta.toSource();
      // Remove @ prefix
      if (source.startsWith('@')) {
        source = source.substring(1);
      }

      // Map class name to ValidateOption field name
      final className = type.getDisplayString();
      String fieldName = className[0].toLowerCase() + className.substring(1);

      // Handle the new @Validate namespace class
      if (className == 'Validate') {
        final constructorName = meta.element?.name;
        if (constructorName == null || constructorName.isEmpty) continue;

        // Strip "Validate." prefix from source
        final dotIndex = source.indexOf('.');
        if (dotIndex != -1) {
          source = source.substring(dotIndex + 1);
        }

        // Map constructor name to the real validator info
        String actualClassName = constructorName;
        if (constructorName == 'IsWithFlags') {
          source = source.replaceFirst('IsWithFlags', 'Is.withFlags');
          actualClassName = 'Is';
        } else if (constructorName == 'NotWithFlags') {
          source = source.replaceFirst('NotWithFlags', 'Not.withFlags');
          actualClassName = 'Not';
        }

        fieldName =
            actualClassName[0].toLowerCase() + actualClassName.substring(1);
      } else {
        // Strip library prefix if present (e.g., Pref.IsEmail -> IsEmail)
        final classIndex = source.indexOf(className);
        if (classIndex > 0 && source[classIndex - 1] == '.') {
          source = source.substring(classIndex);
        }
      }

      // Special cases for keywords
      if (fieldName == 'is') fieldName = 'is_';
      if (fieldName == 'not') fieldName = 'not_';

      validatorSpecs[fieldName] = source;
    }
  }

  if (validatorSpecs.isEmpty) return null;

  final buffer = StringBuffer('ValidateOption(\n');
  validatorSpecs.forEach((name, code) {
    buffer.writeln('        $name: $code,');
  });
  buffer.write('      )');
  return buffer.toString();
}
