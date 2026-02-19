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

import 'dart:io';

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
        await _cmdBuild(root, rest);
        break;
      case 'setup-bridge':
        await _cmdSetupBridge(root, rest);
        break;
      case 'format':
        await _cmdFormat(root);
        break;
      case 'watch-models':
        await _cmdWatchModels(root);
        break;
      case 'watch-dart':
        await _cmdWatchDart(root);
        break;
      case 'watch-js':
        await _cmdWatchJs(root);
        break;
      case 'watch-bridge':
        await _cmdWatchBridge(root);
        break;
      case 'setup-dev':
        await _cmdSetupDev(root);
        break;
      case 'setup-git-hooks':
        await _cmdSetupGitHooks(root);
        break;
      case 'test':
        await _cmdTest(root, rest);
        break;
      case 'release':
        await _cmdRelease(root, rest);
        break;
      case 'all-build':
        await _cmdAllBuild(root, rest);
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
      if (File('${root.path}/tools/run.dart').existsSync() || File('${root.path}\\tools\\run.dart').existsSync()) {
        return root;
      }
    }
  }
  // When run as dart run tools/run.dart from project root, current is the root
  return Directory.current;
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

// ---------------------------------------------------------------------------
// Build: dart compile js + Node preamble
// ---------------------------------------------------------------------------

Future<void> _cmdBuild(Directory root, List<String> args) async {
  String input = 'example/lib/main.dart';
  String outputName = 'index';
  for (final a in args) {
    if (a.startsWith('--input=')) input = a.substring(8);
    if (a.startsWith('--output=')) outputName = a.substring(9);
  }

  final buildDir = Directory('${root.path}/example/build');
  if (!await buildDir.exists()) await buildDir.create(recursive: true);

  final preamblePath = '${root.path}/packages/sequelize_orm/js/preamble.js';
  final preamble = File(preamblePath);
  if (!await preamble.exists()) {
    throw StateError('Preamble not found: $preamblePath');
  }

  _log('Compiling Dart to JS: $input');
  final tempJs = '${root.path}/example/build/_temp.js';
  final outJs = '${root.path}/example/build/$outputName.js';

  final compileResult = await Process.run(
    'dart',
    ['compile', 'js', input, '-o', tempJs],
    workingDirectory: root.path,
    runInShell: true,
  );
  if (compileResult.exitCode != 0) {
    stdout.write(compileResult.stdout);
    stderr.write(compileResult.stderr);
    exit(compileResult.exitCode);
  }

  final out = File(outJs);
  final sink = out.openWrite();
  sink.add(await preamble.readAsBytes());
  sink.add(await File(tempJs).readAsBytes());
  await sink.close();
  await File(tempJs).delete();

  _log('Build complete: example/build/$outputName.js');
}

// ---------------------------------------------------------------------------
// Setup bridge: install deps + build bundle
// ---------------------------------------------------------------------------

Future<void> _cmdSetupBridge(Directory root, List<String> args) async {
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
    _log('Installing bridge dependencies with $pm...');
    final res = await Process.run(pm, ['install'], workingDirectory: bridgeDir.path, runInShell: true);
    if (res.exitCode != 0) {
      stderr.write(res.stderr);
      exit(res.exitCode);
    }
    _log('Dependencies installed.');
  }

  _log('Building bridge bundle...');
  final res = await Process.run(pm, ['run', 'build'], workingDirectory: bridgeDir.path, runInShell: true);
  if (res.exitCode != 0) {
    stdout.write(res.stdout);
    stderr.write(res.stderr);
    exit(res.exitCode);
  }

  final bundle = File('${root.path}/packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js');
  if (!await bundle.exists()) throw StateError('Bridge bundle was not created.');

  if (!skipCleanup && !skipInstall) {
    final nodeModules = Directory('${bridgeDir.path}/node_modules');
    if (await nodeModules.exists()) {
      _log('Cleaning up node_modules...');
      await nodeModules.delete(recursive: true);
    }
  }

  _log('Bridge setup complete.');
}

// ---------------------------------------------------------------------------
// Format: dart format + Prettier
// ---------------------------------------------------------------------------

Future<void> _cmdFormat(Directory root) async {
  _log('Formatting with Prettier...');
  final (prettierExec, prettierArgs) = _findPrettier(root);
  if (prettierExec != null) {
    final res = await Process.run(
      prettierExec,
      [...prettierArgs, '--write', '**/*.{js,json,md}', '--ignore-path', '.prettierignore'],
      workingDirectory: root.path,
      runInShell: true,
    );
    if (res.exitCode != 0) stdout.write(res.stdout);
  } else {
    _log('Prettier not found; run npm install at root if needed.');
  }

  _log('Formatting Dart...');
  final dartRes = await Process.run('dart', ['format', '.'], workingDirectory: root.path, runInShell: true);
  if (dartRes.exitCode != 0) {
    stderr.write(dartRes.stderr);
    exit(dartRes.exitCode);
  }
  _log('Format complete.');
}

(String?, List<String>) _findPrettier(Directory root) {
  final local = File('${root.path}/node_modules/.bin/prettier${_binExt}');
  if (local.existsSync()) return (local.path, <String>[]);
  return ('npx', ['prettier']);
}

String get _binExt => Platform.isWindows ? '.cmd' : '';

// ---------------------------------------------------------------------------
// Watch models: build_runner watch in example
// ---------------------------------------------------------------------------

Future<void> _cmdWatchModels(Directory root) async {
  _log('Model generator watch – press Ctrl+C to stop');
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

// ---------------------------------------------------------------------------
// Watch Dart: poll and restart dart run example/lib/main.dart
// Restarts when: Dart files change (incl. *.g.dart from model rebuild), or bridge bundle changes.
// ---------------------------------------------------------------------------

Future<void> _cmdWatchDart(Directory root) async {
  final watchDirs = ['example/lib', 'packages'];
  final bridgeBundle = File('${root.path}/packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js');
  Process? proc;

  int computeHash() {
    return 0x1fffffff & (_fileHash(root, watchDirs, '.dart') + _singleFileHash(bridgeBundle));
  }

  Future<void> startServer() async {
    proc?.kill();
    _log('Starting Dart server...');
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
  _log('Watching Dart, bridge bundle, and generated models... (Ctrl+C to stop)');

  var lastHash = computeHash();
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    final h = computeHash();
    if (h != lastHash) {
      lastHash = h;
      _log('Change detected (Dart, models, or bridge), restarting server...');
      await startServer();
    }
  }
}

// ---------------------------------------------------------------------------
// Watch JS: poll and run build. When bridge changes, rebuild bridge then dart2js
// so Node (e.g. node --watch) picks up the new bundle and restarts.
// ---------------------------------------------------------------------------

Future<void> _cmdWatchJs(Directory root) async {
  final watchDirs = ['example/lib', 'packages'];
  const bridgeDir = 'packages/sequelize_orm/js/src';
  final bridgeBundle = File('${root.path}/packages/sequelize_orm/lib/src/bridge/bridge_server.bundle.js');

  _log('Running initial build...');
  await _cmdBuild(root, []);
  _log('Ready – watching Dart and bridge (Ctrl+C to stop)');

  var lastDartHash = _fileHash(root, watchDirs, '.dart');
  var lastBridgeHash = _fileHash(root, [bridgeDir], '.ts');
  var lastBundleHash = _singleFileHash(bridgeBundle);

  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));

    final dartHash = _fileHash(root, watchDirs, '.dart');
    final bridgeTsHash = _fileHash(root, [bridgeDir], '.ts');
    final bundleHash = _singleFileHash(bridgeBundle);

    final bridgeChanged = (bridgeTsHash != lastBridgeHash || bundleHash != lastBundleHash);
    final dartChanged = dartHash != lastDartHash;

    if (bridgeChanged) {
      lastBridgeHash = bridgeTsHash;
      lastBundleHash = bundleHash;
      lastDartHash = dartHash;
      _log('Bridge change detected, rebuilding bridge then dart2js...');
      await _cmdSetupBridge(root, ['--skip-install', '--skip-cleanup']);
      await _cmdBuild(root, []);
      _log('Ready');
    } else if (dartChanged) {
      lastDartHash = dartHash;
      _log('Dart/model change detected, rebuilding...');
      await _cmdBuild(root, []);
      _log('Ready');
    }
  }
}

// ---------------------------------------------------------------------------
// Watch bridge: poll TS and run setup-bridge
// ---------------------------------------------------------------------------

Future<void> _cmdWatchBridge(Directory root) async {
  const watchDir = 'packages/sequelize_orm/js/src';

  _log('Running initial bridge build...');
  await _cmdSetupBridge(root, ['--skip-cleanup']);
  _log('Ready – watching for changes (Ctrl+C to stop)');

  var lastHash = _fileHash(root, [watchDir], '.ts');
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    final h = _fileHash(root, [watchDir], '.ts');
    if (h != lastHash) {
      lastHash = h;
      _log('TypeScript change detected, rebuilding...');
      await _cmdSetupBridge(root, ['--skip-install', '--skip-cleanup']);
      _log('Ready');
    }
  }
}

int _fileHash(Directory root, List<String> relPaths, String extension) {
  int h = 0;
  for (final rel in relPaths) {
    final dir = Directory('${root.path}/$rel');
    if (!dir.existsSync()) continue;
    for (final e in dir.listSync(recursive: true)) {
      if (e is File && e.path.endsWith(extension)) {
        h = 0x1fffffff & (h * 31 + e.path.hashCode);
        try {
          h = 0x1fffffff & (h * 31 + e.lastModifiedSync().millisecondsSinceEpoch.hashCode);
        } catch (_) {}
      }
    }
  }
  return h;
}

/// Hash for a single file (path + lastModified). Returns 0 if file does not exist.
int _singleFileHash(File f) {
  if (!f.existsSync()) return 0;
  try {
    return 0x1fffffff & (f.path.hashCode * 31 + f.lastModifiedSync().millisecondsSinceEpoch.hashCode);
  } catch (_) {
    return 0;
  }
}

// ---------------------------------------------------------------------------
// Setup dev: Docker PostgreSQL (same as setup-dev.sh)
// ---------------------------------------------------------------------------

Future<void> _cmdSetupDev(Directory root) async {
  const container = 'sequelize_postgres_dev';
  _log('Checking Docker...');
  final dockerCheck = await Process.run('docker', ['info'], runInShell: true);
  if (dockerCheck.exitCode != 0) {
    stderr.writeln('Docker is not running. Start Docker and try again.');
    exit(1);
  }

  await Process.run('docker', ['stop', container], runInShell: true);
  await Process.run('docker', ['rm', container], runInShell: true);

  _log('Starting PostgreSQL container...');
  final runResult = await Process.run(
    'docker',
    [
      'run',
      '-d',
      '--name',
      container,
      '-e',
      'POSTGRES_DB=sequelize_dev',
      '-e',
      'POSTGRES_USER=dev_user',
      '-e',
      'POSTGRES_PASSWORD=dev_password',
      '-p',
      '5432:5432',
      'postgres:16-alpine',
    ],
    runInShell: true,
  );
  if (runResult.exitCode != 0) {
    stderr.write(runResult.stderr);
    exit(runResult.exitCode);
  }

  _log('Waiting for PostgreSQL...');
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(const Duration(seconds: 1));
    final ready = await Process.run(
      'docker',
      ['exec', container, 'pg_isready', '-U', 'dev_user', '-d', 'sequelize_dev'],
      runInShell: true,
    );
    if (ready.exitCode == 0) break;
    if (i == 29) {
      stderr.writeln('PostgreSQL did not become ready.');
      exit(1);
    }
  }

  final migrationsDir = Directory('${root.path}/example/migrations');
  final createSql = File('${migrationsDir.path}/create_tables_postgres.sql');
  final seedSql = File('${migrationsDir.path}/seed_data_postgres.sql');
  if (createSql.existsSync()) {
    _log('Running migrations...');
    final p = await Process.start('docker', ['exec', '-i', container, 'psql', '-U', 'dev_user', '-d', 'sequelize_dev'], runInShell: true);
    await p.stdin.addStream(createSql.openRead());
    await p.stdin.close();
    await p.exitCode;
  }
  if (seedSql.existsSync()) {
    _log('Seeding...');
    final p = await Process.start('docker', ['exec', '-i', container, 'psql', '-U', 'dev_user', '-d', 'sequelize_dev'], runInShell: true);
    await p.stdin.addStream(seedSql.openRead());
    await p.stdin.close();
    await p.exitCode;
  }

  _log('Dev environment ready. Connection: postgresql://dev_user:dev_password@localhost:5432/sequelize_dev');
}

// ---------------------------------------------------------------------------
// Setup git hooks
// ---------------------------------------------------------------------------

Future<void> _cmdSetupGitHooks(Directory root) async {
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
      _log('Installed hook: $name');
    }
  }
  _log('Git hooks setup complete.');
}

// ---------------------------------------------------------------------------
// Test: forward to tools/test.dart
// ---------------------------------------------------------------------------

Future<void> _cmdTest(Directory root, List<String> rest) async {
  final proc = await Process.start(
    'dart',
    ['run', 'tools/test.dart', ...rest],
    workingDirectory: root.path,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  exit(await proc.exitCode);
}

// ---------------------------------------------------------------------------
// Release: forward to tools/release_publish.dart
// ---------------------------------------------------------------------------

Future<void> _cmdRelease(Directory root, List<String> rest) async {
  final proc = await Process.start(
    'dart',
    ['run', 'tools/release_publish.dart', ...rest],
    workingDirectory: root.path,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  exit(await proc.exitCode);
}

// ---------------------------------------------------------------------------
// All build: setup-bridge → models → dart2js
// ---------------------------------------------------------------------------

Future<void> _cmdAllBuild(Directory root, List<String> rest) async {
  await _cmdSetupBridge(root, rest.where((a) => a.startsWith('--') || a == 'bun' || a == 'pnpm' || a == 'npm').toList());
  _log('Building models...');
  await Process.run('dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs'], workingDirectory: '${root.path}/example', runInShell: true);
  await _cmdBuild(root, []);
  _log('Full build complete.');
}

void _log(String msg) => stdout.writeln('[tools] $msg');
