part of '../run.dart';

/// Full build: setup-bridge → models → dart2js
Future<void> cmdAllBuild(Directory root, List<String> rest) async {
  await cmdSetupBridge(
    root,
    rest
        .where(
          (a) => a.startsWith('--') || a == 'bun' || a == 'pnpm' || a == 'npm',
        )
        .toList(),
  );
  cmdlog('Building models...');
  await Process.run(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: '${root.path}/example',
    runInShell: true,
  );
  await cmdBuild(root, []);
  cmdlog('Full build complete.');
}
