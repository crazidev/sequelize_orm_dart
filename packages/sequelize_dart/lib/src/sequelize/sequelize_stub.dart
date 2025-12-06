import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_interface.dart';

class Sequelize extends SequelizeInterface {
  @override
  Future<void> authenticate() {
    throw UnimplementedError();
  }

  @override
  SequelizeInterface createInstance(
    SequelizeCoreOptions input, {
    List<Model>? models,
  }) {
    throw UnimplementedError();
  }

  @override
  void addModels(List<Model> models) {}

  @override
  void define(
    String name,
    Map<String, Map<String, dynamic>> attributes,
    Map<String, dynamic> options,
  ) {}

  @override
  Future<void> close() async {
    // No-op for stub
  }
}
