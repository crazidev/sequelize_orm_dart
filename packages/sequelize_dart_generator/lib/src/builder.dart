import 'package:build/build.dart';
import 'package:sequelize_dart_generator/src/models_registry_generator.dart';
import 'package:sequelize_dart_generator/src/sequelize_model_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder sequelizeModelBuilder(BuilderOptions options) {
  // PartBuilder processes files with 'part' directives
  // It only generates .model.g.dart files based on build_extensions in build.yaml
  return PartBuilder(
    [SequelizeModelGenerator(options)],
    '.g.dart',
  );
}

Builder modelsRegistryBuilder(BuilderOptions options) {
  return ModelsRegistryBuilder(options);
}
