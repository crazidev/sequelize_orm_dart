part of '../../sequelize_model_generator.dart';

String _getDartTypeForQuery(String dataType) {
  // Extract base type name if parameterized (e.g., "TINYINT(2)" -> "TINYINT")
  final baseType = dataType.contains('(') ? dataType.split('(')[0] : dataType;

  switch (baseType) {
    case 'INTEGER':
    case 'TINYINT':
    case 'SMALLINT':
    case 'MEDIUMINT':
      return 'int';
    case 'BIGINT':
      return 'SequelizeBigInt';
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
