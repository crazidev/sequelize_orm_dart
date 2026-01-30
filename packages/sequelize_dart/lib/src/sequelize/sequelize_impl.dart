// ignore_for_file: avoid_print

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/bridge/bridge_client.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_interface.dart';

/// Unified Sequelize implementation for both Dart VM and dart2js.
/// Both platforms now use the bridge pattern (stdio for VM, Worker Thread for JS).
class Sequelize extends SequelizeInterface {
  final BridgeClient _bridge = BridgeClient.instance;
  final Map<String, Model> _models = {};
  Map<String, dynamic>? _connectionConfig;

  @override
  Future<void> authenticate() async {
    if (_bridge.isInitializing) {
      await _bridge.waitForInitialization();
    }

    if (!_bridge.isConnected) {
      throw Exception('Not connected to database. Call createInstance first.');
    }
  }

  @override
  Sequelize createInstance({
    required SequelizeCoreOptions connection,
    Function(String sql)? logging,
    SequelizePoolOptions? pool,
  }) {
    final Map<String, dynamic> config = Map<String, dynamic>.from(
      connection.toJson(),
    );

    // Store the logging callback in the bridge client
    if (logging != null) {
      _bridge.setLoggingCallback(logging);
    }

    // Remove logging function (can't serialize) - just send boolean
    final hasLogging = logging != null;
    config.remove('logging');
    config.addEntries([MapEntry('logging', hasLogging)]);

    // Handle pool options
    if (pool != null) {
      config['pool'] = pool.toJson();
    }

    // If URL is provided, remove individual connection parameters
    if (connection.url != null) {
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

    _connectionConfig = config;
    return this;
  }

  /// Initialize Sequelize with models
  ///
  /// Start up and connect to the database, define all models, and set up all associations.
  @override
  Future<void> initialize({required List<Model> models}) async {
    if (_connectionConfig == null) {
      throw Exception(
        'Connection config not set. Call createInstance() first.',
      );
    }

    await _bridge.start(connectionConfig: _connectionConfig!);

    // print('[Sequelize] Defining ${models.length} models...');
    for (final model in models) {
      model.define(model.name, this);
      _models[model.name] = model;

      final response = await _bridge.call('defineModel', {
        'name': model.name,
        'attributes': model.$getAttributesJson(),
        'options': model.getOptionsJson(),
      });

      // Store primary keys from response
      final primaryKeys = response['primaryKeys'] as List?;
      if (primaryKeys != null) {
        model.primaryKeys = primaryKeys.cast<String>();
      }
    }
    // print('[Sequelize] All models defined.');

    // print('[Sequelize] Setting up associations...');
    for (final model in models) {
      await model.associateModel();
    }
    // print('[Sequelize] All associations configured.');
  }

  @override
  void addModels(List<Model> models) {
    for (final model in models) {
      model.define(model.name, this);
      _models[model.name] = model;

      _bridge
          .call('defineModel', {
            'name': model.name,
            'attributes': model.$getAttributesJson(),
            'options': model.getOptionsJson(),
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
        'Bridge not connected. Ensure createInstance() has completed.',
      );
    }

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

  /// Get the bridge client (for QueryEngine and Model)
  BridgeClient get bridge => _bridge;

  /// Get a registered model by name
  Model? getModel(String name) => _models[name];

  @override
  Future<void> close() async {
    await _bridge.close();
  }

  // --- SQL Expression Builders ---

  static SqlFn fn(String fn, [dynamic args]) {
    if (args == null) return SqlFn(fn);
    if (args is List) return SqlFn(fn, args);
    return SqlFn(fn, [args]);
  }

  static SqlCol col(String col) => SqlCol(col);
  static SqlLiteral literal(String val) => SqlLiteral(val);
  static SqlAttribute attribute(String attr) => SqlAttribute(attr);
  static SqlIdentifier identifier(String id) => SqlIdentifier(id);
  static SqlCast cast(dynamic expr, String type) => SqlCast(expr, type);
  static SqlRandom random() => SqlRandom();
}
