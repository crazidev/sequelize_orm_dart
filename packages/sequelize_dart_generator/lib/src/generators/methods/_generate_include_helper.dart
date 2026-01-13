part of '../../sequelize_model_generator.dart';

void _generateIncludeHelper(
  StringBuffer buffer,
  String className,
  List<_AssociationInfo> associations,
  GeneratorNamingConfig namingConfig,
) {
  final helperClassName = '\$${className}IncludeHelper';

  buffer.writeln('/// Type-safe include helper for $className');
  buffer.writeln('class $helperClassName {');
  buffer.writeln('  const $helperClassName();');

  // Generate a method for each association
  for (var assoc in associations) {
    final associationName = assoc.as ?? assoc.fieldName;
    final modelClassName = assoc.modelClassName;
    final methodName = assoc.fieldName;
    final colsClass = '\$${modelClassName}Columns';
    final inclClass = '\$${modelClassName}IncludeHelper';
    final generateSeparate = assoc.associationType == 'hasMany';

    buffer.writeln();
    buffer.writeln('  /// Include `$associationName`');
    buffer.write('  IncludeBuilder<$modelClassName> $methodName({');
    if (generateSeparate) buffer.write('bool? separate, ');
    buffer.writeln('bool? required, bool? right,');
    buffer.writeln(
      '    QueryOperator Function($colsClass c)? where, QueryAttributes? attributes,',
    );
    buffer.writeln(
      '    dynamic order, dynamic group, int? limit, int? offset,',
    );
    buffer.writeln(
      '    List<IncludeBuilder> Function($inclClass i)? include,',
    );
    buffer.writeln(
      '    Map<String, dynamic>? through, bool? duplicating,',
    );
    buffer.writeln(
      '    QueryOperator Function($colsClass c)? on, bool? or, bool? subQuery,',
    );
    buffer.writeln('  }) {');
    buffer.writeln('    const cols = $colsClass();');
    buffer.writeln('    const incl = $inclClass();');
    buffer.writeln('    return IncludeBuilder<$modelClassName>(');
    buffer.writeln(
      "      association: '$associationName', model: $modelClassName.instance,",
    );
    if (generateSeparate) {
      buffer.writeln(
        '      separate: separate, required: required, right: right,',
      );
    } else {
      buffer.writeln('      required: required, right: right,');
    }
    buffer.writeln(
      '      where: where != null ? where(cols) : null, attributes: attributes,',
    );
    buffer.writeln(
      '      order: order, group: group, limit: limit, offset: offset,',
    );
    buffer.writeln(
      '      include: include != null ? include(incl) : null, through: through,',
    );
    buffer.writeln(
      '      duplicating: duplicating, on: on != null ? on(cols) : null,',
    );
    buffer.writeln('      or: or, subQuery: subQuery,');
    buffer.writeln('    );');
    buffer.writeln('  }');
  }

  buffer.writeln('}');
}
