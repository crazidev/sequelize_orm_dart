import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/sequelize/bridge_client.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_interface.dart';

class Sequelize extends SequelizeInterface {
  final BridgeClient _bridge = BridgeClient.instance;
  final Map<String, Model> _models = {};
  Map<String, dynamic>? _connectionConfig;

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
  SequelizeInterface createInstance(SequelizeCoreOptions input) {
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

    // Store config for later use in initialize()
    _connectionConfig = config;

    return this;
  }

  /// Initialize Sequelize with models
  ///
  /// This method properly sequences the initialization:
  /// 1. Starts the bridge and connects to the database
  /// 2. Defines all models in the bridge (awaited)
  /// 3. Sets up all associations (awaited)
  ///
  /// Example:
  /// ```dart
  /// final sequelize = Sequelize().createInstance(config);
  /// await sequelize.initialize(models: [Users.instance, Post.instance]);
  /// // Now safe to run queries
  /// ```
  @override
  Future<void> initialize({required List<Model> models}) async {
    if (_connectionConfig == null) {
      throw Exception(
        'Connection config not set. Call createInstance() first.',
      );
    }

    // Start bridge and wait for connection
    await _bridge.start(connectionConfig: _connectionConfig!);

    // Step 1: Define all models in the bridge first
    print('[Sequelize] Defining ${models.length} models...');
    for (final model in models) {
      // Set up model references synchronously
      model.define(model.name, this);
      _models[model.name] = model;

      // Define model in bridge and WAIT for completion
      await _bridge.call('defineModel', {
        'name': model.name,
        'attributes': model.getAttributesJson(),
        'options': model.getOptionsJson(),
      });
    }
    print('[Sequelize] All models defined.');

    // Step 2: Set up associations AFTER all models are defined
    print('[Sequelize] Setting up associations...');
    for (final model in models) {
      await model.associateModel();
    }
    print('[Sequelize] All associations configured.');
  }

  @override
  void addModels(List<Model> models) {
    for (final model in models) {
      // Call model.define() FIRST to set sequelizeInstance synchronously
      // This ensures the model is properly initialized before any queries
      model.define(model.name, this);
      _models[model.name] = model;

      // Then register the model with the bridge asynchronously
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
