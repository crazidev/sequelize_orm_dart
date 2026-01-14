part of '../../sequelize_model_generator.dart';

Future<_FieldInfo?> _extractFromDataTypeField(
  FieldElement field,
  BuildStep buildStep,
  TypeChecker primaryKeyChecker,
  TypeChecker autoIncrementChecker,
  TypeChecker notNullChecker,
  TypeChecker columnNameChecker,
  TypeChecker defaultChecker,
  TypeChecker commentChecker,
  TypeChecker uniqueChecker,
  TypeChecker indexChecker,
  TypeChecker validatorChecker,
) async {
  final fieldName = field.name ?? 'unknown_field';

  // Extract DataType directly from field initializer
  // DataType firstName = DataType.STRING
  String dataType = 'STRING';

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
  bool unsigned = false;
  bool zerofill = false;
  bool binary = false;

  // Try to get constant value from field first (works if field is const/final)
  final constantValue = field.computeConstantValue();

  // If the field is not const, try to get the constant value from the initializer
  if (constantValue == null) {
    try {
      final dynamic node = await buildStep.resolver.astNodeFor(
        field.firstFragment,
        resolve: true,
      );
      if (node != null) {
        // We use dynamic access here to avoid issues with VariableDeclaration type promotion/imports
        try {
          final dynamic initializer = node.initializer;
          if (initializer != null) {
            final String source = initializer.toSource() as String;
            // Extract the DataType from DataType.XXX or DataType.XXX_method(params)
            if (source.contains('DataType.')) {
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
                  // Extract parameters (e.g., "10" from "(10)")
                  final paramValues = params.substring(1, params.length - 1);

                  // Handle both legacy DataType.INTEGER_length(10) and new DataType.INTEGER(10)
                  final baseType = typeName.split('_')[0];
                  dataType = '$baseType($paramValues)';
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
          }
        } catch (e) {
          // The node might not be a VariableDeclaration
        }
      }
    } catch (e) {
      // Ignore errors during constant evaluation
    }
  }

  if (constantValue != null) {
    // DataType.STRING or DataType.TINYINT_length(2) - extract the type name and parameters
    final typeReader = ConstantReader(constantValue);
    final nameValue = typeReader.peek('name')?.stringValue;
    if (nameValue != null) {
      dataType = nameValue;

      // Check for additional parameters (length, scale, variant)
      final lengthValue = typeReader.peek('length')?.intValue;
      final scaleValue = typeReader.peek('scale')?.intValue;
      final variantValue = typeReader.peek('variant')?.stringValue;

      // Check for chained properties
      unsigned = typeReader.peek('unsigned')?.boolValue ?? false;
      zerofill = typeReader.peek('zerofill')?.boolValue ?? false;
      binary = typeReader.peek('binary')?.boolValue ?? false;

      // Construct the full dataType representation
      if (variantValue != null) {
        // e.g., TEXT('tiny')
        dataType = "$dataType('$variantValue')";
      } else if (scaleValue != null && lengthValue != null) {
        // e.g., DECIMAL(10, 2)
        dataType = '$dataType($lengthValue, $scaleValue)';
      } else if (lengthValue != null) {
        // e.g., TINYINT(2), STRING(255)
        dataType = '$dataType($lengthValue)';
      }
    } else {
      // Fallback to the variable name if name field is missing
      final typeField = constantValue.variable;
      if (typeField != null) {
        dataType = typeField.name ?? 'STRING';
      }
    }
  }

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

  final dartType = _getDartTypeForQuery(dataType);

  // Use columnName if provided, otherwise use fieldName (will be converted to snake_case)
  final name = columnName ?? fieldName;

  // Extract validators
  final validateCode = _extractValidators(field, validatorChecker);

  return _FieldInfo(
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
  );
}
