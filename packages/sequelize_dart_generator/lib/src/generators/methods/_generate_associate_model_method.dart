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
      final modelInstanceName = '${assoc.modelClassName}.model';
      if (assoc.associationType == 'hasOne') {
        buffer.write('    await hasOne(');
      } else if (assoc.associationType == 'hasMany') {
        buffer.write('    await hasMany(');
      } else {
        buffer.write('    await belongsTo(');
      }
      buffer.write(modelInstanceName);
      if (assoc.foreignKey != null ||
          assoc.as != null ||
          assoc.sourceKey != null ||
          assoc.targetKey != null) {
        buffer.write(',');
        buffer.writeln();
        if (assoc.foreignKey != null) {
          buffer.writeln("      foreignKey: '${assoc.foreignKey}',");
        }
        if (assoc.as != null) {
          buffer.writeln("      as: '${assoc.as}',");
        }
        if (assoc.sourceKey != null && assoc.associationType != 'belongsTo') {
          buffer.writeln("      sourceKey: '${assoc.sourceKey}',");
        }
        // BelongsTo: only emit `targetKey` if it's not the default primary key
        // to avoid incompatibilities with Sequelize's auto-generated inverse
        // association (e.g. when the other side defines `hasOne/hasMany`).
        if (assoc.targetKey != null &&
            assoc.associationType == 'belongsTo' &&
            assoc.targetKey != 'id') {
          buffer.writeln("      targetKey: '${assoc.targetKey}',");
        }
        buffer.write('    ');
      }
      buffer.writeln(');');
    }
  }

  buffer.writeln('  }');
  buffer.writeln();
}
