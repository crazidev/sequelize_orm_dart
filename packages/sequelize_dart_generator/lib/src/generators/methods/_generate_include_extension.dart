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
    '  /// The [include] function receives a `$queryBuilderClassName` instance for type-safe nested includes',
  );
  buffer.writeln('  IncludeBuilder<$className> include({');
  buffer.writeln('    bool? separate,');
  buffer.writeln('    bool? required,');
  buffer.writeln('    bool? right,');
  buffer.writeln(
    '    QueryOperator Function($queryBuilderClassName ${_toCamelCase(className)})? where,',
  );
  buffer.writeln('    QueryAttributes? attributes,');
  buffer.writeln('    List<List<String>>? order,');
  buffer.writeln('    int? limit,');
  buffer.writeln('    int? offset,');
  buffer.writeln(
    '    List<IncludeBuilder> Function($queryBuilderClassName ${_toCamelCase(className)})? include,',
  );
  buffer.writeln('    Map<String, dynamic>? through,');
  buffer.writeln('  }) {');
  buffer.writeln(
    '    return IncludeBuilder<$className>(',
  );
  buffer.writeln('      association: name,');
  buffer.writeln('      model: model,');
  buffer.writeln('      separate: separate,');
  buffer.writeln('      required: required,');
  buffer.writeln('      right: right,');
  buffer.writeln(
    '      where: where != null ? (dynamic qb) => where(qb as \$${className}Query) : null,',
  );
  buffer.writeln('      attributes: attributes,');
  buffer.writeln('      order: order,');
  buffer.writeln('      limit: limit,');
  buffer.writeln('      offset: offset,');
  buffer.writeln(
    '      include: include != null ? (dynamic qb) => include(qb as \$${className}Query) : (_) => <IncludeBuilder>[],',
  );
  buffer.writeln('      through: through,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();
}
