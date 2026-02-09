part of '../../sequelize_model_generator.dart';

String _getAssociationJsonKey(String? as, String modelClassName) {
  if (as != null && as.isNotEmpty) {
    return as;
  }
  return _toCamelCase(modelClassName);
}
