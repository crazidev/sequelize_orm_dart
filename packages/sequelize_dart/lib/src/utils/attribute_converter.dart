import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';

/// Utility class for converting ColumnDefinition to JSON format for Sequelize
class AttributeConverter {
  /// Converts a list of ColumnDefinition to a JSON map for Sequelize
  static Map<String, Map<String, dynamic>> convertAttributesToJson(
    List<ColumnDefinition> attributes,
  ) {
    final map = <String, Map<String, dynamic>>{};

    for (var item in attributes) {
      final attr = <String, dynamic>{'type': item.type.name};

      // Column name
      if (item.columnName != null) attr['columnName'] = item.columnName;

      // Null constraint
      if (item.allowNull != null) attr['allowNull'] = item.allowNull;

      // Primary key and auto increment
      if (item.primaryKey != null) attr['primaryKey'] = item.primaryKey;
      if (item.autoIncrement != null) {
        attr['autoIncrement'] = item.autoIncrement;
      }
      if (item.autoIncrementIdentity != null) {
        attr['autoIncrementIdentity'] = item.autoIncrementIdentity;
      }

      // Default value
      if (item.defaultValue != null) attr['defaultValue'] = item.defaultValue;

      // Unique constraint
      if (item.unique != null) {
        if (item.unique is bool || item.unique is String) {
          attr['unique'] = item.unique;
        } else if (item.unique is UniqueOption) {
          attr['unique'] = (item.unique as UniqueOption).toJson();
        }
      }

      // Index
      if (item.index != null) {
        if (item.index is bool || item.index is String) {
          attr['index'] = item.index;
        } else if (item.index is IndexOption) {
          attr['index'] = (item.index as IndexOption).toJson();
        }
      }

      // Comment
      if (item.comment != null) attr['comment'] = item.comment;

      // Validation
      if (item.validate != null) attr['validate'] = item.validate!.toJson();

      map[item.name] = attr;
    }

    return map;
  }
}
