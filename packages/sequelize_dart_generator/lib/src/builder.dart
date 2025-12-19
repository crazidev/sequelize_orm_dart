import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sequelize_dart_generator/src/sequelize_model_generator.dart';

Builder sequelizeModelBuilder(BuilderOptions options) {
  return PartBuilder(
    [SequelizeModelGenerator()],
    '.g.dart',
  );
}
