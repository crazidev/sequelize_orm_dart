part of '../run.dart';

/// Watch model files and run build_runner (example/)
Future<void> cmdWatchModels(Directory root) async {
  cmdlog('Model generator watch – press Ctrl+C to stop');
  final exampleDir = Directory('${root.path}/example');
  final proc = await Process.start(
    'dart',
    ['run', 'build_runner', 'watch', '--delete-conflicting-outputs'],
    workingDirectory: exampleDir.path,
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
  exit(await proc.exitCode);
}
