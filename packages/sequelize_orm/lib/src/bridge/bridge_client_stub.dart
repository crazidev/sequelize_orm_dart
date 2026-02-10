import 'package:sequelize_orm/src/bridge/bridge_client_interface.dart';

/// Stub implementation of BridgeClient for unsupported platforms
class BridgeClient implements BridgeClientInterface {
  BridgeClient._();

  static BridgeClient? _instance;

  /// Get the singleton instance
  static BridgeClient get instance {
    _instance ??= BridgeClient._();
    return _instance!;
  }

  @override
  Future<void> start({
    required Map<String, dynamic> connectionConfig,
    String? nodePath,
    String? bridgePath,
  }) {
    throw UnimplementedError(
      'BridgeClient is not available in this environment',
    );
  }

  @override
  Future<dynamic> call(String method, Map<String, dynamic> params) {
    throw UnimplementedError(
      'BridgeClient is not available in this environment',
    );
  }

  @override
  void setLoggingCallback(Function(String sql)? callback) {
    throw UnimplementedError(
      'BridgeClient is not available in this environment',
    );
  }

  @override
  bool get isConnected => false;

  @override
  bool get isClosed => true;

  @override
  bool get isInitializing => false;

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<void> close() async {}
}
