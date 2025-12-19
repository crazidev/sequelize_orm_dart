part of '../../sequelize_model_generator.dart';

void _generateFindAllMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
) {
  final queryBuilderClassName = '\$${className}Query';

  buffer.writeln('  @override');
  buffer.writeln(
    '  Future<List<$valuesClassName>> findAll(Query Function($queryBuilderClassName ${className.toLowerCase()}) builder) {',
  );
  buffer.writeln('    final query = builder($queryBuilderClassName());');
  buffer.writeln('    return QueryEngine().findAll(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    ).then((data) =>');
  buffer.writeln(
    '      data.map((value) => $valuesClassName.fromJson(value)).toList()',
  );
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
