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
  buffer.writeln();

  // Generate a method for each association
  for (var assoc in associations) {
    final associationName = assoc.as ?? assoc.fieldName;
    final modelClassName = assoc.modelClassName;
    final methodName = assoc.fieldName;
    final associatedColumnsClassName = '\$${modelClassName}Columns';
    final associatedIncludeHelperClassName = '\$${modelClassName}IncludeHelper';
    final singularName = assoc.singularName ?? _toCamelCase(modelClassName);
    final generateSeperate = assoc.associationType == 'hasMany';
    final pluralName = assoc.pluralName ?? modelClassName;
    final callbackName = namingConfig.getWhereCallbackName(
      singular: singularName,
      plural: pluralName,
    );
    final includeParamName = namingConfig.getIncludeCallbackName(
      singular: singularName,
      plural: pluralName,
    );

    buffer.writeln('  /// Include the `$associationName` association');
    buffer.writeln('  IncludeBuilder<$modelClassName> $methodName({');
    if (generateSeperate) buffer.writeln('    bool? separate,');
    buffer.writeln('    bool? required,');
    buffer.writeln('    bool? right,');
    buffer.writeln(
      '    QueryOperator Function($associatedColumnsClassName $callbackName)? where,',
    );
    buffer.writeln('    QueryAttributes? attributes,');
    buffer.writeln('    dynamic order,');
    buffer.writeln('    dynamic group,');
    buffer.writeln('    int? limit,');
    buffer.writeln('    int? offset,');
    buffer.writeln(
      '    List<IncludeBuilder> Function($associatedIncludeHelperClassName $includeParamName)? include,',
    );
    buffer.writeln('    Map<String, dynamic>? through,');
    buffer.writeln('    bool? duplicating,');
    buffer.writeln(
      '    QueryOperator Function($associatedColumnsClassName $callbackName)? on,',
    );
    buffer.writeln('    bool? or,');
    buffer.writeln('    bool? subQuery,');
    buffer.writeln('  }) {');
    buffer.writeln(
      '    final ${callbackName}Columns = $associatedColumnsClassName();',
    );
    buffer.writeln(
      '    final ${callbackName}IncludeHelper = const $associatedIncludeHelperClassName();',
    );
    buffer.writeln('    return IncludeBuilder<$modelClassName>(');
    buffer.writeln("      association: '$associationName',");
    buffer.writeln('      model: $modelClassName.instance,');
    if (generateSeperate) buffer.writeln('      separate: separate,');
    buffer.writeln('      required: required,');
    buffer.writeln('      right: right,');
    buffer.writeln(
      '      where: where != null ? where(${callbackName}Columns) : null,',
    );
    buffer.writeln('      attributes: attributes,');
    buffer.writeln('      order: order,');
    buffer.writeln('      group: group,');
    buffer.writeln('      limit: limit,');
    buffer.writeln('      offset: offset,');
    buffer.writeln(
      '      include: include != null ? include(${callbackName}IncludeHelper) : null,',
    );
    buffer.writeln('      through: through,');
    buffer.writeln('      duplicating: duplicating,');
    buffer.writeln(
      '      on: on != null ? on(${callbackName}Columns) : null,',
    );
    buffer.writeln('      or: or,');
    buffer.writeln('      subQuery: subQuery,');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
  }

  buffer.writeln('}');
}
