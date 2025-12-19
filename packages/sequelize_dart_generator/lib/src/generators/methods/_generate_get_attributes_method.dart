part of '../../sequelize_model_generator.dart';

void _generateGetAttributesMethod(
  StringBuffer buffer,
  List<_FieldInfo> fields,
) {
  buffer.writeln('  @override');
  buffer.writeln('  List<ModelAttributes> getAttributes() {');
  buffer.writeln('    return [');
  for (var field in fields) {
    final hasExtraProperties =
        field.autoIncrement ||
        field.primaryKey ||
        field.allowNull != null ||
        field.defaultValue != null ||
        field.validateCode != null;

    if (hasExtraProperties) {
      buffer.write('''      ModelAttributes(
        name: '${field.name}',
        type: DataType.${field.dataType},
''');
      if (field.autoIncrement) buffer.writeln('        autoIncrement: true,');
      if (field.primaryKey) buffer.writeln('        primaryKey: true,');
      if (field.allowNull != null) {
        buffer.writeln('        allowNull: ${field.allowNull},');
      }
      if (field.defaultValue != null) {
        buffer.writeln('        defaultValue: ${field.defaultValue},');
      }
      if (field.validateCode != null) {
        buffer.writeln('        validate: ${field.validateCode},');
      }
      buffer.writeln('      ),');
    } else {
      buffer.writeln(
        "      ModelAttributes(name: '${field.name}', type: DataType.${field.dataType}),",
      );
    }
  }
  buffer.writeln('    ];');
  buffer.writeln('  }');
  buffer.writeln();
}
