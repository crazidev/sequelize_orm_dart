part of '../../sequelize_model_generator.dart';

List<_AssociationInfo> _getAssociations(ClassElement element) {
  final associations = <_AssociationInfo>[];
  const hasOneChecker = TypeChecker.fromUrl(
    'package:sequelize_dart_annotations/src/has_one.dart#HasOne',
  );
  const hasManyChecker = TypeChecker.fromUrl(
    'package:sequelize_dart_annotations/src/has_many.dart#HasMany',
  );

  for (var field in element.fields) {
    if (hasOneChecker.hasAnnotationOfExact(field)) {
      final annotation = hasOneChecker.firstAnnotationOfExact(field);
      if (annotation != null) {
        final reader = ConstantReader(annotation);
        // Read the model type from the positional parameter
        final modelType = reader.read('model').typeValue;
        final modelClassName = _getModelClassName(modelType);
        final fieldName = field.name ?? 'unknown_field';
        final foreignKey = reader.peek('foreignKey')?.stringValue;
        final as = reader.peek('as')?.stringValue;
        final sourceKey = reader.peek('sourceKey')?.stringValue;

        associations.add(
          _AssociationInfo(
            associationType: 'hasOne',
            modelClassName: modelClassName,
            fieldName: fieldName,
            foreignKey: foreignKey,
            as: as,
            sourceKey: sourceKey,
          ),
        );
      }
    } else if (hasManyChecker.hasAnnotationOfExact(field)) {
      final annotation = hasManyChecker.firstAnnotationOfExact(field);
      if (annotation != null) {
        final reader = ConstantReader(annotation);
        // Read the model type from the positional parameter
        final modelType = reader.read('model').typeValue;
        final modelClassName = _getModelClassName(modelType);
        final fieldName = field.name ?? 'unknown_field';
        final foreignKey = reader.peek('foreignKey')?.stringValue;
        final as = reader.peek('as')?.stringValue;
        final sourceKey = reader.peek('sourceKey')?.stringValue;

        associations.add(
          _AssociationInfo(
            associationType: 'hasMany',
            modelClassName: modelClassName,
            fieldName: fieldName,
            foreignKey: foreignKey,
            as: as,
            sourceKey: sourceKey,
          ),
        );
      }
    }
  }
  return associations;
}
