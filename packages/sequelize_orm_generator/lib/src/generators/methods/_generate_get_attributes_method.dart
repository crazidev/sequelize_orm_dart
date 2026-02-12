part of '../../sequelize_model_generator.dart';

void _generateGetAttributesMethod(
  StringBuffer buffer,
  List<_FieldInfo> fields,
) {
  buffer.writeln('  @protected');
  buffer.writeln('  @override');
  buffer.writeln('  List<ColumnDefinition> \$getAttributes() {');
  buffer.writeln('    return [');
  for (var field in fields) {
    final hasExtraProperties = field.autoIncrement ||
        field.primaryKey ||
        field.allowNull != null ||
        field.defaultValue != null ||
        field.validateCode != null ||
        field.columnName != null ||
        field.comment != null ||
        field.unique != null ||
        field.index != null ||
        field.autoIncrementIdentity != null;

    if (hasExtraProperties) {
      final typeExpression = _getDataTypeExpression(field);

      buffer.write('''      ColumnDefinition(
        name: '${field.name}',
        type: $typeExpression,
''');
      if (field.autoIncrement) buffer.writeln('        autoIncrement: true,');
      if (field.primaryKey) buffer.writeln('        primaryKey: true,');
      if (field.allowNull != null) {
        buffer.writeln('        allowNull: ${field.allowNull},');
      }
      if (field.columnName != null) {
        buffer.writeln("        columnName: '${field.columnName}',");
      }
      if (field.defaultValue != null) {
        final defaultValueCode =
            field.defaultValueSource ?? _toDartLiteral(field.defaultValue);
        buffer.writeln(
          '        defaultValue: $defaultValueCode,',
        );
      }
      if (field.comment != null) {
        buffer.writeln("        comment: '${field.comment}',");
      }
      if (field.unique != null) {
        if (field.unique is bool) {
          buffer.writeln('        unique: ${field.unique},');
        } else if (field.unique is String) {
          buffer.writeln("        unique: '${field.unique}',");
        } else {
          buffer.writeln('        unique: ${field.unique},');
        }
      }
      if (field.index != null) {
        if (field.index is bool) {
          buffer.writeln('        index: ${field.index},');
        } else if (field.index is String) {
          buffer.writeln("        index: '${field.index}',");
        } else {
          buffer.writeln('        index: ${field.index},');
        }
      }
      if (field.autoIncrementIdentity != null) {
        buffer.writeln(
          '        autoIncrementIdentity: ${field.autoIncrementIdentity},',
        );
      }
      if (field.validateCode != null) {
        buffer.writeln('        validate: ${field.validateCode},');
      }
      buffer.writeln('      ),');
    } else {
      final typeExpression = _getDataTypeExpression(field);

      buffer.writeln(
        "      ColumnDefinition(name: '${field.name}', type: $typeExpression),",
      );
    }
  }
  buffer.writeln('    ];');
  buffer.writeln('  }');
  buffer.writeln();
}

String _toDartLiteral(Object? value) {
  if (value == null) return 'null';
  if (value is String) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');
    return "'$escaped'";
  }

  return value.toString();
}
