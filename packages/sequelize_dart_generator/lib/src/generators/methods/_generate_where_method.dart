part of '../../sequelize_model_generator.dart';

void _generateWhereMethod(
  StringBuffer buffer,
  String className,
  String generatedClassName,
) {
  buffer.writeln('  Map<String, dynamic>? where() {');
  buffer.writeln('    final keys = $generatedClassName().getPrimaryKeys();');
  buffer.writeln('    if (keys.isEmpty) return null;');
  buffer.writeln();
  buffer.writeln('    final json = toJson();');
  buffer.writeln('    final whereClause = <String, dynamic>{};');
  buffer.writeln('    for (final key in keys) {');
  buffer.writeln('      final value = json[key];');
  buffer.writeln('      if (value != null) {');
  buffer.writeln('        whereClause[key] = value;');
  buffer.writeln('      }');
  buffer.writeln('    }');
  buffer.writeln('    return whereClause.isEmpty ? null : whereClause;');
  buffer.writeln('  }');
  buffer.writeln();
}
