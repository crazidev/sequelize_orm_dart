part of '../../sequelize_model_generator.dart';

void _generateGetQueryBuilderMethod(
  StringBuffer buffer,
  String className,
) {
  final queryBuilderClassName = '\$${className}Query';

  buffer.writeln('  @override');
  buffer.writeln('  dynamic getQueryBuilder() {');
  buffer.writeln('    return $queryBuilderClassName();');
  buffer.writeln('  }');
  buffer.writeln();
}
