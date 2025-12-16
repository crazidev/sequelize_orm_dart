import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/sequelize/bridge_client.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_interface.dart';

class Sequelize extends SequelizeInterface {
  final BridgeClient _bridge = BridgeClient.instance;
  final Map<String, Model> _models = {};

  @override
  Future<void> authenticate() async {
    // Wait for initialization to complete if still in progress
    if (_bridge.isInitializing) {
      await _bridge.waitForInitialization();
    }

    if (!_bridge.isConnected) {
      throw Exception('Not connected to database. Call createInstance first.');
    }
    // Connection is already verified during connect
  }

  @override
  SequelizeInterface createInstance(
    SequelizeCoreOptions input, {
    List<Model>? models,
  }) {
    // Convert connection options to JSON, removing logging function
    final Map<String, dynamic> config = Map<String, dynamic>.from(
      input.toJson(),
    );

    // Store the logging callback in the bridge client
    if (input.logging != null) {
      _bridge.setLoggingCallback(input.logging);
    }

    // Remove logging function (can't serialize) - just send boolean
    final logging = config['logging'].runtimeType.toString() != 'Null';
    config.remove('logging');
    config.addEntries([
      MapEntry('logging', logging),
    ]);

    // If URL is provided, remove individual connection parameters
    // Sequelize will use the URL instead
    if (input.url != null) {
      final keysToRemove = [
        'host',
        'password',
        'user',
        'database',
        'port',
        'schema',
      ];
      config.removeWhere((key, value) => keysToRemove.contains(key));
    }

    // Start bridge and connect asynchronously
    // Note: This is fire-and-forget, connection happens in background
    // Users should call authenticate() to verify connection
    _bridge
        .start(connectionConfig: config)
        .then((_) {
          // Register models after connection
          if (models != null) {
            addModels(models);
          }
        })
        .catchError((error) {
          print('[Sequelize] Failed to start bridge');
          if (error is BridgeException) {
            if (error.message.isNotEmpty) {
              print('[Sequelize] Error: ${error.message}');
            }
            if (error.code != null) {
              print('[Sequelize] Error code: ${error.code}');
            }
            if (error.stack != null && error.stack!.isNotEmpty) {
              print('[Sequelize] Stack trace:\n${error.stack}');
            }
          } else {
            print('[Sequelize] Error: ${error.toString()}');
            if (error is Error) {
              print('[Sequelize] Stack trace:\n${error.stackTrace}');
            }
          }
        });

    return this;
  }

  @override
  void addModels(List<Model> models) {
    for (final model in models) {
      // Call model.define() which sets sequelizeInstance synchronously
      // This ensures the model is properly initialized
      model.define(model.name, this);

      // Register the model with the bridge
      // Note: This is async but we can't wait here since addModels is synchronous
      // The model will be registered in the background
      _bridge
          .call('defineModel', {
            'name': model.name,
            'attributes': model.getAttributesJson(),
            'options': model.getOptionsJson(),
          })
          .then((_) {
            // Model defined successfully in bridge
          })
          .catchError((error) {
            print('[Sequelize] Failed to define model "${model.name}": $error');
          });

      _models[model.name] = model;
    }
  }

  @override
  void define(
    String name,
    Map<String, Map<String, dynamic>> attributes,
    Map<String, dynamic> options,
  ) {
    if (!_bridge.isConnected) {
      throw Exception(
        'Bridge not connected. Ensure createInstance() has completed and bridge is ready.',
      );
    }

    // Register model with bridge server asynchronously
    // Note: This is fire-and-forget, errors will be logged
    _bridge
        .call('defineModel', {
          'name': name,
          'attributes': attributes,
          'options': options,
        })
        .catchError((error) {
          print('[Sequelize] Failed to define model "$name": $error');
        });
  }

  /// Get the bridge client (for QueryEngine)
  BridgeClient get bridge => _bridge;

  /// Get a registered model by name
  Model? getModel(String name) => _models[name];

  /// Close the bridge connection
  @override
  Future<void> close() async {
    await _bridge.close();
  }
}
