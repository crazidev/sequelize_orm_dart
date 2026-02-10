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

  final sequelizeOrmConfig = readSequelizeOrmConfig(
    packageRoot,
    loadEnvFile: true,
  );

  final exitCode = await _runSeedCommand(
    packageRoot: packageRoot,
    sequelizeOrmConfig: sequelizeOrmConfig,
    url: parsed.url,
    databaseName: parsed.databaseName,
    dialect: parsed.dialect,
    alter: parsed.alter ?? true,
    force: parsed.force ?? false,
    verbose: parsed.verbose,
  );
  exit(exitCode);
}

Future<int> _runSeedCommand({
  required String packageRoot,
  required SequelizeOrmConfig sequelizeOrmConfig,
  required String? url,
  required String? databaseName,
  required String? dialect,
  required bool alter,
  required bool force,
  required bool verbose,
}) async {
  final packageName = readPackageName(packageRoot);
  if (packageName == null) {
    stderr.writeln('Failed to read package name from pubspec.yaml');
    return 2;
  }

  final selectedProfile = selectDbProfile(
    sequelizeOrmConfig: sequelizeOrmConfig,
    databaseName: databaseName,
  );

  final hasDiscreteParams =
      selectedProfile != null &&
      (selectedProfile.host != null ||
          selectedProfile.database != null ||
          selectedProfile.user != null);

  final resolvedUrl = (url != null && url.trim().isNotEmpty)
      ? url.trim()
      : (selectedProfile?.url ?? Platform.environment['DATABASE_URL']);

  if ((resolvedUrl == null || resolvedUrl.isEmpty) && !hasDiscreteParams) {
    stderr.writeln(
      'Missing database connection info. Pass --url, set DATABASE_URL, or configure a profile in sequelize.yaml.',
    );
    return 2;
  }

  final modelsRelPath =
      sequelizeOrmConfig.modelsPath ?? p.join('lib', 'models');
  final seedersRelPath =
      sequelizeOrmConfig.seedersPath ?? p.join('lib', 'seeders');

  // 0) Generate model *.g.dart files from models_path.
  final modelsDirAbs = toAbsolutePath(packageRoot, modelsRelPath);
  final modelFilesList = findModelFiles(modelsDirAbs);
  if (modelFilesList.isEmpty) {
    stderr.writeln('No *.model.dart files found under: $modelsRelPath');
    return 1;
  }

  final collection = createCollection(packageRoot);
  for (final inputPath in modelFilesList) {
    final ok = await generateOne(
      collection: collection,
      packageRoot: packageRoot,
      inputPath: inputPath,
      outputPathOverride: null,
      quiet: true,
    );
    if (!ok) return 1;
  }

  // 1) Generate `Db` registry from the configured models folder.
  final okDb = await generateDbRegistryFromModelsPath(
    packageRoot: packageRoot,
    packageName: packageName,
    modelsRelPath: modelsRelPath,
    seedersRelPath: seedersRelPath,
    registryPathOverride: sequelizeOrmConfig.registryPath,
  );
  if (!okDb) return 1;

  // 2) Create a temporary runner script and execute it.
  final registryPath = await findRegistryPath(
    packageRoot: packageRoot,
    modelsRelPath: modelsRelPath,
    registryPathOverride: sequelizeOrmConfig.registryPath,
  );

  final dbFileAbs = toAbsolutePath(packageRoot, registryPath);
  final dbImport = importPathFromLib(packageRoot, dbFileAbs);
  if (dbImport == null) {
    stderr.writeln(
      'Failed to resolve Db registry import path from: $dbFileAbs',
    );
    return 1;
  }

  final runnerDirAbs = p.join(packageRoot, '.dart_tool', 'sequelize_orm');
  Directory(runnerDirAbs).createSync(recursive: true);
  final runnerAbs = p.join(runnerDirAbs, 'seed_runner.dart');

  await File(runnerAbs).writeAsString(
    seedRunnerSource(
      packageName: packageName,
      dbImportPath: dbImport,
    ),
  );

  final proc = await Process.start(
    'dart',
    [
      'run',
      runnerAbs,
      if (resolvedUrl != null) ...[
        '--url',
        resolvedUrl,
      ],
      if (dialect != null && dialect.trim().isNotEmpty) ...[
        '--dialect',
        dialect.trim(),
      ] else if (selectedProfile?.dialect != null &&
          selectedProfile!.dialect!.trim().isNotEmpty) ...[
        '--dialect',
        selectedProfile.dialect!.trim(),
      ],
      alter ? '--alter' : '--no-alter',
      force ? '--force' : '--no-force',
      if (verbose) '--verbose',
    ],
    workingDirectory: packageRoot,
    runInShell: true,
    environment: {
      ...Platform.environment,
      if (selectedProfile != null) ...{
        if (selectedProfile.host != null)
          'SEQUELIZE_HOST': selectedProfile.host!,
        if (selectedProfile.port != null)
          'SEQUELIZE_PORT': selectedProfile.port!.toString(),
        if (selectedProfile.database != null)
          'SEQUELIZE_DB': selectedProfile.database!,
        if (selectedProfile.user != null)
          'SEQUELIZE_USER': selectedProfile.user!,
        if (selectedProfile.pass != null)
          'SEQUELIZE_PASS': selectedProfile.pass!,
        if (selectedProfile.ssl != null)
          'SEQUELIZE_SSL': selectedProfile.ssl!.toString(),
      },
    },
  );

  await Future.wait([
    stdout.addStream(proc.stdout),
    stderr.addStream(proc.stderr),
  ]);
  return await proc.exitCode;
}

String _helpText() => '''
Sequelize Dart Seeder

Usage:
  dart run sequelize_orm_generator:seed
  dart run sequelize_orm_generator:seed --url <DATABASE_URL>
  dart run sequelize_orm_generator:seed --database dev

Options:
  --package-root <path>   Package root (defaults to nearest pubspec.yaml from cwd)
  --url <url>             Database URL (falls back to env DATABASE_URL)
  --database <name>       Database profile name from sequelize.yaml (databases: {name: ...})
  --dialect <dialect>     Dialect override for the runner (postgres/mysql/mariadb/sqlite)
  --alter / --no-alter    Pass alter flag to sequelize.sync() (default: true)
  --force / --no-force    Pass force flag to sequelize.sync() (default: false)
  --verbose / -v          Show verbose logs (SQL queries and seeder status)
  --help                  Show this help
''';

({
  bool showHelp,
  String? url,
  String? databaseName,
  String? dialect,
  bool? alter,
  bool? force,
  bool verbose,
  String? packageRoot,
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
    url: valueAfter('--url'),
    databaseName: valueAfter('--database'),
    dialect: valueAfter('--dialect'),
    alter: args.contains('--alter')
        ? true
        : (args.contains('--no-alter') ? false : null),
    force: args.contains('--force')
        ? true
        : (args.contains('--no-force') ? false : null),
    verbose: args.contains('--verbose') || args.contains('-v'),
    packageRoot: valueAfter('--package-root'),
  );
}
