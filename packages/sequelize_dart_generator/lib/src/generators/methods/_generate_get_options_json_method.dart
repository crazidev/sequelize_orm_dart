part of '../../sequelize_model_generator.dart';

void _generateGetOptionsJsonMethod(
  StringBuffer buffer,
  Map<String, dynamic> tableAnnotation,
) {
  buffer.writeln('  @protected');
  buffer.writeln('  @override');
  buffer.writeln('  Map<String, dynamic> getOptionsJson() {');
  buffer.writeln('    final table = Table(');

  // Write all optional parameters
  final optionalParams = <String, dynamic>{...tableAnnotation};

  for (final entry in optionalParams.entries) {
    final key = entry.key;
    final value = entry.value;

    if (value == null) continue;

    if (key == 'name' && value is Map) {
      buffer.writeln(
        "      name: ModelNameOption(singular: '${value['singular']}', plural: '${value['plural']}'),",
      );
    } else if (key == 'createdAt' && value is Map) {
      final enable = value['enable'];
      final columnName = value['columnName'];
      if (enable == false) {
        buffer.writeln('      createdAt: TimestampOption.disabled(),');
      } else if (columnName != null) {
        buffer.writeln(
          "      createdAt: TimestampOption.custom('$columnName'),",
        );
      } else if (enable == true) {
        buffer.writeln('      createdAt: TimestampOption.enabled(),');
      }
    } else if (key == 'deletedAt' && value is Map) {
      final enable = value['enable'];
      final columnName = value['columnName'];
      if (enable == false) {
        buffer.writeln('      deletedAt: TimestampOption.disabled(),');
      } else if (columnName != null) {
        buffer.writeln(
          "      deletedAt: TimestampOption.custom('$columnName'),",
        );
      } else if (enable == true) {
        buffer.writeln('      deletedAt: TimestampOption.enabled(),');
      }
    } else if (key == 'updatedAt' && value is Map) {
      final enable = value['enable'];
      final columnName = value['columnName'];
      if (enable == false) {
        buffer.writeln('      updatedAt: TimestampOption.disabled(),');
      } else if (columnName != null) {
        buffer.writeln(
          "      updatedAt: TimestampOption.custom('$columnName'),",
        );
      } else if (enable == true) {
        buffer.writeln('      updatedAt: TimestampOption.enabled(),');
      }
    } else if (key == 'version' && value is Map) {
      final version = value['version'];
      if (version != null) {
        buffer.writeln("      version: VersionOption.custom('$version'),");
      } else {
        buffer.writeln('      version: VersionOption.disabled(),');
      }
    } else if (value is bool) {
      buffer.writeln('      $key: $value,');
    } else if (value is String) {
      buffer.writeln("      $key: '$value',");
    }
  }

  buffer.writeln('    );');
  buffer.writeln('    return table.toJson();');
  buffer.writeln('  }');
  buffer.writeln();
}
