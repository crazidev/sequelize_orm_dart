part of '../../sequelize_model_generator.dart';

void _generateCountMethod(
  StringBuffer buffer,
  String className,
  String whereCallbackName,
  GeneratorNamingConfig namingConfig,
) {
  final columnsClassName = namingConfig.getModelColumnsClassName(className);

  buffer.writeln('  @override');
  buffer.writeln('  Future<int> count({');
  buffer.writeln(
    '    QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln('  }) {');
  buffer.writeln('    const columns = $columnsClassName();');
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      columns: columns,');
  buffer.writeln('    );');
  buffer.writeln('    return QueryEngine().count(');
  buffer.writeln('      modelName: modelName,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
