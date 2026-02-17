part of '../../sequelize_model_generator.dart';

void _generateEnums(
  StringBuffer buffer,
  String className,
  List<_FieldInfo> fields,
  GeneratorNamingConfig namingConfig,
) {
  for (var field in fields) {
    if (field.enumValues != null && field.enumValues!.isNotEmpty) {
      final enumName = _getEnumName(className, field.fieldName);

      buffer.writeln('/// Enum for ${field.fieldName} in $className');
      buffer.writeln('enum $enumName {');

      for (var i = 0; i < field.enumValues!.length; i++) {
        final value = field.enumValues![i];
        final accessorName = _sanitizeEnumAccessor(value, '');
        final isLast = i == field.enumValues!.length - 1;

        buffer.writeln("  $accessorName('$value')${isLast ? ';' : ','}");
      }

      buffer.writeln();
      buffer.writeln('  final String value;');
      buffer.writeln('  const $enumName(this.value);');
      buffer.writeln();

      buffer.writeln('  @override');
      buffer.writeln('  String toString() => value;');
      buffer.writeln();

      buffer.writeln('  static $enumName? fromValue(String? value) {');
      buffer.writeln('    if (value == null) return null;');
      buffer.writeln('    try {');
      buffer.writeln('      return $enumName.values.firstWhere(');
      buffer.writeln('        (e) => e.value == value,');
      buffer.writeln('      );');
      buffer.writeln('    } catch (_) {');
      buffer.writeln('      return null;');
      buffer.writeln('    }');
      buffer.writeln('  }');

      buffer.writeln('}');
      buffer.writeln();
    }
  }
}
