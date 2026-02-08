part of '../../sequelize_model_generator.dart';

String _getModelClassName(DartType type) {
  final element = type.element;
  if (element is ClassElement) {
    return element.name ?? 'Unknown';
  }
  return type.toString().replaceAll('*', '').trim();
}
