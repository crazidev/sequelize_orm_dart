part of '../../sequelize_model_generator.dart';

Map<String, dynamic> _extractTableAnnotation(ConstantReader annotation) {
  final result = <String, dynamic>{};

  // Optional fields
  if (annotation.peek('tableName')?.isNull == false) {
    result['tableName'] = annotation.peek('tableName')?.stringValue;
  }
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
    result['schemaDelimiter'] = annotation.peek('schemaDelimiter')?.stringValue;
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
