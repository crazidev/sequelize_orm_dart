part of '../run.dart';

/// Install and build bridge server bundle. Options: [bun|pnpm|npm], --skip-install, --skip-cleanup
Future<void> cmdSetupBridge(Directory root, List<String> args) async {
  String pm = 'bun';
  bool skipInstall = false;
  bool skipCleanup = false;
  for (final a in args) {
    if (a == 'bun' || a == 'pnpm' || a == 'npm') pm = a;
    if (a == '--skip-install') skipInstall = true;
    if (a == '--skip-cleanup') skipCleanup = true;
  }

  final bridgeDir = Directory('${root.path}/packages/sequelize_orm/js');
  if (!await bridgeDir.exists()) {
    throw StateError('Bridge directory not found: ${bridgeDir.path}');
  }

  if (!skipInstall) {
    cmdlog('Installing bridge dependencies with $pm...');
    final res = await Process.run(
      pm,
      ['install'],
      workingDirectory: bridgeDir.path,
      runInShell: true,
    );
    if (res.exitCode != 0) {
      stderr.write(res.stderr);
      exit(res.exitCode);
    }
    cmdlog('Dependencies installed.');
  }

  cmdlog('Building bridge bundle...');
  final res = await Process.run(
    pm,
    ['run', 'build'],
    workingDirectory: bridgeDir.path,
    runInShell: true,
  );
  if (res.exitCode != 0) {
    stdout.write(res.stdout);
    stderr.write(res.stderr);
    exit(res.exitCode);
  }

  final bundle = File(
    '${root.path}/packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js',
  );
  if (!await bundle.exists()) {
    throw StateError('Bridge bundle was not created.');
  }

  if (!skipCleanup && !skipInstall) {
    final nodeModules = Directory('${bridgeDir.path}/node_modules');
    if (await nodeModules.exists()) {
      cmdlog('Cleaning up node_modules...');
      await nodeModules.delete(recursive: true);
    }
  }

  cmdlog('Bridge setup complete.');
}
