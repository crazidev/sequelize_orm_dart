part of '../../sequelize_model_generator.dart';

String _getDataTypeExpression(_FieldInfo field) {
  String typeBase;

  if (field.dataType.contains('(')) {
    final base = field.dataType.split('(')[0];
    final params = field.dataType.substring(
      field.dataType.indexOf('(') + 1,
      field.dataType.lastIndexOf(')'),
    );

    if (base == 'TEXT' || base == 'BLOB') {
      // TEXT('long') -> DataType.TEXT.long
      final variant = params.replaceAll("'", "").replaceAll('"', "");
      typeBase = 'DataType.$base.$variant';
    } else {
      // New callable syntax: DataType.INTEGER(10)
      typeBase = 'DataType.$base($params)';
    }
  } else {
    typeBase = 'DataType.${field.dataType}';
  }

  String typeExpression = typeBase;
  if (field.unsigned) typeExpression += '.UNSIGNED';
  if (field.zerofill) typeExpression += '.ZEROFILL';
  if (field.binary) typeExpression += '.BINARY';

  return typeExpression;
}
