part of '../../sequelize_model_generator.dart';

void _generateMaxMethod(
  StringBuffer buffer,
  String className,
  String whereCallbackName,
  GeneratorNamingConfig namingConfig,
) {
  final columnsClassName = namingConfig.getModelColumnsClassName(className);

  buffer.writeln('  @override');
  buffer.writeln('  Future<num?> max(');
  buffer.writeln(
    '    Column Function($columnsClassName column) columnFn,',
  );
  buffer.writeln('    {');
  buffer.writeln(
    '      QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln('    }');
  buffer.writeln('  ) {');
  buffer.writeln('    final columns = $columnsClassName();');
  buffer.writeln('    final column = columnFn(columns);');
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      columns: columns,');
  buffer.writeln('    );');
  buffer.writeln('    return QueryEngine().max(');
  buffer.writeln('      modelName: modelName,');
  buffer.writeln('      column: column.name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
