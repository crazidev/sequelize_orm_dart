import 'enums.dart';

class ModelAttributes {
  final String name;
  final DataType type;
  final dynamic defaultValue;
  final bool? notNull;
  final bool? primaryKey;
  final bool? autoIncrement;

  const ModelAttributes({
    required this.name,
    required this.type,
    this.notNull,
    this.defaultValue,
    this.primaryKey,
    this.autoIncrement,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'notNull': notNull,
      'primaryKey': primaryKey,
      'autoIncrement': autoIncrement,
    };
  }
}
