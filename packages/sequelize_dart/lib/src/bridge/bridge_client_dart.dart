import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sequelize_dart/src/bridge/bridge_client_interface.dart';
import 'package:sequelize_dart/src/bridge/bridge_exception.dart';
import 'package:sequelize_dart/src/bridge/sequelize_exceptions.dart';

/// Client for communicating with the Node.js Sequelize bridge server.
/// Uses stdio (stdin/stdout) for Dart VM environments.
class BridgeClient implements BridgeClientInterface {
  Process? _process;
  StreamController<String> _responseController =
      StreamController<String>.broadcast();
  final Map<int, Completer<dynamic>> _pendingRequests = {};
  int _requestId = 1;
  bool _isConnected = false;
  bool _isClosed = false;
  Completer<void>? _initializationCompleter;
  bool _isInitializing = false;

  /// Callback for SQL logging
  Function(String sql)? _loggingCallback;

  BridgeClient._();

  @override
  void setLoggingCallback(Function(String sql)? callback) {
    _loggingCallback = callback;
  }

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
  }) async {
    // If already initializing, wait for it to complete
    if (_isInitializing && _initializationCompleter != null) {
      return _initializationCompleter!.future;
    }

    // If already started and connected, return immediately
    if (_process != null && !_isClosed && _isConnected) {
      return;
    }

    // If already started but not connected, just connect
    if (_process != null && !_isClosed) {
      await _connect(connectionConfig);
      return;
    }

    // Recreate response controller if closed
    if (_isClosed) {
      _responseController = StreamController<String>.broadcast();
    }

    // Start initialization
    _isInitializing = true;
    _initializationCompleter = Completer<void>();

    // Find the bridge server path
    final serverPath = bridgePath ?? _findBridgeServerPath();

    if (!File(serverPath).existsSync()) {
      _isInitializing = false;
      _initializationCompleter?.completeError(
        Exception(
          'Bridge server not found at: $serverPath\n'
          'Make sure to run: ./tools/setup_bridge.sh to build the bundle',
        ),
      );
      _initializationCompleter = null;
      throw Exception(
        'Bridge server not found at: $serverPath\n'
        'Make sure to run: ./tools/setup_bridge.sh to build the bundle',
      );
    }

    // Collect stderr for error reporting
    final stderrBuffer = StringBuffer();
    final stderrCompleter = Completer<void>();

    // Start Node.js process
    _process = await Process.start(
      nodePath ?? _findNodePath(),
      [serverPath],
      workingDirectory: p.dirname(serverPath),
    );

    _isClosed = false;

    // Listen to stdout for responses
    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            _responseController.add(line);
            _handleResponse(line);
          },
          onError: (error) {
            // ignore: avoid_print
            print('[BridgeClient] stdout error: $error');
          },
        );

    // Listen to stderr for errors
    _process!.stderr
        .transform(utf8.decoder)
        .listen(
          (data) {
            stderrBuffer.writeln(data);
          },
          onDone: () {
            stderrCompleter.complete();
          },
          onError: (error) {
            stderrCompleter.completeError(error);
          },
        );

    // Handle process exit
    final bridgeProcess = _process;
    _process!.exitCode.then((code) {
      if (_process != bridgeProcess) return;
      if (!_isClosed && code != 0) {
        final stderr = stderrBuffer.toString();
        final errorMsg = stderr.isNotEmpty
            ? 'Bridge server exited with code $code.\nError: $stderr'
            : 'Bridge server exited with code $code';
        // ignore: avoid_print
        print('[BridgeClient] Process exited with code: $code');
        _cleanup();
        throw BridgeException(errorMsg);
      } else if (!_isClosed) {
        // ignore: avoid_print
        print('[BridgeClient] Process exited with code: $code');
        _cleanup();
      }
    });

    // Wait for ready signal with timeout
    try {
      await _waitForReady();
    } catch (e) {
      _isInitializing = false;
      _initializationCompleter?.completeError(e);
      _initializationCompleter = null;
      final stderr = stderrBuffer.toString();
      final errorMsg = stderr.isNotEmpty
          ? 'Failed to start bridge server: $e\nError output: $stderr'
          : 'Failed to start bridge server: $e';
      throw BridgeException(errorMsg);
    }

    // Connect to database
    try {
      await _connect(connectionConfig);
      _isInitializing = false;
      _initializationCompleter?.complete();
      _initializationCompleter = null;
    } catch (e) {
      _isInitializing = false;
      _initializationCompleter?.completeError(e);
      _initializationCompleter = null;
      final stderr = stderrBuffer.toString();
      if (stderr.isNotEmpty && e is BridgeException && e.message.isEmpty) {
        throw BridgeException(
          'Failed to connect to database.\nError output: $stderr',
        );
      }
      rethrow;
    }
  }

  /// Find Node.js path
  String _findNodePath() {
    // Try common Node.js paths
    final possiblePaths = [
      '/usr/local/bin/node',
      '/usr/bin/node',
      // NVM paths
      '${Platform.environment['HOME']}/.nvm/versions/node/v22.9.0/bin/node',
      '${Platform.environment['HOME']}/.nvm/versions/node/v20.0.0/bin/node',
      '${Platform.environment['HOME']}/.nvm/versions/node/v18.0.0/bin/node',
    ];

    for (final path in possiblePaths) {
      if (File(path).existsSync()) {
        return path;
      }
    }

    // Fallback to just 'node' and hope it's in PATH
    return 'node';
  }

  /// Find the bridge server path relative to the package
  String _findBridgeServerPath() {
    // Try multiple possible locations (bundled version first)
    final possiblePaths = [
      // Bundled version (preferred - no npm install needed)
      'packages/sequelize_dart/js/bridge_server.bundle.js',
      '../packages/sequelize_dart/js/bridge_server.bundle.js',
      'js/bridge_server.bundle.js',
      // Absolute path fallback for bundled version
      p.join(
        Platform.script.toFilePath(),
        '..',
        '..',
        'packages',
        'sequelize_dart',
        'js',
        'bridge_server.bundle.js',
      ),
    ];

    for (final path in possiblePaths) {
      final normalized = p.normalize(path);
      if (File(normalized).existsSync()) {
        return p.absolute(normalized);
      }
    }

    // Default fallback to bundled version
    return 'packages/sequelize_dart/js/bridge_server.bundle.js';
  }

  /// Wait for the ready signal from the bridge server
  Future<void> _waitForReady() async {
    final completer = Completer<void>();

    late StreamSubscription<String> subscription;
    subscription = _responseController.stream.listen((line) {
      try {
        final response = jsonDecode(line);
        if (response['id'] == 0 && response['result']?['ready'] == true) {
          subscription.cancel();
          completer.complete();
        }
      } catch (e) {
        // Ignore parse errors during initial wait
      }
    });

    // Timeout after 10 seconds
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription.cancel();
        throw Exception('Timeout waiting for bridge server to be ready');
      },
    );
  }

  /// Connect to the database
  Future<void> _connect(Map<String, dynamic> connectionConfig) async {
    final result = await call('connect', {'config': connectionConfig});
    if (result['connected'] == true) {
      _isConnected = true;
    } else {
      throw Exception('Failed to connect to database');
    }
  }

  /// Handle a response from the bridge server
  void _handleResponse(String line) {
    try {
      final response = jsonDecode(line);

      // Handle SQL log notifications
      if (response['notification'] == 'sql_log') {
        final sql = response['sql'] as String?;
        if (sql != null && _loggingCallback != null) {
          _loggingCallback!(sql);
        }
        return;
      }

      final id = response['id'];

      if (id != null && _pendingRequests.containsKey(id)) {
        final completer = _pendingRequests.remove(id)!;

        if (response.containsKey('error')) {
          final error = response['error'];
          String errorMessage = 'Unknown error';
          int? errorCode;
          String? errorStack;

          if (error is Map) {
            completer.completeError(
              SequelizeException.fromBridge(Map<String, dynamic>.from(error)),
            );
          } else {
            completer.completeError(
              BridgeException(error?.toString() ?? 'Unknown error'),
            );
          }
        } else {
          completer.complete(response['result']);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[BridgeClient] Failed to parse response: $e');
    }
  }

  @override
  Future<dynamic> call(String method, Map<String, dynamic> params) async {
    if (_isClosed) {
      throw Exception('Bridge is closed');
    }

    if (_process == null) {
      throw Exception('Bridge is not started. Call start() first.');
    }

    final id = _requestId++;
    final request = jsonEncode({'id': id, 'method': method, 'params': params});

    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _process!.stdin.writeln(request);

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _pendingRequests.remove(id);
        throw Exception('Request timeout: $method');
      },
    );
  }

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isClosed => _isClosed;

  @override
  bool get isInitializing => _isInitializing;

  @override
  Future<void> waitForInitialization() async {
    if (!_isInitializing) {
      return;
    }
    if (_initializationCompleter != null) {
      return _initializationCompleter!.future;
    }
  }

  /// Clean up resources
  void _cleanup() {
    _isClosed = true;
    _isConnected = false;

    for (final completer in _pendingRequests.values) {
      completer.completeError(Exception('Bridge closed'));
    }
    _pendingRequests.clear();

    _responseController.close();
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;

    try {
      await call('close', {});
    } catch (e) {
      // Ignore errors during close
    }

    _cleanup();
    _process?.kill();
    _process = null;
  }
}
