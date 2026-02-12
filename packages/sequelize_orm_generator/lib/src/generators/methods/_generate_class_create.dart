part of '../../sequelize_model_generator.dart';

void _generateClassCreate(
  StringBuffer buffer,
  String createClassName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations,
  GeneratorNamingConfig namingConfig,
) {
  buffer.writeln('class $createClassName {');
  // Add regular fields (omit only auto-increment fields — DB generates those)
  for (var field in fields) {
    if (!field.autoIncrement) {
      buffer.writeln('  final ${field.dartType}? ${field.fieldName};');
    }
  }

  // Add association fields
  for (var assoc in associations) {
    final modelCreateClassName = namingConfig.getModelCreateClassName(
      assoc.modelClassName,
    );
    if (assoc.associationType == 'hasOne' ||
        assoc.associationType == 'belongsTo') {
      buffer.writeln('  final $modelCreateClassName? ${assoc.fieldName};');
    } else {
      buffer.writeln(
        '  final List<$modelCreateClassName>? ${assoc.fieldName};',
      );
    }
  }

  buffer.writeln();
  buffer.writeln('  $createClassName({');
  for (var field in fields) {
    if (!field.autoIncrement) {
      buffer.writeln('    this.${field.fieldName},');
    }
  }
  for (var assoc in associations) {
    buffer.writeln('    this.${assoc.fieldName},');
  }
  buffer.writeln('  });');
  buffer.writeln();
  buffer.writeln('  Map<String, dynamic> toJson() {');
  buffer.writeln('    final result = <String, dynamic>{};');

  // Add regular fields (omit only auto-increment fields)
  for (var field in fields) {
    if (!field.autoIncrement) {
      final serializedFieldValue = _toJsonFieldValueExpression(
        field,
        valueExpression: field.fieldName,
        alreadyNonNull: true,
      );
      buffer.writeln(
        "    if (${field.fieldName} != null) result['${field.name}'] = $serializedFieldValue;",
      );
    }
  }

  // Add associations (nested in the data object for Sequelize)
  for (var assoc in associations) {
    final assocName = assoc.as ?? assoc.fieldName;
    if (assoc.associationType == 'hasOne' ||
        assoc.associationType == 'belongsTo') {
      buffer.writeln('    if (${assoc.fieldName} != null) {');
      buffer.writeln(
        '      result[\'$assocName\'] = ${assoc.fieldName}!.toJson();',
      );
      buffer.writeln('    }');
    } else {
      buffer.writeln('    if (${assoc.fieldName} != null) {');
      buffer.writeln(
        '      result[\'$assocName\'] = ${assoc.fieldName}!.map((e) => e.toJson()).toList();',
      );
      buffer.writeln('    }');
    }
  }

  buffer.writeln('    return result;');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();
}
