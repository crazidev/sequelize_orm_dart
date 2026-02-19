part of '../run.dart';

/// Release/publish (forwards to tools/release_publish.dart)
Future<void> cmdRelease(Directory root, List<String> rest) async {
  final proc = await Process.start(
    'dart',
    ['run', 'tools/release_publish.dart', ...rest],
    workingDirectory: root.path,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  exit(await proc.exitCode);
}
