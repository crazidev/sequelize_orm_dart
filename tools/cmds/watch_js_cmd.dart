part of '../run.dart';

/// Watch Dart files and recompile to JS. When bridge changes, rebuild bridge then dart2js.
Future<void> cmdWatchJs(Directory root) async {
  final watchDirs = ['example/lib', 'packages'];
  const bridgeDir = 'packages/sequelize_orm/js/src';
  final bridgeBundle = File(
    '${root.path}/packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
  );

  cmdlog('Running initial build...');
  await cmdBuild(root, []);
  cmdlog('Ready – watching Dart and bridge (Ctrl+C to stop)');

  var lastDartHash = _fileHash(root, watchDirs, '.dart');
  var lastBridgeHash = _fileHash(root, [bridgeDir], '.ts');
  var lastBundleHash = _singleFileHash(bridgeBundle);

  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));

    final dartHash = _fileHash(root, watchDirs, '.dart');
    final bridgeTsHash = _fileHash(root, [bridgeDir], '.ts');
    final bundleHash = _singleFileHash(bridgeBundle);

    final bridgeChanged =
        (bridgeTsHash != lastBridgeHash || bundleHash != lastBundleHash);
    final dartChanged = dartHash != lastDartHash;

    if (bridgeChanged) {
      lastBridgeHash = bridgeTsHash;
      lastBundleHash = bundleHash;
      lastDartHash = dartHash;
      cmdlog('Bridge change detected, rebuilding bridge then dart2js...');
      await cmdSetupBridge(root, ['--skip-install', '--skip-cleanup']);
      await cmdBuild(root, []);
      cmdlog('Ready');
    } else if (dartChanged) {
      lastDartHash = dartHash;
      cmdlog('Dart/model change detected, rebuilding...');
      await cmdBuild(root, []);
      cmdlog('Ready');
    }
  }
}
