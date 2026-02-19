part of '../run.dart';

/// Format Dart and JS/JSON/MD (dart format + Prettier)
Future<void> cmdFormat(Directory root) async {
  cmdlog('Formatting with Prettier...');
  final (prettierExec, prettierArgs) = _findPrettier(root);
  if (prettierExec != null) {
    final res = await Process.run(
      prettierExec,
      [
        ...prettierArgs,
        '--write',
        '**/*.{js,json,md}',
        '--ignore-path',
        '.prettierignore',
      ],
      workingDirectory: root.path,
      runInShell: true,
    );
    if (res.exitCode != 0) stdout.write(res.stdout);
  } else {
    cmdlog('Prettier not found; run npm install at root if needed.');
  }

  cmdlog('Formatting Dart...');
  final dartRes = await Process.run(
    'dart',
    ['format', '.'],
    workingDirectory: root.path,
    runInShell: true,
  );
  if (dartRes.exitCode != 0) {
    stderr.write(dartRes.stderr);
    exit(dartRes.exitCode);
  }
  cmdlog('Format complete.');
}
