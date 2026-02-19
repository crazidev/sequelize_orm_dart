// Cross-platform tool runner for Sequelize ORM (Windows, macOS, Linux).
//
// Usage:
//   dart run tools/run.dart <command> [options]
//   dart run tools/run.dart --help
//
// Commands (each can be run individually):
//   build          Compile Dart to JS (optional: --input=, --output=)
//   setup-bridge   Install and build bridge server bundle
//   format         Format Dart and JS/JSON/MD with dart format + Prettier
//   watch-models   Watch model files and run build_runner
//   watch-dart     Watch Dart files and restart VM server
//   watch-js       Watch Dart files and recompile to JS
//   watch-bridge   Watch TypeScript and rebuild bridge
//   setup-dev      Start PostgreSQL in Docker for development
//   setup-git-hooks  Install git hooks from .github/hooks
//   test           Run tests (forwards to tools/test.dart)
//   release        Release/publish (forwards to tools/release_publish.dart)
//   all-build      Run setup-bridge, then build models, then dart2js (full build)

import 'dart:convert';
import 'dart:io';

part 'cmds/build_all_cmd.dart';
part 'cmds/build_cmd.dart';
part 'cmds/format_cmd.dart';
part 'cmds/release_cmd.dart';
part 'cmds/setup_bridge_cmd.dart';
part 'cmds/setup_dev_cmd.dart';
part 'cmds/setup_git_hook_cmd.dart';
part 'cmds/test_cmd.dart';
part 'cmds/watch_bridge_cmd.dart';
part 'cmds/watch_dart_cmd.dart';
part 'cmds/watch_js_cmd.dart';
part 'cmds/watch_models_cmd.dart';

void cmdlog(String msg) => stdout.writeln('[tools] $msg');

void main(List<String> args) async {
  final root = _projectRoot;
  Directory.current = root;

  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printHelp();
    exit(0);
  }

  final command = args.first.toLowerCase();
  final rest = args.skip(1).toList();

  try {
    switch (command) {
      case 'build':
        await cmdBuild(root, rest);
        break;
      case 'setup-bridge':
        await cmdSetupBridge(root, rest);
        break;
      case 'format':
        await cmdFormat(root);
        break;
      case 'watch-models':
        await cmdWatchModels(root);
        break;
      case 'watch-dart':
        await cmdWatchDart(root);
        break;
      case 'watch-js':
        await cmdWatchJs(root);
        break;
      case 'watch-bridge':
        await cmdWatchBridge(root);
        break;
      case 'setup-dev':
        await cmdSetupDev(root);
        break;
      case 'setup-git-hooks':
        await cmdSetupGitHooks(root);
        break;
      case 'test':
        await cmdTest(root, rest);
        break;
      case 'release':
        await cmdRelease(root, rest);
        break;
      case 'all-build':
        await cmdAllBuild(root, rest);
        break;
      default:
        stderr.writeln('Unknown command: $command');
        _printHelp();
        exit(1);
    }
  } catch (e, st) {
    stderr.writeln('Error: $e');
    stderr.writeln(st);
    exit(1);
  }
}

Directory get _projectRoot {
  final uri = Platform.script;
  String? path;
  if (uri.scheme == 'file') {
    path = uri.toFilePath();
  }
  if (path != null) {
    final script = File(path);
    if (script.existsSync()) {
      final root = script.parent.parent;
      if (File('${root.path}/tools/run.dart').existsSync() ||
          File('${root.path}\\tools\\run.dart').existsSync()) {
        return root;
      }
    }
  }
  return Directory.current;
}

(String?, List<String>) _findPrettier(Directory root) {
  final local = File('${root.path}/node_modules/.bin/prettier$_binExt');
  if (local.existsSync()) return (local.path, <String>[]);
  return ('npx', ['prettier']);
}

String get _binExt => Platform.isWindows ? '.cmd' : '';

int _fileHash(Directory root, List<String> relPaths, String extension) {
  int h = 0;
  for (final rel in relPaths) {
    final dir = Directory('${root.path}/$rel');
    if (!dir.existsSync()) continue;
    for (final e in dir.listSync(recursive: true)) {
      if (e is File && e.path.endsWith(extension)) {
        h = 0x1fffffff & (h * 31 + e.path.hashCode);
        try {
          h = 0x1fffffff &
              (h * 31 + e.lastModifiedSync().millisecondsSinceEpoch.hashCode);
        } catch (_) {}
      }
    }
  }
  return h;
}

int _singleFileHash(File f) {
  if (!f.existsSync()) return 0;
  try {
    return 0x1fffffff &
        (f.path.hashCode * 31 +
            f.lastModifiedSync().millisecondsSinceEpoch.hashCode);
  } catch (_) {
    return 0;
  }
}

void _printHelp() {
  print('''
Sequelize ORM – cross-platform tools (Windows, macOS, Linux)

Usage: dart run tools/run.dart <command> [options]

Commands:
  build            Compile Dart to JS (default: example/lib/main.dart → index.js)
                    Options: --input=FILE, --output=NAME
  setup-bridge     Install and build bridge server (bun | pnpm | npm)
                    Options: [bun|pnpm|npm], --skip-install, --skip-cleanup
  format           Format Dart + JS/JSON/MD (dart format + Prettier)
  watch-models     Watch model files, run build_runner (example/)
  watch-dart       Watch Dart files, restart VM server on change
  watch-js         Watch Dart files, recompile to JS on change
  watch-bridge     Watch TypeScript, rebuild bridge on change
  setup-dev        Start PostgreSQL in Docker for development
  setup-git-hooks  Install git hooks from .github/hooks
  test             Run tests (pass flags to tools/test.dart)
  release          Release/publish (pass flags to tools/release_publish.dart)
  all-build        Full build: setup-bridge → models → dart2js

Examples:
  dart run tools/run.dart build
  dart run tools/run.dart build --input=example/lib/benchmark.dart --output=benchmark
  dart run tools/run.dart setup-bridge pnpm
  dart run tools/run.dart watch-models
  dart run tools/run.dart test --postgres
''');
}
