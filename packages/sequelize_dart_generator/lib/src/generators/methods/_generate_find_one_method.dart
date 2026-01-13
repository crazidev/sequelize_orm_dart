part of '../../sequelize_model_generator.dart';

void _generateFindOneMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
  String whereCallbackName,
  String includeCallbackName,
) {
  final columnsClassName = '\$${className}Columns';
  final includeHelperClassName = '\$${className}IncludeHelper';

  buffer.writeln('  @override');
  buffer.writeln('  Future<$valuesClassName?> findOne({');
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
  buffer.writeln('    return QueryEngine().findOne(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    ).then((result) =>');
  buffer.writeln('      result != null ? (() {');
  buffer.writeln(
    '        final instance = $valuesClassName.fromJson(result.data);',
  );
  buffer.writeln('        instance.originalQuery = query;');
  // TODO: Once JS side enables previous() and changed(), these will be populated
  // Currently these are empty {} and [] respectively until JS implementation is enabled
  buffer.writeln('        instance.previous = result.previous;');
  buffer.writeln('        instance.changedFields = result.changed;');
  buffer.writeln('        instance.isNewRecord = result.isNewRecord;');
  buffer.writeln('        return instance;');
  buffer.writeln('      })() : null');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
