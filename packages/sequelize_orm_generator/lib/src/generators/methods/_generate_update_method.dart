part of '../../sequelize_model_generator.dart';

void _generateUpdateMethod(
  StringBuffer buffer,
  String className,
  String whereCallbackName,
  List<_FieldInfo> fields,
  GeneratorNamingConfig namingConfig,
) {
  final columnsClassName = namingConfig.getModelColumnsClassName(className);

  // Generate update method with named parameters for each field
  buffer.writeln('  Future<int> update({');

  // Add named parameters for each field (excluding primary keys and auto-increment)
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln('    ${field.dartType}? ${field.fieldName},');
    }
  }

  buffer.writeln(
    '    required QueryOperator Function($columnsClassName $whereCallbackName) where,',
  );
  buffer.writeln('  }) {');

  // Build data map from named parameters
  buffer.writeln('    final data = <String, dynamic>{};');
  for (var field in fields) {
    if (!field.autoIncrement && !field.primaryKey) {
      buffer.writeln(
        "    if (${field.fieldName} != null) data['${field.name}'] = ${field.fieldName};",
      );
    }
  }

  buffer.writeln();
  buffer.writeln('    if (data.isEmpty) {');
  buffer.writeln(
    '      throw ArgumentError(\'Data cannot be empty for update\');',
  );
  buffer.writeln('    }');

  buffer.writeln();
  buffer.writeln('    const columns = $columnsClassName();');
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      columns: columns,');
  buffer.writeln('    );');

  buffer.writeln();
  buffer.writeln('    return QueryEngine().update(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      data: data,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
