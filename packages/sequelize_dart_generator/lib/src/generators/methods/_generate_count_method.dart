part of '../../sequelize_model_generator.dart';

void _generateCountMethod(
  StringBuffer buffer,
  String className,
  String whereCallbackName,
) {
  final columnsClassName = '\$${className}Columns';

  buffer.writeln('  @override');
  buffer.writeln('  Future<int> count({');
  buffer.writeln(
    '    QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln('  }) {');
  buffer.writeln('    final columns = $columnsClassName();');
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      columns: columns,');
  buffer.writeln('    );');
  buffer.writeln('    return QueryEngine().count(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
