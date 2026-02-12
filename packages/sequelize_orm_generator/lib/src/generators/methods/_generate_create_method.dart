part of '../../sequelize_model_generator.dart';

void _generateCreateMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
  String whereCallbackName,
  String includeCallbackName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations,
  GeneratorNamingConfig namingConfig,
) {
  final createClassName = namingConfig.getModelCreateClassName(className);

  // Generate create method that accepts Create class with associations
  buffer.writeln(
    '  Future<$valuesClassName> create($createClassName createData) {',
  );
  buffer.writeln(
    '    // Convert Create class to JSON (includes nested associations)',
  );
  buffer.writeln('    final data = createData.toJson();');
  buffer.writeln();
  buffer.writeln('    // Build include list for associations');
  buffer.writeln('    final includeList = <IncludeBuilder>[];');

  for (final assoc in associations) {
    final assocName = assoc.as ?? assoc.fieldName;
    final modelClassName = assoc.modelClassName;
    buffer.writeln('    if (createData.${assoc.fieldName} != null) {');
    buffer.writeln('      includeList.add(');
    buffer.writeln('        IncludeBuilder(');
    buffer.writeln('          association: \'$assocName\',');
    buffer.writeln('          model: $modelClassName.model,');
    buffer.writeln(
      '          // Allow nested create (e.g. create PostDetails with Post, and Post with User)',
    );
    buffer.writeln(
      '          // This tells Sequelize to accept nested association objects inside the payload.',
    );
    buffer.writeln(
      '          include: [IncludeBuilder(all: true, nested: true)],',
    );
    buffer.writeln('        ),');
    buffer.writeln('      );');
    buffer.writeln('    }');
  }

  buffer.writeln();
  buffer.writeln(
    '    // Build query with include option if associations exist',
  );
  buffer.writeln('    final query = Query(');
  buffer.writeln('      include: includeList.isNotEmpty ? includeList : null,');
  buffer.writeln('    );');
  buffer.writeln();

  buffer.writeln('    return QueryEngine().create(');
  buffer.writeln('      modelName: modelName,');
  buffer.writeln('      data: data,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    ).then((result) {');
  buffer.writeln(
    '      final instance = $valuesClassName.fromJson(result.data);',
  );
  buffer.writeln('      instance.originalQuery = query;');
  buffer.writeln('      instance.setPreviousDataValues(instance.toJson());');
  buffer.writeln('      return instance;');
  buffer.writeln('    });');
  buffer.writeln('  }');
  buffer.writeln();
}
