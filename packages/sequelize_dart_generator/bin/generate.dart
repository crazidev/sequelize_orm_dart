import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:sequelize_dart_generator/src/generator_naming_config.dart';
import 'package:sequelize_dart_generator/src/sequelize_model_generator.dart'
    show generateSequelizeModelStandalone;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

const _tableChecker = TypeChecker.fromUrl(
  'package:sequelize_dart/src/annotations/table.dart#Table',
);

void main(List<String> args) async {
  final parsed = _parseArgs(args);
  if (parsed.showHelp) {
    stdout.writeln(_helpText());
    exit(0);
  }

  final packageRoot = _findNearestPubspecDir(
    parsed.packageRoot ?? Directory.current.path,
  );
  if (packageRoot == null) {
    stderr.writeln('No pubspec.yaml found. Run from a Dart package folder.');
    exit(2);
  }

  final sequelizeOrmConfig = _readSequelizeOrmConfig(packageRoot);

  if (parsed.server) {
    await _runServer(packageRoot);
    return;
  }

  if (parsed.registry) {
    final ok = await _generateRegistries(
      packageRoot: packageRoot,
      registryRelPaths: null,
      quiet: false,
    );
    exit(ok ? 0 : 1);
  }

  if (parsed.seed) {
    final exitCode = await _runSeedCommand(
      packageRoot: packageRoot,
      sequelizeOrmConfig: sequelizeOrmConfig,
      url: parsed.url,
      databaseName: parsed.databaseName,
      dialect: parsed.dialect,
      alter: parsed.alter ?? true,
      force: parsed.force ?? false,
    );
    exit(exitCode);
  }

  final collection = _createCollection(packageRoot);

  final inputs = <String>[];
  if (parsed.input != null) {
    inputs.add(_toAbsolutePath(packageRoot, parsed.input!));
  } else if (parsed.folder != null) {
    final folderAbs = _toAbsolutePath(packageRoot, parsed.folder!);
    inputs.addAll(_findModelFiles(folderAbs));
  } else {
    // Default to pubspec config (sequelize_orm.models_path), falling back to lib/models.
    final modelsFolderRel =
        sequelizeOrmConfig.modelsPath ?? p.join('lib', 'models');
    final folderAbs = _toAbsolutePath(packageRoot, modelsFolderRel);
    inputs.addAll(_findModelFiles(folderAbs));
  }

  if (inputs.isEmpty) {
    stdout.writeln('No *.model.dart files found.');
    exit(0);
  }

  var failures = 0;
  for (final inputPath in inputs) {
    final ok = await _generateOne(
      collection: collection,
      packageRoot: packageRoot,
      inputPath: inputPath,
      outputPathOverride: parsed.output,
    );
    if (!ok) failures++;
  }

  exit(failures == 0 ? 0 : 1);
}

_DbProfile? _selectDbProfile({
  required _SequelizeOrmConfig sequelizeOrmConfig,
  required String? databaseName,
}) {
  if (databaseName != null && databaseName.trim().isNotEmpty) {
    return sequelizeOrmConfig.databases[databaseName.trim()];
  }
  if (sequelizeOrmConfig.database != null) return sequelizeOrmConfig.database;
  if (sequelizeOrmConfig.databases.containsKey('default')) {
    return sequelizeOrmConfig.databases['default'];
  }
  return null;
}

AnalysisContextCollection _createCollection(String packageRoot) {
  return AnalysisContextCollection(
    includedPaths: [packageRoot],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
}

Future<void> _runServer(String packageRoot) async {
  stdout.writeln(jsonEncode({'event': 'ready'}));

  await stdin.transform(utf8.decoder).transform(const LineSplitter()).asyncMap((
    line,
  ) async {
    if (line.trim().isEmpty) return;
    Object? msg;
    try {
      msg = jsonDecode(line);
    } catch (e) {
      stdout.writeln(jsonEncode({'event': 'error', 'message': 'Invalid JSON'}));
      return;
    }
    if (msg is! Map<String, dynamic>) {
      stdout.writeln(
        jsonEncode({'event': 'error', 'message': 'Invalid message'}),
      );
      return;
    }

    final cmd = msg['cmd'];
    if (cmd == 'shutdown') {
      stdout.writeln(jsonEncode({'event': 'shutdown'}));
      exit(0);
    }

    if (cmd == 'generate') {
      // Create a fresh collection per request to avoid stale analyzer caches
      // in long-running server mode.
      final collection = _createCollection(packageRoot);

      final input = msg['input'] as String?;
      final folder = msg['folder'] as String?;
      final output = msg['output'] as String?;

      if (input == null && folder == null) {
        stdout.writeln(
          jsonEncode({
            'event': 'result',
            'ok': false,
            'message': 'Missing input/folder',
          }),
        );
        return;
      }

      final generated = <String>[];
      var okAll = true;

      if (input != null) {
        final inputAbs = _toAbsolutePath(packageRoot, input);
        final outAbs = output != null
            ? _toAbsolutePath(packageRoot, output)
            : null;
        final ok = await _generateOne(
          collection: collection,
          packageRoot: packageRoot,
          inputPath: inputAbs,
          outputPathOverride: outAbs,
          quiet: true,
        );
        okAll = okAll && ok;
        if (ok) generated.add(outAbs ?? _defaultOutputPathForInput(inputAbs));
      } else if (folder != null) {
        final folderAbs = _toAbsolutePath(packageRoot, folder);
        for (final inputAbs in _findModelFiles(folderAbs)) {
          final ok = await _generateOne(
            collection: collection,
            packageRoot: packageRoot,
            inputPath: inputAbs,
            outputPathOverride: null,
            quiet: true,
          );
          okAll = okAll && ok;
          if (ok) generated.add(_defaultOutputPathForInput(inputAbs));
        }
      }

      stdout.writeln(
        jsonEncode({
          'event': 'result',
          'ok': okAll,
          'generated': generated,
        }),
      );
      return;
    }

    if (cmd == 'registry') {
      final List<dynamic>? filesDyn = msg['files'] as List<dynamic>?;
      final files = (filesDyn == null)
          ? null
          : filesDyn.whereType<String>().toList();

      final ok = await _generateRegistries(
        packageRoot: packageRoot,
        registryRelPaths: files,
        quiet: true,
      );

      stdout.writeln(
        jsonEncode({
          'event': 'result',
          'ok': ok,
        }),
      );
      return;
    }

    stdout.writeln(jsonEncode({'event': 'error', 'message': 'Unknown cmd'}));
  }).drain<void>();
}

Future<bool> _generateRegistries({
  required String packageRoot,
  required List<String>? registryRelPaths,
  required bool quiet,
}) async {
  final packageName = _readPackageName(packageRoot);
  if (packageName == null) {
    stderr.writeln('Failed to read package name from pubspec.yaml');
    return false;
  }

  final registryFilesAbs = (registryRelPaths != null)
      ? registryRelPaths
            .map((r) => _toAbsolutePath(packageRoot, r))
            .where((p) => p.endsWith('.registry.dart'))
            .toList()
      : _findRegistryFiles(packageRoot);

  if (registryFilesAbs.isEmpty) {
    if (!quiet) stdout.writeln('No *.registry.dart files found.');
    return true;
  }

  final models = await _scanModelsForRegistry(packageRoot, packageName);
  if (models.isEmpty) {
    if (!quiet) stdout.writeln('No @Table models found under lib/.');
  }

  var okAll = true;
  for (final registryAbs in registryFilesAbs) {
    final outAbs = registryAbs.replaceFirst(
      RegExp(r'\.registry\.dart$'),
      '.dart',
    );
    final baseName = p.basename(registryAbs).replaceAll('.registry.dart', '');
    final className = _capitalizeFirst(baseName);

    final content = _generateRegistryDart(
      models: models,
      registryClassName: className,
    );

    try {
      await File(outAbs).writeAsString(content);
      if (!quiet) {
        stdout.writeln(
          'Generated ${p.basename(outAbs)} from ${p.basename(registryAbs)}',
        );
      }
    } catch (e) {
      okAll = false;
      stderr.writeln('Failed to write registry: $outAbs');
      stderr.writeln(e);
    }
  }

  return okAll;
}

Future<bool> _generateSeedersRegistryFileAtPath({
  required String packageRoot,
  required String packageName,
  required String seedersRelPath,
  required bool quiet,
}) async {
  final seedersDirAbs = _toAbsolutePath(packageRoot, seedersRelPath);
  final seedersDir = Directory(seedersDirAbs);
  if (!seedersDir.existsSync()) {
    if (!quiet) {
      stdout.writeln('No seeders directory found: $seedersRelPath');
    }
    return true;
  }

  final seeders = await _scanSeedersForRegistry(
    packageRoot,
    packageName,
    seedersDirAbs,
  );
  seeders.sort((a, b) => a.className.compareTo(b.className));

  final outAbs = p.join(seedersDirAbs, 'seeders.dart');
  final content = _generateSeedersRegistryDart(
    seeders: seeders,
    registryClassName: 'Seeders',
    packageName: packageName,
  );

  try {
    await File(outAbs).writeAsString(content);
    if (!quiet) {
      stdout.writeln('Generated ${p.basename(outAbs)}');
    }
    return true;
  } catch (e) {
    stderr.writeln('Failed to write seeders registry: $outAbs');
    stderr.writeln(e);
    return false;
  }
}

Future<List<_SeederInfo>> _scanSeedersForRegistry(
  String packageRoot,
  String packageName,
  String seedersDirAbs,
) async {
  final files = _findSeederFiles(seedersDirAbs);
  if (files.isEmpty) return const [];

  final collection = _createCollection(packageRoot);
  final infos = <_SeederInfo>[];

  for (final fileAbs in files) {
    try {
      final context = collection.contextFor(fileAbs);
      final result = context.currentSession.getParsedUnit(fileAbs);
      if (result is! ParsedUnitResult) continue;

      final importPath = _importPathFromLib(packageRoot, fileAbs);
      if (importPath == null) continue;

      for (final d in result.unit.declarations) {
        if (d is! ClassDeclaration) continue;
        final extendsClause = d.extendsClause;
        if (extendsClause == null) continue;

        final superType = extendsClause.superclass;
        final typeName = _typeNameLexeme(superType);
        if (typeName == null) continue;

        // Allow `SequelizeSeeding` or `prefix.SequelizeSeeding`
        if (!typeName.endsWith('SequelizeSeeding')) continue;

        infos.add(
          _SeederInfo(
            className: d.name.lexeme,
            importPath: importPath,
            packageName: packageName,
          ),
        );
      }
    } catch (_) {
      // Skip unreadable/unparseable files
    }
  }

  // De-dup in case multiple classes per file or parse quirks.
  final byKey = <String, _SeederInfo>{};
  for (final s in infos) {
    byKey['${s.importPath}::${s.className}'] = s;
  }
  return byKey.values.toList();
}

String? _typeNameLexeme(NamedType t) {
  // analyzer changed identifier fields across versions; handle both.
  try {
    final dyn = t as dynamic;
    final name2 = dyn.name2;
    if (name2 != null) {
      return (name2 as dynamic).lexeme as String?;
    }
  } catch (_) {}
  try {
    final dyn = t as dynamic;
    final name = dyn.name;
    if (name != null) {
      return (name as dynamic).lexeme as String?;
    }
  } catch (_) {}
  return null;
}

List<String> _findSeederFiles(String folderAbs) {
  final root = Directory(folderAbs);
  if (!root.existsSync()) return const [];

  return root
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .map((f) => f.path)
      .where((p) => p.endsWith('.seeder.dart'))
      .toList()
    ..sort();
}

String _generateSeedersRegistryDart({
  required List<_SeederInfo> seeders,
  required String registryClassName,
  required String packageName,
}) {
  final buffer = StringBuffer();

  for (final s in seeders) {
    buffer.writeln("import 'package:$packageName/${s.importPath}.dart';");
  }
  buffer.writeln();
  buffer.writeln("import 'package:sequelize_dart/sequelize_dart.dart';");
  buffer.writeln();

  buffer.writeln('/// Registry class for accessing all seeders');
  buffer.writeln('class $registryClassName {');
  buffer.writeln('  $registryClassName._();');
  buffer.writeln();
  buffer.writeln('  static List<SequelizeSeeding> all() {');
  buffer.writeln('    return [');
  for (final s in seeders) {
    buffer.writeln('      ${s.className}(),');
  }
  buffer.writeln('    ];');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

class _SeederInfo {
  final String className;
  final String importPath;
  final String packageName;

  _SeederInfo({
    required this.className,
    required this.importPath,
    required this.packageName,
  });
}

Future<List<_RegistryModelInfo>> _scanModelsForRegistry(
  String packageRoot,
  String packageName,
) async {
  final libRoot = p.join(packageRoot, 'lib');
  final modelFiles = _findModelFiles(libRoot);
  if (modelFiles.isEmpty) return const [];

  final collection = _createCollection(packageRoot);
  final namingConfig = GeneratorNamingConfig.fromOptions(
    const BuilderOptions({}),
  );

  final infos = <_RegistryModelInfo>[];
  for (final inputPath in modelFiles) {
    try {
      final context = collection.contextFor(inputPath);
      final result = context.currentSession.getParsedUnit(inputPath);
      if (result is! ParsedUnitResult) continue;
      final classNames = _findTableClassNamesParsed(result.unit);
      for (final className in classNames) {
        final importPath = _importPathFromLib(packageRoot, inputPath);
        if (importPath == null) continue;
        infos.add(
          _RegistryModelInfo(
            className: className,
            generatedClassName: namingConfig.getModelClassName(className),
            packageName: packageName,
            importPath: importPath,
          ),
        );
      }
    } catch (_) {
      // Skip unreadable/unparseable files
    }
  }

  infos.sort((a, b) => a.className.compareTo(b.className));
  return infos;
}

List<String> _findTableClassNamesParsed(CompilationUnit unit) {
  final names = <String>[];
  for (final d in unit.declarations) {
    if (d is! ClassDeclaration) continue;
    final meta = d.metadata;
    if (meta.isEmpty) continue;
    final hasTable = meta.any((a) => _annotationEndsWithName(a, 'Table'));
    if (!hasTable) continue;
    names.add(d.name.lexeme);
  }
  return names;
}

bool _annotationEndsWithName(Annotation a, String name) {
  final id = a.name;
  if (id is PrefixedIdentifier) return id.identifier.name == name;
  if (id is SimpleIdentifier) return id.name == name;
  // Fallback: try text.
  final src = a.name.toSource();
  return src == name || src.endsWith('.$name');
}

String? _importPathFromLib(String packageRoot, String absModelFile) {
  final libDir = p.join(packageRoot, 'lib');
  final rel = p.relative(absModelFile, from: libDir);
  if (rel.startsWith('..')) return null;
  final withoutExt = p.withoutExtension(rel);
  return withoutExt.replaceAll('\\', '/');
}

String _generateRegistryDart({
  required List<_RegistryModelInfo> models,
  required String registryClassName,
}) {
  final buffer = StringBuffer();
  for (final model in models) {
    buffer.writeln(
      "import 'package:${model.packageName}/${model.importPath}.dart';",
    );
  }
  buffer.writeln();
  buffer.writeln("import 'package:sequelize_dart/sequelize_dart.dart';");
  buffer.writeln();

  buffer.writeln('/// Registry class for accessing all models');
  buffer.writeln('class $registryClassName {');
  buffer.writeln('  $registryClassName._();');
  buffer.writeln();

  for (final model in models) {
    final getterName = _toCamelCase(model.className);
    buffer.writeln('  /// Returns the ${model.className} model instance');
    buffer.writeln(
      '  static ${model.generatedClassName} get $getterName => ${model.generatedClassName}();',
    );
    buffer.writeln();
  }

  buffer.writeln('  /// Returns a list of all model instances');
  buffer.writeln('  static List<Model> allModels() {');
  buffer.writeln('    return [');
  for (final model in models) {
    final getterName = _toCamelCase(model.className);
    buffer.writeln('      $registryClassName.$getterName,');
  }
  buffer.writeln('    ];');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

String? _readPackageName(String packageRoot) {
  final pubspec = File(p.join(packageRoot, 'pubspec.yaml'));
  if (!pubspec.existsSync()) return null;
  final lines = pubspec.readAsLinesSync();
  for (final raw in lines) {
    final line = raw.trimRight();
    if (line.trimLeft().startsWith('#')) continue;
    final m = RegExp(r'^\s*name\s*:\s*([a-zA-Z0-9_]+)\s*$').firstMatch(line);
    if (m != null) return m.group(1);
  }
  return null;
}

class _SequelizeOrmConfig {
  final String? modelsPath;
  final String? seedersPath;
  final _DbProfile? database;
  final Map<String, _DbProfile> databases;

  const _SequelizeOrmConfig({
    required this.modelsPath,
    required this.seedersPath,
    required this.database,
    required this.databases,
  });
}

class _DbProfile {
  final String? dialect;
  final String? url;

  const _DbProfile({required this.dialect, required this.url});
}

Future<int> _runSeedCommand({
  required String packageRoot,
  required _SequelizeOrmConfig sequelizeOrmConfig,
  required String? url,
  required String? databaseName,
  required String? dialect,
  required bool alter,
  required bool force,
}) async {
  final packageName = _readPackageName(packageRoot);
  if (packageName == null) {
    stderr.writeln('Failed to read package name from pubspec.yaml');
    return 2;
  }

  final selectedProfile = _selectDbProfile(
    sequelizeOrmConfig: sequelizeOrmConfig,
    databaseName: databaseName,
  );

  final resolvedUrl = (url != null && url.trim().isNotEmpty)
      ? url.trim()
      : (selectedProfile?.url ?? Platform.environment['DATABASE_URL']);
  if (resolvedUrl == null || resolvedUrl.isEmpty) {
    stderr.writeln('Missing database URL. Pass --url or set DATABASE_URL.');
    return 2;
  }

  final modelsRelPath =
      sequelizeOrmConfig.modelsPath ?? p.join('lib', 'models');
  final seedersRelPath =
      sequelizeOrmConfig.seedersPath ?? p.join('lib', 'seeders');

  // 1) Generate `Db` model registry from the configured models folder.
  final okDb = await _generateDbRegistryFromModelsPath(
    packageRoot: packageRoot,
    packageName: packageName,
    modelsRelPath: modelsRelPath,
  );
  if (!okDb) return 1;

  // 2) Generate seeders registry directly (no build_runner marker required).
  final okSeeders = await _generateSeedersRegistryFileAtPath(
    packageRoot: packageRoot,
    packageName: packageName,
    seedersRelPath: seedersRelPath,
    quiet: true,
  );
  if (!okSeeders) return 1;

  // 3) Create a temporary runner script and execute it.
  final modelsBaseDirRel = p.dirname(modelsRelPath);
  final dbFileAbs = _toAbsolutePath(
    packageRoot,
    p.join(modelsBaseDirRel, 'db.dart'),
  );
  final seedersFileAbs = _toAbsolutePath(
    packageRoot,
    p.join(seedersRelPath, 'seeders.dart'),
  );

  final dbImport = _importPathFromLib(packageRoot, dbFileAbs);
  final seedersImport = _importPathFromLib(packageRoot, seedersFileAbs);
  if (dbImport == null) {
    stderr.writeln(
      'Failed to resolve Db registry import path from: $dbFileAbs',
    );
    return 1;
  }
  if (seedersImport == null) {
    stderr.writeln(
      'Failed to resolve Seeders registry import path from: $seedersFileAbs',
    );
    return 1;
  }

  final runnerDirAbs = p.join(packageRoot, '.dart_tool', 'sequelize_orm');
  Directory(runnerDirAbs).createSync(recursive: true);
  final runnerAbs = p.join(runnerDirAbs, 'seed_runner.dart');

  await File(runnerAbs).writeAsString(
    _seedRunnerSource(
      packageName: packageName,
      dbImportPath: dbImport,
      seedersImportPath: seedersImport,
    ),
  );

  final proc = await Process.start(
    'dart',
    [
      'run',
      runnerAbs,
      '--url',
      resolvedUrl,
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
    ],
    workingDirectory: packageRoot,
    runInShell: true,
  );

  unawaited(stdout.addStream(proc.stdout));
  unawaited(stderr.addStream(proc.stderr));
  return await proc.exitCode;
}

String _seedRunnerSource({
  required String packageName,
  required String dbImportPath,
  required String seedersImportPath,
}) {
  return '''
import 'dart:io';

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:$packageName/$dbImportPath.dart';
import 'package:$packageName/$seedersImportPath.dart';

String? _valueAfter(List<String> args, String flag) {
  final idx = args.indexOf(flag);
  if (idx == -1) return null;
  if (idx + 1 >= args.length) return null;
  return args[idx + 1];
}

SequelizeCoreOptions _connectionFrom({
  required String url,
  String? dialect,
}) {
  final uri = Uri.tryParse(url);
  final scheme = (dialect ?? uri?.scheme ?? '').toLowerCase();

  // Normalize common scheme aliases.
  final normalized = switch (scheme) {
    'postgres' || 'postgresql' || 'psql' => 'postgres',
    'mysql' => 'mysql',
    'mariadb' || 'maria' => 'mariadb',
    'sqlite' => 'sqlite',
    _ => scheme,
  };

  switch (normalized) {
    case 'postgres':
      return SequelizeConnection.postgres(url: url);
    case 'mysql':
      return SequelizeConnection.mysql(url: url);
    case 'mariadb':
      return SequelizeConnection.mariadb(url: url);
    case 'sqlite':
      // Accept ':memory:' / 'sqlite::memory:' / 'sqlite:///path/to.db'
      if (url == ':memory:' || url == 'sqlite::memory:') {
        return SequelizeConnection.sqlite(storage: ':memory:');
      }
      if (uri != null && uri.path.isNotEmpty) {
        return SequelizeConnection.sqlite(storage: uri.path);
      }
      return SequelizeConnection.sqlite(storage: url);
    default:
      throw ArgumentError(
        'Unsupported dialect "\$normalized". Pass --dialect or use a URL scheme like postgresql://, mysql://, mariadb://, sqlite://',
      );
  }
}

void main(List<String> args) async {
  final url = _valueAfter(args, '--url') ?? Platform.environment['DATABASE_URL'];
  if (url == null || url.trim().isEmpty) {
    stderr.writeln('Missing database URL. Pass --url or set DATABASE_URL.');
    exit(2);
  }

  final dialect = _valueAfter(args, '--dialect');
  final alter = args.contains('--no-alter') ? false : true;
  final force = args.contains('--force');

  final sequelize = Sequelize().createInstance(
    connection: _connectionFrom(url: url.trim(), dialect: dialect),
  );

  await sequelize.initialize(models: Db.allModels());
  await sequelize.sync(alter: alter, force: force);

  final seeders = Seeders.all()
    ..sort((a, b) => a.order.compareTo(b.order));

  for (final seeder in seeders) {
    await seeder.run();
  }

  await sequelize.close();
}
''';
}

Future<bool> _generateDbRegistryFromModelsPath({
  required String packageRoot,
  required String packageName,
  required String modelsRelPath,
}) async {
  final modelsDirAbs = _toAbsolutePath(packageRoot, modelsRelPath);
  final modelFiles = _findModelFiles(modelsDirAbs);

  if (modelFiles.isEmpty) {
    stderr.writeln('No *.model.dart files found under: $modelsRelPath');
    return false;
  }

  final collection = _createCollection(packageRoot);
  final namingConfig = GeneratorNamingConfig.fromOptions(
    const BuilderOptions({}),
  );

  final models = <_RegistryModelInfo>[];
  for (final inputPath in modelFiles) {
    try {
      final context = collection.contextFor(inputPath);
      final result = context.currentSession.getParsedUnit(inputPath);
      if (result is! ParsedUnitResult) continue;

      final classNames = _findTableClassNamesParsed(result.unit);
      if (classNames.isEmpty) continue;

      final importPath = _importPathFromLib(packageRoot, inputPath);
      if (importPath == null) continue;

      for (final className in classNames) {
        models.add(
          _RegistryModelInfo(
            className: className,
            generatedClassName: namingConfig.getModelClassName(className),
            packageName: packageName,
            importPath: importPath,
          ),
        );
      }
    } catch (_) {
      // Skip
    }
  }

  if (models.isEmpty) {
    stderr.writeln('No @Table models found under: $modelsRelPath');
    return false;
  }

  models.sort((a, b) => a.className.compareTo(b.className));

  final baseDirRel = p.dirname(modelsRelPath);
  final dbOutAbs = _toAbsolutePath(packageRoot, p.join(baseDirRel, 'db.dart'));

  final content = _generateRegistryDart(
    models: models,
    registryClassName: 'Db',
  );

  try {
    await File(dbOutAbs).writeAsString(content);
    return true;
  } catch (e) {
    stderr.writeln('Failed to write Db registry: $dbOutAbs');
    stderr.writeln(e);
    return false;
  }
}

_SequelizeOrmConfig _readSequelizeOrmConfig(String packageRoot) {
  // Prefer dedicated sequelize.yaml (adjacent to pubspec), then fall back to pubspec.yaml.
  final sequelizeYaml = File(p.join(packageRoot, 'sequelize.yaml'));
  if (sequelizeYaml.existsSync()) {
    final cfg = _tryReadConfigFromSequelizeYaml(sequelizeYaml);
    if (cfg != null) return cfg;
  }

  final pubspec = File(p.join(packageRoot, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return const _SequelizeOrmConfig(
      modelsPath: null,
      seedersPath: null,
      database: null,
      databases: {},
    );
  }

  try {
    final doc = loadYaml(pubspec.readAsStringSync());
    if (doc is! YamlMap) {
      return const _SequelizeOrmConfig(
        modelsPath: null,
        seedersPath: null,
        database: null,
        databases: {},
      );
    }
    final cfg = doc['sequelize_orm'];
    if (cfg is! YamlMap) {
      return const _SequelizeOrmConfig(
        modelsPath: null,
        seedersPath: null,
        database: null,
        databases: {},
      );
    }

    String? readString(String key) {
      final v = cfg[key];
      if (v is String) return v.trim().isEmpty ? null : v.trim();
      return null;
    }

    return _SequelizeOrmConfig(
      modelsPath: readString('models_path'),
      seedersPath: readString('seeders_path'),
      database: null,
      databases: const {},
    );
  } catch (_) {
    // On parse errors, behave as if no config exists.
    return const _SequelizeOrmConfig(
      modelsPath: null,
      seedersPath: null,
      database: null,
      databases: {},
    );
  }
}

_SequelizeOrmConfig? _tryReadConfigFromSequelizeYaml(File sequelizeYaml) {
  try {
    final doc = loadYaml(sequelizeYaml.readAsStringSync());
    if (doc is! YamlMap) return null;

    String? readString(dynamic map, String key) {
      if (map is! YamlMap) return null;
      final v = map[key];
      if (v is String) return v.trim().isEmpty ? null : v.trim();
      return null;
    }

    _DbProfile? readDbProfile(dynamic map) {
      if (map is! YamlMap) return null;
      return _DbProfile(
        dialect: readString(map, 'dialect'),
        url: readString(map, 'url'),
      );
    }

    final modelsPath = readString(doc, 'models_path');
    final seedersPath = readString(doc, 'seeders_path');

    final database = readDbProfile(doc['database']);

    final dbs = <String, _DbProfile>{};
    final dbsNode = doc['databases'];
    if (dbsNode is YamlMap) {
      for (final entry in dbsNode.entries) {
        final key = entry.key;
        if (key is! String) continue;
        final prof = readDbProfile(entry.value);
        if (prof != null) dbs[key] = prof;
      }
    }

    return _SequelizeOrmConfig(
      modelsPath: modelsPath,
      seedersPath: seedersPath,
      database: database,
      databases: dbs,
    );
  } catch (_) {
    return null;
  }
}

List<String> _findRegistryFiles(String packageRoot) {
  final root = Directory(packageRoot);
  if (!root.existsSync()) return const [];
  final out = <String>[];
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final pth = entity.path;
    if (pth.endsWith('.registry.dart')) out.add(pth);
  }
  out.sort();
  return out;
}

String _toCamelCase(String input) {
  if (input.isEmpty) return input;
  return input[0].toLowerCase() + input.substring(1);
}

String _capitalizeFirst(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

class _RegistryModelInfo {
  final String className;
  final String generatedClassName;
  final String importPath;
  final String packageName;

  _RegistryModelInfo({
    required this.className,
    required this.generatedClassName,
    required this.importPath,
    required this.packageName,
  });
}

Future<bool> _generateOne({
  required AnalysisContextCollection collection,
  required String packageRoot,
  required String inputPath,
  required String? outputPathOverride,
  bool quiet = false,
}) async {
  if (!inputPath.endsWith('.model.dart')) {
    if (!quiet) {
      stderr.writeln('Skip (not a *.model.dart): $inputPath');
    }
    return true;
  }

  final context = collection.contextFor(inputPath);
  final result = await context.currentSession.getResolvedUnit(inputPath);
  if (result is! ResolvedUnitResult) {
    stderr.writeln('Failed to resolve: $inputPath');
    return false;
  }

  final unit = result.unit;
  final classDecl = _findFirstTableClass(unit);
  if (classDecl == null) {
    stderr.writeln('No @Table class found in: $inputPath');
    return false;
  }

  final classElement = classDecl.declaredFragment?.element;
  if (classElement == null) {
    stderr.writeln('No element for @Table class in: $inputPath');
    return false;
  }

  final tableAnnotation = _tableChecker.firstAnnotationOfExact(classElement);
  if (tableAnnotation == null) {
    stderr.writeln('Failed to read @Table annotation in: $inputPath');
    return false;
  }

  final initializerByName = _buildInitializerMap(classDecl);
  Future<String?> initializerSourceProvider(FieldElement field) async =>
      initializerByName[field.name];

  final generated = await generateSequelizeModelStandalone(
    element: classElement,
    annotation: ConstantReader(tableAnnotation),
    options: const BuilderOptions({}),
    initializerSourceProvider: initializerSourceProvider,
  );

  final outputPath = outputPathOverride != null
      ? _toAbsolutePath(packageRoot, outputPathOverride)
      : _defaultOutputPathForInput(inputPath);

  final outputBasename = p.basename(outputPath);
  final inputBasename = p.basename(inputPath);

  final content = _wrapAsPartOutput(
    inputBasename: inputBasename,
    generatorName: 'SequelizeModelGenerator',
    generatedBody: generated,
  );

  await File(outputPath).writeAsString(content);
  if (!quiet) {
    stdout.writeln('Generated $outputBasename from $inputBasename');
  }
  return true;
}

ClassDeclaration? _findFirstTableClass(CompilationUnit unit) {
  for (final d in unit.declarations) {
    if (d is! ClassDeclaration) continue;
    final element = d.declaredFragment?.element;
    if (element == null) continue;
    if (_tableChecker.hasAnnotationOfExact(element)) return d;
  }
  return null;
}

Map<String, String> _buildInitializerMap(ClassDeclaration classDecl) {
  final map = <String, String>{};

  for (final member in classDecl.members) {
    if (member is! FieldDeclaration) continue;
    final fields = member.fields;
    for (final variable in fields.variables) {
      final name = variable.name.lexeme;
      final init = variable.initializer?.toSource();
      if (init != null) map[name] = init;
    }
  }

  return map;
}

String _wrapAsPartOutput({
  required String inputBasename,
  required String generatorName,
  required String generatedBody,
}) {
  final buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('// dart format width=80');
  buffer.writeln();
  buffer.writeln("part of '$inputBasename';");
  buffer.writeln();
  buffer.writeln(
    '// **************************************************************************',
  );
  buffer.writeln('// $generatorName');
  buffer.writeln(
    '// **************************************************************************',
  );
  buffer.writeln();
  buffer.write(generatedBody);
  return buffer.toString();
}

List<String> _findModelFiles(String folderAbs) {
  final root = Directory(folderAbs);
  if (!root.existsSync()) return const [];

  return root
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .map((f) => f.path)
      .where((p) => p.endsWith('.model.dart'))
      .toList()
    ..sort();
}

String _defaultOutputPathForInput(String inputPath) {
  final dir = p.dirname(inputPath);
  final base = p.basename(inputPath);
  final outBase = base.replaceFirst(RegExp(r'\.model\.dart$'), '.model.g.dart');
  return p.join(dir, outBase);
}

String _toAbsolutePath(String packageRoot, String maybeRelative) {
  final normalized = maybeRelative.replaceAll('/', p.separator);
  return p.isAbsolute(normalized)
      ? normalized
      : p.normalize(p.join(packageRoot, normalized));
}

String? _findNearestPubspecDir(String startPath) {
  var current = p.isAbsolute(startPath)
      ? p.normalize(startPath)
      : p.normalize(p.join(Directory.current.path, startPath));
  final stat = FileSystemEntity.typeSync(current);
  if (stat == FileSystemEntityType.file) {
    current = p.dirname(current);
  }

  while (true) {
    final pubspec = p.join(current, 'pubspec.yaml');
    if (File(pubspec).existsSync()) return current;
    final parent = p.dirname(current);
    if (parent == current) return null;
    current = parent;
  }
}

String _helpText() => '''
Sequelize Dart Generator (standalone)

Usage:
  dart run sequelize_dart_generator:generate --input lib/models/users.model.dart
  dart run sequelize_dart_generator:generate --folder lib/models
  dart run sequelize_dart_generator:generate              # defaults to sequelize_orm.models_path (or lib/models)
  dart run sequelize_dart_generator:generate --registry
  dart run sequelize_dart_generator:generate --seed --url <DATABASE_URL>
  dart run sequelize_dart_generator:generate --server

Options:
  --package-root <path>   Package root (defaults to nearest pubspec.yaml from cwd)
  --input <path>          Single *.model.dart file (relative to package root or absolute)
  --folder <path>         Folder to scan for **/*.model.dart (relative to package root or absolute)
  --registry              Generate registries for **/*.registry.dart under the package
  --seed                  Run sync(alter/force) then execute seeders
  --url <url>             Database URL (falls back to env DATABASE_URL)
  --database <name>       Database profile name from sequelize.yaml (databases: {name: ...})
  --dialect <dialect>     Dialect override for the runner (postgres/mysql/mariadb/sqlite)
  --alter / --no-alter    Pass alter flag to sequelize.sync() (default: true)
  --force / --no-force    Pass force flag to sequelize.sync() (default: false)
  --output <path>         Output path (only applies to --input)
  --server               Run as a persistent stdio server (JSON lines)
  --help                 Show this help
''';

({
  bool showHelp,
  bool server,
  bool registry,
  bool seed,
  String? url,
  String? databaseName,
  String? dialect,
  bool? alter,
  bool? force,
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
    seed: args.contains('--seed'),
    url: valueAfter('--url'),
    databaseName: valueAfter('--database'),
    dialect: valueAfter('--dialect'),
    alter: args.contains('--alter')
        ? true
        : (args.contains('--no-alter') ? false : null),
    force: args.contains('--force')
        ? true
        : (args.contains('--no-force') ? false : null),
    packageRoot: valueAfter('--package-root'),
    input: valueAfter('--input'),
    folder: valueAfter('--folder'),
    output: valueAfter('--output'),
  );
}
