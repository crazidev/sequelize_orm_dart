part of '../run.dart';

/// Watch TypeScript and rebuild bridge
Future<void> cmdWatchBridge(Directory root) async {
  const watchDir = 'packages/sequelize_orm/js/src';

  cmdlog('Running initial bridge build...');
  await cmdSetupBridge(root, ['--skip-cleanup']);
  cmdlog('Ready – watching for changes (Ctrl+C to stop)');

  var lastHash = _fileHash(root, [watchDir], '.ts');
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    final h = _fileHash(root, [watchDir], '.ts');
    if (h != lastHash) {
      lastHash = h;
      cmdlog('TypeScript change detected, rebuilding...');
      await cmdSetupBridge(root, ['--skip-install', '--skip-cleanup']);
      cmdlog('Ready');
    }
  }
}
