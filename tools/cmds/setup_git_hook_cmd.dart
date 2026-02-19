part of '../run.dart';

/// Install git hooks from .github/hooks
Future<void> cmdSetupGitHooks(Directory root) async {
  final gitDir = Directory('${root.path}/.git');
  final hooksSrc = Directory('${root.path}/.github/hooks');
  if (!gitDir.existsSync()) {
    stderr.writeln('.git not found.');
    exit(1);
  }
  if (!hooksSrc.existsSync()) {
    stderr.writeln('.github/hooks not found.');
    exit(1);
  }

  final destDir = Directory('${root.path}/.git/hooks');
  if (!destDir.existsSync()) await destDir.create(recursive: true);

  for (final f in hooksSrc.listSync()) {
    if (f is File) {
      final name = f.uri.pathSegments.last;
      final dest = File('${destDir.path}/$name');
      await dest.writeAsBytes(await f.readAsBytes());
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', dest.path], runInShell: true);
      }
      cmdlog('Installed hook: $name');
    }
  }
  cmdlog('Git hooks setup complete.');
}
