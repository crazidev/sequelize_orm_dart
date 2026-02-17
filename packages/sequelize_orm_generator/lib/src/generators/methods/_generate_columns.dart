part of '../../sequelize_model_generator.dart';

void _generateColumns(
  StringBuffer buffer,
  String className,
  List<_FieldInfo> fields,
  GeneratorNamingConfig namingConfig,
) {
  final columnsClassName = namingConfig.getModelColumnsClassName(className);

  buffer.writeln('/// Type-safe columns for $className');
  buffer.writeln(
    '/// Contains only column references for use in where clauses',
  );
  buffer.writeln('class $columnsClassName {');
  buffer.writeln('  const $columnsClassName();');
  buffer.writeln();

  // Generate column references
  for (var field in fields) {
    final typeExpression = _getDataTypeExpression(field);

    final baseType = field.dataType.contains('(')
        ? field.dataType.split('(')[0]
        : field.dataType;
    final isJson = baseType == 'JSON' || baseType == 'JSONB';
    final isEnum = baseType == 'ENUM';

    if (isJson) {
      final jsonTypeParam = (field.jsonDartTypeHint != null &&
              field.jsonDartTypeHint!.startsWith('List<'))
          ? field.jsonDartTypeHint!
          : 'dynamic';
      buffer.writeln(
        "  final ${field.fieldName} = const JsonColumn<$jsonTypeParam>('${field.name}', $typeExpression);",
      );
    } else if (isEnum) {
      final enumClassName = '_$className${_capitalize(field.fieldName)}Enum';
      buffer.writeln(
        '  static final _${field.fieldName} = $enumClassName();',
      );
      buffer.writeln(
        '  $enumClassName get ${field.fieldName} => _${field.fieldName};',
      );
    } else {
      final dartType = _getDartTypeForQuery(field.dataType,
          jsonDartTypeHint: field.jsonDartTypeHint);
      buffer.writeln(
        "  final ${field.fieldName} = const Column<$dartType>('${field.name}', $typeExpression);",
      );
    }
  }

  buffer.writeln('}');
  buffer.writeln();

  // Generate enum wrapper classes
  for (var field in fields) {
    if (field.enumValues != null && field.enumValues!.isNotEmpty) {
      final enumClassName = '_$className${_capitalize(field.fieldName)}Enum';
      final conditionClassName =
          '${className}${_capitalize(field.fieldName)}EnumCondition';
      final dartEnumName = _getEnumName(className, field.fieldName);
      final typeExpression = _getDataTypeExpression(field);

      final hasPrefix =
          field.enumPrefix != null && field.enumPrefix!.isNotEmpty;
      final hasOpposite =
          field.enumOpposite != null && field.enumOpposite!.isNotEmpty;

      buffer.writeln('/// Enum column wrapper for ${field.fieldName}');
      buffer.writeln('class $enumClassName {');
      buffer.writeln(
        "  final Column<String> _column = Column<String>('${field.name}', $typeExpression);",
      );
      buffer.writeln();

      // Standard operators
      buffer.writeln('  /// Equals operator');
      buffer.writeln(
          '  $conditionClassName get eq => $conditionClassName(_column);');
      buffer.writeln();
      buffer.writeln('  /// Not equals operator');
      buffer.writeln(
          '  $conditionClassName get not => $conditionClassName(_column, true);');
      buffer.writeln();

      // Null checks as functions
      buffer.writeln('  /// Is null operator');
      buffer.writeln('  QueryOperator isNull() => _column.isNull();');
      buffer.writeln('  /// Is not null operator');
      buffer.writeln('  QueryOperator isNotNull() => _column.isNotNull();');
      buffer.writeln();

      // Prefix shortcuts (e.g. isActive, notActive)
      if (hasPrefix || hasOpposite) {
        for (var enumValue in field.enumValues!) {
          if (hasPrefix) {
            final accessorName =
                _sanitizeEnumAccessor(enumValue, field.enumPrefix!);
            buffer.writeln(
                '  /// Shortcut for eq.${_sanitizeIdentifier(_toCamelCase(enumValue))}');
            buffer.writeln(
                '  QueryOperator get $accessorName => eq.${_sanitizeIdentifier(_toCamelCase(enumValue))};');
          }
          if (hasOpposite) {
            final accessorName =
                _sanitizeEnumAccessor(enumValue, field.enumOpposite!);
            buffer.writeln(
                '  /// Shortcut for not.${_sanitizeIdentifier(_toCamelCase(enumValue))}');
            buffer.writeln(
                '  QueryOperator get $accessorName => not.${_sanitizeIdentifier(_toCamelCase(enumValue))};');
          }
        }
      }

      buffer.writeln('}');
      buffer.writeln();

      // Condition class (Public name, no leading underscore)
      buffer.writeln('class $conditionClassName {');
      buffer.writeln('  final Column<String> _column;');
      buffer.writeln('  final bool _not;');
      buffer
          .writeln('  $conditionClassName(this._column, [this._not = false]);');
      buffer.writeln();

      buffer.writeln('  /// Type-safe comparison with enum values or null');
      buffer.writeln('  QueryOperator call(dynamic value) {');
      buffer.writeln(
          '    if (value == null) return _not ? _column.isNotNull() : _column.isNull();');
      buffer.writeln(
          '    if (value is $dartEnumName) return _not ? _column.ne(value.value) : _column.eq(value.value);');
      buffer.writeln(
          '    if (value is String) return _not ? _column.ne(value) : _column.eq(value);');
      buffer.writeln(
          '    throw ArgumentError(\'Expected $dartEnumName, String or null\');');
      buffer.writeln('  }');
      buffer.writeln();

      // Enum value properties inside grouper (raw names)
      for (var enumValue in field.enumValues!) {
        final accessorName = _sanitizeIdentifier(_toCamelCase(enumValue));
        buffer.writeln('  /// Property access for $accessorName');
        buffer.writeln(
            '  QueryOperator get $accessorName => _not ? _column.ne(\'$enumValue\') : _column.eq(\'$enumValue\');');
      }

      buffer.writeln('}');
      buffer.writeln();
    }
  }
}
