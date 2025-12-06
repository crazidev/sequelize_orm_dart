import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'sequelize_model_generator.dart';

Builder sequelizeModelBuilder(BuilderOptions options) {
  return PartBuilder(
    [SequelizeModelGenerator()],
    '.g.dart',
  );
}
