part of '../../sequelize_model_generator.dart';

void _generateClassDefinition(
  StringBuffer buffer,
  String generatedClassName,
  String? className,
) {
  buffer.writeln('class $generatedClassName extends Model {');
  buffer.writeln(
    '  static final $generatedClassName _instance = $generatedClassName._internal();',
  );
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln("  String get name => '$className';");
  buffer.writeln();
  buffer.writeln('  $generatedClassName._internal();');
  buffer.writeln();
  buffer.writeln('  factory $generatedClassName() {');
  buffer.writeln('    return _instance;');
  buffer.writeln('  }');
  buffer.writeln();
}
