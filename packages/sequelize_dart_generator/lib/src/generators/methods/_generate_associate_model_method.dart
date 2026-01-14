part of '../../sequelize_model_generator.dart';

void _generateAssociateModelMethod(
  StringBuffer buffer,
  String generatedClassName,
  List<_AssociationInfo> associations,
) {
  // Always generate the method with @override annotation
  buffer.writeln('  @protected');
  buffer.writeln('  @override');
  buffer.writeln('  Future<void> associateModel() async {');

  if (associations.isEmpty) {
    buffer.writeln('    // No associations defined');
  } else {
    for (var assoc in associations) {
      final modelInstanceName = '${assoc.modelClassName}.instance';
      if (assoc.associationType == 'hasOne') {
        buffer.write('    await hasOne(');
      } else {
        buffer.write('    await hasMany(');
      }
      buffer.write(modelInstanceName);
      if (assoc.foreignKey != null ||
          assoc.as != null ||
          assoc.sourceKey != null) {
        buffer.write(',');
        buffer.writeln();
        if (assoc.foreignKey != null) {
          buffer.writeln("      foreignKey: '${assoc.foreignKey}',");
        }
        if (assoc.as != null) {
          buffer.writeln("      as: '${assoc.as}',");
        }
        if (assoc.sourceKey != null) {
          buffer.writeln("      sourceKey: '${assoc.sourceKey}',");
        }
        buffer.write('    ');
      }
      buffer.writeln(');');
    }
  }

  buffer.writeln('  }');
  buffer.writeln();
}
