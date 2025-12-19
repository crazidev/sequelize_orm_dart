part of '../../sequelize_model_generator.dart';

void _generateGetAttributesJsonMethod(StringBuffer buffer) {
  buffer.writeln('  @override');
  buffer.writeln('  Map<String, Map<String, dynamic>> getAttributesJson() {');
  buffer.writeln(
    '    return AttributeConverter.convertAttributesToJson(getAttributes());',
  );
  buffer.writeln('  }');
  buffer.writeln();
}
