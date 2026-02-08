import 'dart:js_interop';

@JS('require')
external JSObject require(String module);

@JS()
external JSGlobal get globalThis;

extension type JSGlobal._(JSObject _) implements JSObject {}

// Node.js path module interop
extension type _NodePath._(JSObject _) implements JSObject {
  external String join(
    String p1, [
    String? p2,
    String? p3,
    String? p4,
    String? p5,
  ]);
  external String resolve(String path);
}

// Node.js fs module interop
extension type _NodeFs._(JSObject _) implements JSObject {
  external bool existsSync(String path);
}

// Node.js process interop
@JS('process')
external _NodeProcess get process;

extension type _NodeProcess._(JSObject _) implements JSObject {
  external String cwd();
}

/// Resolve path to the bridge bundle (works for both stdio and worker modes)
String resolveBridgeWorkerPath() {
  final path = require('path') as _NodePath;
  final fs = require('fs') as _NodeFs;
  final cwd = process.cwd();
  const bundleName = 'bridge_server.bundle.js';

  // Try possible paths relative to current working directory
  final possiblePaths = [
    // From project root: packages/sequelize_dart/js/
    path.join(
      path.join(path.join(cwd, 'packages'), 'sequelize_dart'),
      path.join('js', bundleName),
    ),
    // From example directory: ../packages/sequelize_dart/js/
    path.join(
      path.join(path.join(cwd, '..'), 'packages'),
      path.join(path.join('sequelize_dart', 'js'), bundleName),
    ),
    // Node modules style
    path.join(
      path.join(path.join(cwd, 'node_modules'), 'sequelize_dart'),
      path.join('js', bundleName),
    ),
    // Fallback to same directory
    path.join(cwd, bundleName),
  ];

  for (final p in possiblePaths) {
    if (fs.existsSync(p)) {
      return p;
    }
  }

  // Fallback to first path (will error with clear message if not found)
  return possiblePaths.first;
}
