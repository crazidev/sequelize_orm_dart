part of '../../sequelize_model_generator.dart';

void _generateRestoreMethod(
  StringBuffer buffer,
  String className,
  String whereCallbackName,
  GeneratorNamingConfig namingConfig,
) {
  final columnsClassName = namingConfig.getModelColumnsClassName(className);

  buffer.writeln('  @override');
  buffer.writeln('  Future<void> restore({');
  buffer.writeln(
    '    QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln('    int? limit,');
  buffer.writeln('    bool? individualHooks,');
  buffer.writeln('  }) {');
  buffer.writeln('    const columns = $columnsClassName();');
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      columns: columns,');
  buffer.writeln('    );');
  buffer.writeln('    final options = <String, dynamic>{');
  buffer.writeln('      ...query.toJson(),');
  buffer.writeln('      if (limit != null) \'limit\': limit,');
  buffer.writeln(
    '      if (individualHooks != null) \'individualHooks\': individualHooks,',
  );
  buffer.writeln('    };');
  buffer.writeln('    return QueryEngine().restore(');
  buffer.writeln('      modelName: modelName,');
  buffer.writeln('      options: options,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
