part of '../../sequelize_model_generator.dart';

void _generateSumMethod(
  StringBuffer buffer,
  String className,
  String whereCallbackName,
) {
  final columnsClassName = '\$${className}Columns';

  buffer.writeln('  @override');
  buffer.writeln('  Future<num?> sum(');
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
  buffer.writeln('    return QueryEngine().sum(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      column: column.name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
