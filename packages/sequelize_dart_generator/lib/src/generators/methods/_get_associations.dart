part of '../../sequelize_model_generator.dart';

List<_AssociationInfo> _getAssociations(ClassElement element) {
  final associations = <_AssociationInfo>[];
  const hasOneChecker = TypeChecker.fromUrl(
    'package:sequelize_dart/src/annotations/has_one.dart#HasOne',
  );
  const hasManyChecker = TypeChecker.fromUrl(
    'package:sequelize_dart/src/annotations/has_many.dart#HasMany',
  );
  const belongsToChecker = TypeChecker.fromUrl(
    'package:sequelize_dart/src/annotations/belongs_to.dart#BelongsTo',
  );

  const tableChecker = TypeChecker.fromUrl(
    'package:sequelize_dart/src/annotations/table.dart#Table',
  );

  for (var field in element.fields) {
    final isHasOne = hasOneChecker.hasAnnotationOfExact(field);
    final isHasMany = hasManyChecker.hasAnnotationOfExact(field);
    final isBelongsTo = belongsToChecker.hasAnnotationOfExact(field);

    if (isHasOne || isHasMany || isBelongsTo) {
      final annotation = isHasOne
          ? hasOneChecker.firstAnnotationOfExact(field)
          : isHasMany
          ? hasManyChecker.firstAnnotationOfExact(field)
          : belongsToChecker.firstAnnotationOfExact(field);

      if (annotation != null) {
        final reader = ConstantReader(annotation);
        final modelType = reader.read('model').typeValue;
        final modelClassName = _getModelClassName(modelType);
        final fieldName = field.name ?? 'unknown_field';
        final foreignKey = reader.peek('foreignKey')?.stringValue;
        final as = reader.peek('as')?.stringValue;
        final sourceKey = reader.peek('sourceKey')?.stringValue;
        final targetKey = reader.peek('targetKey')?.stringValue;

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
          isHasOne || isBelongsTo ? modelClassName : (as ?? fieldName),
        );
        pluralName ??= isHasMany ? (as ?? fieldName) : modelClassName;

        associations.add(
          _AssociationInfo(
            associationType: isHasOne
                ? 'hasOne'
                : isHasMany
                ? 'hasMany'
                : 'belongsTo',
            modelClassName: modelClassName,
            fieldName: fieldName,
            foreignKey: foreignKey,
            as: as,
            sourceKey: sourceKey,
            targetKey: targetKey,
            singularName: singularName,
            pluralName: pluralName,
          ),
        );
      }
    }
  }
  return associations;
}
