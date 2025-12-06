import 'package:sequelize_dart/sequelize_dart.dart';

abstract class SequelizeInterface {
  SequelizeInterface createInstance(
    SequelizeCoreOptions input, {
    List<Model>? models,
  });

  Future<void> authenticate();

  void define(
    String name,
    Map<String, Map<String, dynamic>> attributes,
    Map<String, dynamic> options,
  );

  void addModels(List<Model> models);

  Future<void> close();
}
