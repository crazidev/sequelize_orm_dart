part of '../../sequelize_model_generator.dart';

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
