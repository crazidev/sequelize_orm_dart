// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:js' as js;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:sequelize_orm/src/bridge/bridge_client_interface.dart';
import 'package:sequelize_orm/src/bridge/bridge_exception.dart';
import 'package:sequelize_orm/src/core/global.dart';

/// JS interop bindings for Node.js worker_threads module
@JS('Object')
extension type _JsObject._(JSObject _) implements JSObject {
  external factory _JsObject();
}

extension type _Worker._(JSObject _) implements JSObject {
  external void postMessage(JSAny? message);
  external void on(String event, JSFunction callback);
  external void terminate();
}

extension type _WorkerThreadsModule._(JSObject _) implements JSObject {
  @JS('Worker')
  external JSFunction get workerClass;
}

/// Client for communicating with the Node.js Sequelize bridge worker thread.
/// Uses Worker Threads for dart2js environments.
class BridgeClient implements BridgeClientInterface {
  _Worker? _worker;
  final Map<int, Completer<dynamic>> _pendingRequests = {};
  int _requestId = 1;
  bool _isConnected = false;
  bool _isClosed = false;
  Completer<void>? _initializationCompleter;
  bool _isInitializing = false;
  Completer<void>? _readyCompleter;

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
    String? nodePath, // Not used in JS version
    String? bridgePath,
  }) async {
    // If already initializing, wait for it to complete
    if (_isInitializing && _initializationCompleter != null) {
      return _initializationCompleter!.future;
    }

    // If already started and connected, return immediately
    if (_worker != null && !_isClosed && _isConnected) {
      return;
    }

    // Start initialization
    _isInitializing = true;
    _initializationCompleter = Completer<void>();
    _readyCompleter = Completer<void>();

    try {
      // Import worker_threads module
      final workerThreads = require('worker_threads') as _WorkerThreadsModule;

      // Find the worker path
      final workerPath = bridgePath ?? _findBridgeWorkerPath();

      // Create worker options
      final options = _JsObject();

      // Create worker thread
      final workerConstructor = workerThreads.workerClass;
      _worker = workerConstructor
          .callAsConstructorVarArgs([workerPath.toJS, options]) as _Worker;

      _isClosed = false;

      // Listen for messages from worker
      _worker!.on(
        'message',
        js.allowInterop((data) {
          _handleResponse(data as JSAny?);
        }) as JSFunction,
      );

      // Listen for errors
      _worker!.on(
        'error',
        js.allowInterop((error) {
          print('[BridgeClient] Worker error: $error');
          _cleanup();
        }) as JSFunction,
      );

      // Listen for exit
      _worker!.on(
        'exit',
        js.allowInterop((code) {
          if (!_isClosed) {
            print(
              '[BridgeClient] Worker exited unexpectedly with code: $code',
            );
            _cleanup();
          }
        }) as JSFunction,
      );

      // Wait for ready signal
      await _readyCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout waiting for bridge worker to be ready');
        },
      );

      // Connect to database
      await _connect(connectionConfig);

      _isConnected = true;
      _isInitializing = false;
      _initializationCompleter?.complete();
      _initializationCompleter = null;
    } catch (e) {
      _isInitializing = false;
      _initializationCompleter?.completeError(e);
      _initializationCompleter = null;
      rethrow;
    }
  }

  /// Find the bridge worker path using Node.js path resolution
  String _findBridgeWorkerPath() {
    // Use the global helper that resolves path using Node.js fs and path modules
    return resolveBridgeWorkerPath();
  }

  /// Connect to the database
  Future<void> _connect(Map<String, dynamic> connectionConfig) async {
    final result = await call('connect', {'config': connectionConfig});
    // Handle both JsLinkedHashMap and regular Map
    final resultMap = Map<String, dynamic>.from(result as Map);
    if (resultMap['connected'] == true) {
      _isConnected = true;
    } else {
      throw Exception('Failed to connect to database');
    }
  }

  /// Handle a response from the bridge worker
  void _handleResponse(JSAny? data) {
    if (data == null) return;

    try {
      final response = (data as JSObject).dartify();
      if (response is! Map) return;

      final responseMap = Map<String, dynamic>.from(response);

      // Handle ready signal
      if (responseMap['id'] == 0 && responseMap['result']?['ready'] == true) {
        if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
          // Use Future.delayed to ensure proper async context in dart2js
          final completer = _readyCompleter!;
          Future.delayed(Duration.zero, () {
            completer.complete();
          });
        }
        return;
      }

      // Handle SQL log notifications
      if (responseMap['notification'] == 'sql_log') {
        final sql = responseMap['sql'] as String?;
        if (sql != null && _loggingCallback != null) {
          _loggingCallback!(sql);
        }
        return;
      }

      final id = responseMap['id'];

      if (id != null && _pendingRequests.containsKey(id)) {
        final completer = _pendingRequests.remove(id)!;
        final result = responseMap['result'];

        if (responseMap.containsKey('error')) {
          final error = responseMap['error'];
          String errorMessage = 'Unknown error';
          int? errorCode;
          String? errorStack;

          if (error is Map) {
            errorMessage = error['message'] as String? ??
                error['name'] as String? ??
                'Unknown error';
            errorCode = error['code'] as int?;
            errorStack = error['stack'] as String?;
          }

          // Use Future.delayed to ensure proper async context in dart2js
          Future.delayed(Duration.zero, () {
            completer.completeError(
              BridgeException(errorMessage, code: errorCode, stack: errorStack),
            );
          });
        } else {
          // Use Future.delayed to ensure proper async context in dart2js
          Future.delayed(Duration.zero, () {
            completer.complete(result);
          });
        }
      }
    } catch (e) {
      print('[BridgeClient] Failed to parse response: $e');
    }
  }

  @override
  Future<dynamic> call(String method, Map<String, dynamic> params) async {
    if (_isClosed) {
      throw Exception('Bridge is closed');
    }

    if (_worker == null) {
      throw Exception('Bridge is not started. Call start() first.');
    }

    final id = _requestId++;
    final request = {'id': id, 'method': method, 'params': params};

    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    // Send request to worker using postMessage (structured clone)
    _worker!.postMessage((request as Object).jsify());

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
    _worker?.terminate();
    _worker = null;
  }
}
