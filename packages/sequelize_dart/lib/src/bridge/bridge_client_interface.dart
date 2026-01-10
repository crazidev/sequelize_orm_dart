/// Interface for bridge clients
/// Both Dart VM (stdio) and dart2js (worker thread) implementations
/// follow this interface.
abstract class BridgeClientInterface {
  /// Start the bridge and connect to the database
  Future<void> start({
    required Map<String, dynamic> connectionConfig,
    String? nodePath,
    String? bridgePath,
  });

  /// Send a JSON-RPC request to the bridge
  Future<dynamic> call(String method, Map<String, dynamic> params);

  /// Set the logging callback to receive SQL queries
  void setLoggingCallback(Function(String sql)? callback);

  /// Check if connected to the database
  bool get isConnected;

  /// Check if the bridge is closed
  bool get isClosed;

  /// Check if the bridge is initializing
  bool get isInitializing;

  /// Wait for initialization to complete
  Future<void> waitForInitialization();

  /// Close the bridge and cleanup resources
  Future<void> close();
}
