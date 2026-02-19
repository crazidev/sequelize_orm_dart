part of '../run.dart';

/// Watch Dart files and restart VM server. Restarts when Dart, *.g.dart, or bridge bundle change.
Future<void> cmdWatchDart(Directory root) async {
  final watchDirs = ['example/lib', 'packages'];
  final bridgeBundle = File(
    '${root.path}/packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
  );
  Process? proc;

  int computeHash() {
    return 0x1fffffff &
        (_fileHash(root, watchDirs, '.dart') + _singleFileHash(bridgeBundle));
  }

  Future<void> startServer() async {
    proc?.kill();
    cmdlog('Starting Dart server...');
    proc = await Process.start(
      'dart',
      ['run', 'example/lib/main.dart'],
      workingDirectory: root.path,
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );
    proc!.exitCode.then((_) => proc = null);
  }

  await startServer();
  cmdlog(
    'Watching Dart, bridge bundle, and generated models... (Ctrl+C to stop)',
  );

  var lastHash = computeHash();
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    final h = computeHash();
    if (h != lastHash) {
      lastHash = h;
      cmdlog('Change detected (Dart, models, or bridge), restarting server...');
      await startServer();
    }
  }
}
