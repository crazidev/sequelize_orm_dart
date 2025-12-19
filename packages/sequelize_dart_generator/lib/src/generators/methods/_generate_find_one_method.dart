part of '../../sequelize_model_generator.dart';

void _generateFindOneMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
) {
  final queryBuilderClassName = '\$${className}Query';

  buffer.writeln('  @override');
  buffer.writeln(
    '  Future<$valuesClassName?> findOne(Query Function($queryBuilderClassName ${className.toLowerCase()}) builder) {',
  );
  buffer.writeln('    final query = builder($queryBuilderClassName());');
  buffer.writeln('    return QueryEngine().findOne(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    ).then((data) =>');
  buffer.writeln(
    '      data != null ? $valuesClassName.fromJson(data) : null',
  );
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
