part of '../../sequelize_model_generator.dart';

void _generateGetQueryBuilderMethod(
  StringBuffer buffer,
  String className,
  GeneratorNamingConfig namingConfig,
) {
  final queryBuilderClassName = namingConfig.getModelQueryClassName(className);

  buffer.writeln('  @protected');
  buffer.writeln('  @override');
  buffer.writeln('  dynamic getQueryBuilder() {');
  buffer.writeln('    return $queryBuilderClassName();');
  buffer.writeln('  }');
  buffer.writeln();
}
