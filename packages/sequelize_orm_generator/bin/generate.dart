import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sequelize_orm_generator/src/cli/cli_shared.dart';

void main(List<String> args) async {
  final parsed = _parseArgs(args);
  if (parsed.showHelp) {
    stdout.writeln(_helpText());
    exit(0);
  }

  final packageRoot = findNearestPubspecDir(
    parsed.packageRoot ?? Directory.current.path,
  );
  if (packageRoot == null) {
    stderr.writeln('No pubspec.yaml found. Run from a Dart package folder.');
    exit(2);
  }

  final sequelizeOrmConfig = readSequelizeOrmConfig(packageRoot);

  if (parsed.server) {
    await runServer(packageRoot);
    return;
  }

  if (parsed.registry) {
    final ok = await generateRegistries(
      packageRoot: packageRoot,
      registryRelPaths: null,
      quiet: false,
    );
    exit(ok ? 0 : 1);
  }

  final collection = createCollection(packageRoot);

  final inputs = <String>[];
  if (parsed.input != null) {
    inputs.add(toAbsolutePath(packageRoot, parsed.input!));
  } else if (parsed.folder != null) {
    final folderAbs = toAbsolutePath(packageRoot, parsed.folder!);
    inputs.addAll(findModelFiles(folderAbs));
  } else {
    final modelsFolderRel =
        sequelizeOrmConfig.modelsPath ?? p.join('lib', 'models');
    final folderAbs = toAbsolutePath(packageRoot, modelsFolderRel);
    inputs.addAll(findModelFiles(folderAbs));
  }

  if (inputs.isEmpty) {
    stdout.writeln('No *.model.dart files found.');
    exit(0);
  }

  var failures = 0;
  for (final inputPath in inputs) {
    final ok = await generateOne(
      collection: collection,
      packageRoot: packageRoot,
      inputPath: inputPath,
      outputPathOverride: parsed.output,
    );
    if (!ok) failures++;
  }

  if (failures != 0) {
    exit(1);
  }

  // Auto-generate Db registry from configured paths.
  final packageName = readPackageName(packageRoot);
  if (packageName == null) {
    stderr.writeln('Failed to read package name from pubspec.yaml');
    exit(2);
  }

  final modelsRelPath =
      sequelizeOrmConfig.modelsPath ?? p.join('lib', 'models');
  final seedersRelPath =
      sequelizeOrmConfig.seedersPath ?? p.join('lib', 'seeders');

  final okDb = await generateDbRegistryFromModelsPath(
    packageRoot: packageRoot,
    packageName: packageName,
    modelsRelPath: modelsRelPath,
    seedersRelPath: seedersRelPath,
    registryPathOverride: sequelizeOrmConfig.registryPath,
  );
  exit(okDb ? 0 : 1);
}

String _helpText() => '''
Sequelize Dart Generator

Usage:
  dart run sequelize_orm_generator:generate --input lib/models/users.model.dart
  dart run sequelize_orm_generator:generate --folder lib/models
  dart run sequelize_orm_generator:generate              # defaults to sequelize_orm.models_path (or lib/models)
  dart run sequelize_orm_generator:generate --registry
  dart run sequelize_orm_generator:generate --server

For seeding, use the separate seed command:
  dart run sequelize_orm_generator:seed --help

Options:
  --package-root <path>   Package root (defaults to nearest pubspec.yaml from cwd)
  --input <path>          Single *.model.dart file (relative to package root or absolute)
  --folder <path>         Folder to scan for **/*.model.dart (relative to package root or absolute)
  --registry              Generate registries for **/*.registry.dart under the package
  --output <path>         Output path (only applies to --input)
  --server                Run as a persistent stdio server (JSON lines)
  --help                  Show this help
''';

({
  bool showHelp,
  bool server,
  bool registry,
  String? packageRoot,
  String? input,
  String? folder,
  String? output,
})
_parseArgs(List<String> args) {
  String? valueAfter(String flag) {
    final idx = args.indexOf(flag);
    if (idx == -1) return null;
    if (idx + 1 >= args.length) return null;
    return args[idx + 1];
  }

  final showHelp = args.contains('--help') || args.contains('-h');
  return (
    showHelp: showHelp,
    server: args.contains('--server'),
    registry: args.contains('--registry'),
    packageRoot: valueAfter('--package-root'),
    input: valueAfter('--input'),
    folder: valueAfter('--folder'),
    output: valueAfter('--output'),
  );
}
