part of '../run.dart';

/// Compile Dart to JS (default: example/lib/main.dart → index.js).
/// Options: --input=FILE, --output=NAME
Future<void> cmdBuild(Directory root, List<String> args) async {
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

  cmdlog('Compiling Dart to JS: $input');
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

  cmdlog('Build complete: example/build/$outputName.js');
}
