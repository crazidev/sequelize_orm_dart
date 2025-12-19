part of '../../sequelize_model_generator.dart';

void _generateDefineMethod(
  StringBuffer buffer,
  String generatedClassName,
  List<_AssociationInfo> associations,
) {
  buffer.writeln('  @override');
  buffer.writeln(
    '  $generatedClassName define(String modelName, Object sequelize) {',
  );
  buffer.writeln('    super.define(modelName, sequelize);');
  // Note: associateModel() is now called by Sequelize.initialize()
  // after all models are defined, so we don't call it here
  buffer.writeln('    return this;');
  buffer.writeln('  }');
  buffer.writeln();
}
