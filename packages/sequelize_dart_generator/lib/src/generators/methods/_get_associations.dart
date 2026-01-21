part of '../../sequelize_model_generator.dart';

List<_AssociationInfo> _getAssociations(ClassElement element) {
  final associations = <_AssociationInfo>[];
  const hasOneChecker = TypeChecker.fromUrl(
    'package:sequelize_dart/src/annotations/has_one.dart#HasOne',
  );
  const hasManyChecker = TypeChecker.fromUrl(
    'package:sequelize_dart/src/annotations/has_many.dart#HasMany',
  );

  const tableChecker = TypeChecker.fromUrl(
    'package:sequelize_dart/src/annotations/table.dart#Table',
  );

  for (var field in element.fields) {
    final isHasOne = hasOneChecker.hasAnnotationOfExact(field);
    final isHasMany = hasManyChecker.hasAnnotationOfExact(field);

    if (isHasOne || isHasMany) {
      final annotation = isHasOne
          ? hasOneChecker.firstAnnotationOfExact(field)
          : hasManyChecker.firstAnnotationOfExact(field);

      if (annotation != null) {
        final reader = ConstantReader(annotation);
        final modelType = reader.read('model').typeValue;
        final modelClassName = _getModelClassName(modelType);
        final fieldName = field.name ?? 'unknown_field';
        final foreignKey = reader.peek('foreignKey')?.stringValue;
        final as = reader.peek('as')?.stringValue;
        final sourceKey = reader.peek('sourceKey')?.stringValue;

        // Try to get singular/plural names from the target model's @Table annotation
        String? singularName;
        String? pluralName;

        final modelElement = modelType.element;
        if (modelElement is ClassElement) {
          final tableAnnotation = tableChecker.firstAnnotationOf(modelElement);
          if (tableAnnotation != null) {
            final tableReader = ConstantReader(tableAnnotation);
            final nameReader = tableReader.peek('name');
            if (nameReader != null && nameReader.isNull == false) {
              singularName = nameReader.peek('singular')?.stringValue;
              pluralName = nameReader.peek('plural')?.stringValue;
            }
          }
        }

        // Fallbacks
        singularName ??= _toCamelCase(
          isHasOne ? modelClassName : (as ?? fieldName),
        );
        pluralName ??= isHasMany ? (as ?? fieldName) : modelClassName;

        associations.add(
          _AssociationInfo(
            associationType: isHasOne ? 'hasOne' : 'hasMany',
            modelClassName: modelClassName,
            fieldName: fieldName,
            foreignKey: foreignKey,
            as: as,
            sourceKey: sourceKey,
            singularName: singularName,
            pluralName: pluralName,
          ),
        );
      }
    }
  }
  return associations;
}
