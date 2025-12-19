part of '../../sequelize_model_generator.dart';

String _toCamelCase(String str) {
  if (str.isEmpty) return str;
  return str[0].toLowerCase() + str.substring(1);
}
