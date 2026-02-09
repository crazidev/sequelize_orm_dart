export 'bridge_client_stub.dart'
    if (dart.library.js_interop) 'bridge_client_js.dart'
    if (dart.library.io) 'bridge_client_dart.dart';

// Re-export shared types
export 'bridge_client_interface.dart';
export 'bridge_exception.dart';
