part of '../../sequelize_model_generator.dart';

void _generateIncludeExtension(
  StringBuffer buffer,
  String className,
) {
  final queryBuilderClassName = '\$${className}Query';
  final extensionName = '${className}Include';

  buffer.writeln('/// Type-safe include extension for $className');
  buffer.writeln(
    'extension $extensionName on AssociationReference<$className> {',
  );
  buffer.writeln('  /// Type-safe include with nested includes');
  buffer.writeln(
    '  /// The [query] function receives a `$queryBuilderClassName` instance and returns an `IncludeQuery` object',
  );
  buffer.writeln('  IncludeBuilder<$className> include([');
  buffer.writeln(
    '    IncludeQuery Function($queryBuilderClassName ${_toCamelCase(className)})? query,',
  );
  buffer.writeln('  ]) {');
  buffer.writeln('    if (query != null) {');
  buffer.writeln(
    '      return IncludeBuilder<$className>.fromQuery(',
  );
  buffer.writeln('        association: name,');
  buffer.writeln('        model: model,');
  buffer.writeln(
    '        query: query(model.getQueryBuilder() as $queryBuilderClassName),',
  );
  buffer.writeln('      );');
  buffer.writeln('    }');
  buffer.writeln();
  buffer.writeln('    return IncludeBuilder<$className>(');
  buffer.writeln('      association: name,');
  buffer.writeln('      model: model,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();
}
