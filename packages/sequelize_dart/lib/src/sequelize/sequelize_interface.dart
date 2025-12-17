import 'package:sequelize_dart/sequelize_dart.dart';

abstract class SequelizeInterface {
  SequelizeInterface createInstance(SequelizeCoreOptions input);

  Future<void> authenticate();

  /// Initialize Sequelize with models
  ///
  /// This method properly sequences the initialization:
  /// 1. Waits for bridge connection
  /// 2. Defines all models in the bridge (awaited)
  /// 3. Sets up all associations (awaited)
  Future<void> initialize({required List<Model> models});

  void define(
    String name,
    Map<String, Map<String, dynamic>> attributes,
    Map<String, dynamic> options,
  );

  void addModels(List<Model> models);

  Future<void> close();
}
