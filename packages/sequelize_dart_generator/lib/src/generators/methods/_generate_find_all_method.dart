part of '../../sequelize_model_generator.dart';

void _generateFindAllMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
  String whereCallbackName,
  String includeCallbackName,
) {
  final columnsClassName = '\$${className}Columns';
  final includeHelperClassName = '\$${className}IncludeHelper';

  buffer.writeln('  @override');
  buffer.writeln('  Future<List<$valuesClassName>> findAll({');
  buffer.writeln(
    '    QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln(
    '    List<IncludeBuilder> Function($includeHelperClassName $includeCallbackName)? include,',
  );
  buffer.writeln('    dynamic order,');
  buffer.writeln('    dynamic group,');
  buffer.writeln('    int? limit,');
  buffer.writeln('    int? offset,');
  buffer.writeln('    QueryAttributes? attributes,');
  buffer.writeln('  }) {');
  buffer.writeln('    const columns = $columnsClassName();');
  buffer.writeln('    const includeHelper = $includeHelperClassName();');
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      include: include,');
  buffer.writeln('      columns: columns,');
  buffer.writeln('      includeHelper: includeHelper,');
  buffer.writeln('      order: order,');
  buffer.writeln('      group: group,');
  buffer.writeln('      limit: limit,');
  buffer.writeln('      offset: offset,');
  buffer.writeln('      attributes: attributes,');
  buffer.writeln('    );');
  buffer.writeln('    return QueryEngine().findAll(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    ).then((data) =>');
  buffer.writeln('      data.map((value) {');
  buffer.writeln('        final instance = $valuesClassName.fromJson(value);');
  buffer.writeln('        instance._originalQuery = query;');
  buffer.writeln('        return instance;');
  buffer.writeln('      }).toList()');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
