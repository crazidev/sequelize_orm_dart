part of '../../sequelize_model_generator.dart';

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

        final autoIncrement = reader.peek('autoIncrement')?.boolValue ?? false;
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
