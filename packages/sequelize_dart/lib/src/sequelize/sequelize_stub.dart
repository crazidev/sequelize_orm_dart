import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/sequelize/bridge_client.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_interface.dart';

class Sequelize extends SequelizeInterface {
  @override
  Future<void> authenticate() {
    throw UnimplementedError();
  }

  @override
  SequelizeInterface createInstance(SequelizeCoreOptions input) {
    throw UnimplementedError();
  }

  @override
  Future<void> initialize({required List<Model> models}) async {
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

  /// Get the bridge client (for QueryEngine)
  BridgeClient? get bridge => null;

  /// Get a registered model by name
  Model? getModel(String name) => null;

  @override
  Future<void> close() async {}
}
