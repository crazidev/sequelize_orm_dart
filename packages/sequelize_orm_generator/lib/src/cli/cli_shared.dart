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
import 'package:sequelize_orm_generator/src/generator_naming_config.dart';
import 'package:sequelize_orm_generator/src/sequelize_model_generator.dart'
    show generateSequelizeModelStandalone;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

// ---------------------------------------------------------------------------
// Table annotation checker
// ---------------------------------------------------------------------------

const tableChecker = TypeChecker.fromUrl(
  'package:sequelize_orm/src/annotations/table.dart#Table',
);

// ---------------------------------------------------------------------------
// Environment
// ---------------------------------------------------------------------------

Map<String, String>? _env;

void loadEnv(String packageRoot, {bool quiet = false}) {
  if (_env != null) return;
  var envFile = File(p.join(packageRoot, '.env'));
  if (!envFile.existsSync()) {
    envFile = File(p.join(Directory.current.path, '.env'));
  }

  if (!envFile.existsSync()) {
    _env = {};
    return;
  }

  try {
    final lines = envFile.readAsLinesSync();
    final map = <String, String>{};
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final idx = line.indexOf('=');
      if (idx == -1) continue;
      final key = line.substring(0, idx).trim();
      var val = line.substring(idx + 1).trim();
      if (val.startsWith('"') && val.endsWith('"')) {
        val = val.substring(1, val.length - 1);
      } else if (val.startsWith("'") && val.endsWith("'")) {
        val = val.substring(1, val.length - 1);
      }
      map[key] = val;
    }
    _env = map;
    if (!quiet) {
      stdout.writeln('Loaded ${map.length} variables from ${envFile.path}');
    }
  } catch (e) {
    _env = {};
    if (!quiet) {
      stderr.writeln('Failed to read .env file: $e');
    }
  }
}

String? resolveEnv(String? value) {
  if (value == null) return null;
  if (value.startsWith('env.')) {
    final key = value.substring(4);
    return _env?[key];
  }
  return value;
}

// ---------------------------------------------------------------------------
// Config classes
// ---------------------------------------------------------------------------

class SequelizeOrmConfig {
  final String? modelsPath;
  final String? seedersPath;
  final String? registryPath;
  final DbProfile? database;
  final Map<String, DbProfile> databases;

  const SequelizeOrmConfig({
    required this.modelsPath,
    required this.seedersPath,
    required this.registryPath,
    required this.database,
    required this.databases,
  });
}

class DbProfile {
  final String? dialect;
  final String? url;
  final String? host;
  final int? port;
  final String? database;
  final String? user;
  final String? pass;
  final bool? ssl;

  const DbProfile({
    this.dialect,
    this.url,
    this.host,
    this.port,
    this.database,
    this.user,
    this.pass,
    this.ssl,
  });
}

// ---------------------------------------------------------------------------
// Config reading
// ---------------------------------------------------------------------------

/// Reads the sequelize.yaml (or pubspec.yaml fallback) configuration.
///
/// When [loadEnvFile] is `true`, a `.env` file is loaded first so that
/// `env.VAR` references in `sequelize.yaml` are resolved. The generate
/// command does not need this -- only the seed command uses database
/// connection profiles that reference environment variables.
SequelizeOrmConfig readSequelizeOrmConfig(
  String packageRoot, {
  bool loadEnvFile = false,
}) {
  if (loadEnvFile) {
    loadEnv(packageRoot);
  }

  final sequelizeYaml = File(p.join(packageRoot, 'sequelize.yaml'));
  if (sequelizeYaml.existsSync()) {
    final cfg = _tryReadConfigFromSequelizeYaml(sequelizeYaml);
    if (cfg != null) return cfg;
  }

  final pubspec = File(p.join(packageRoot, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return const SequelizeOrmConfig(
      modelsPath: null,
      seedersPath: null,
      registryPath: null,
      database: null,
      databases: {},
    );
  }

  try {
    final doc = loadYaml(pubspec.readAsStringSync());
    if (doc is! YamlMap) {
      return const SequelizeOrmConfig(
        modelsPath: null,
        seedersPath: null,
        registryPath: null,
        database: null,
        databases: {},
      );
    }
    final cfg = doc['sequelize_orm'];
    if (cfg is! YamlMap) {
      return const SequelizeOrmConfig(
        modelsPath: null,
        seedersPath: null,
        registryPath: null,
        database: null,
        databases: {},
      );
    }

    String? readString(String key) {
      final v = cfg[key];
      if (v is String) return v.trim().isEmpty ? null : resolveEnv(v.trim());
      return null;
    }

    return SequelizeOrmConfig(
      modelsPath: readString('models_path'),
      seedersPath: readString('seeders_path'),
      registryPath: readString('registry_path'),
      database: null,
      databases: const {},
    );
  } catch (_) {
    return const SequelizeOrmConfig(
      modelsPath: null,
      seedersPath: null,
      registryPath: null,
      database: null,
      databases: {},
    );
  }
}

SequelizeOrmConfig? _tryReadConfigFromSequelizeYaml(File sequelizeYaml) {
  try {
    final doc = loadYaml(sequelizeYaml.readAsStringSync());
    if (doc is! YamlMap) return null;

    String? readString(dynamic map, String key) {
      if (map is! YamlMap) return null;
      final v = map[key];
      if (v is String) return v.trim().isEmpty ? null : resolveEnv(v.trim());
      return null;
    }

    DbProfile? readDbProfile(dynamic map) {
      if (map is! YamlMap) {
        if (map is String) {
          return DbProfile(url: resolveEnv(map));
        }
        return null;
      }

      int? readInt(dynamic map, String key) {
        if (map is! YamlMap) return null;
        final v = map[key];
        if (v is int) return v;
        if (v is String) return int.tryParse(resolveEnv(v) ?? '');
        return null;
      }

      bool? readBool(dynamic map, String key) {
        if (map is! YamlMap) return null;
        final v = map[key];
        if (v is bool) return v;
        if (v is String) return resolveEnv(v) == 'true';
        return null;
      }

      return DbProfile(
        dialect: readString(map, 'dialect'),
        url: readString(map, 'url'),
        host: readString(map, 'host'),
        port: readInt(map, 'port'),
        database: readString(map, 'database'),
        user: readString(map, 'user') ?? readString(map, 'username'),
        pass: readString(map, 'pass') ?? readString(map, 'password'),
        ssl: readBool(map, 'ssl'),
      );
    }

    final modelsPath = readString(doc, 'models_path');
    final seedersPath = readString(doc, 'seeders_path');
    final registryPath = readString(doc, 'registry_path');

    final databaseNode = doc['database'] ?? doc['connection'];
    DbProfile? database;
    final dbs = <String, DbProfile>{};

    if (databaseNode is YamlMap) {
      final isSingle =
          databaseNode.containsKey('url') ||
          databaseNode.containsKey('host') ||
          databaseNode.containsKey('dialect');

      if (isSingle) {
        database = readDbProfile(databaseNode);
      } else {
        for (final entry in databaseNode.entries) {
          final key = entry.key;
          if (key is! String) continue;
          final prof = readDbProfile(entry.value);
          if (prof != null) dbs[key] = prof;
        }
      }
    } else if (databaseNode is String) {
      database = DbProfile(url: resolveEnv(databaseNode));
    }

    final dbsNode = doc['databases'];
    if (dbsNode is YamlMap) {
      for (final entry in dbsNode.entries) {
        final key = entry.key;
        if (key is! String) continue;
        final prof = readDbProfile(entry.value);
        if (prof != null) dbs[key] = prof;
      }
    }

    return SequelizeOrmConfig(
      modelsPath: modelsPath,
      seedersPath: seedersPath,
      registryPath: registryPath,
      database: database,
      databases: dbs,
    );
  } catch (_) {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Package utilities
// ---------------------------------------------------------------------------

String? readPackageName(String packageRoot) {
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

String? findNearestPubspecDir(String startPath) {
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

String toAbsolutePath(String packageRoot, String maybeRelative) {
  final normalized = maybeRelative.replaceAll('/', p.separator);
  return p.isAbsolute(normalized)
      ? normalized
      : p.normalize(p.join(packageRoot, normalized));
}

// ---------------------------------------------------------------------------
// File discovery
// ---------------------------------------------------------------------------

List<String> findModelFiles(String folderAbs) {
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

List<String> findRegistryFiles(String packageRoot) {
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

List<String> findSeederFiles(String folderAbs) {
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

// ---------------------------------------------------------------------------
// Analysis context
// ---------------------------------------------------------------------------

AnalysisContextCollection createCollection(String packageRoot) {
  return AnalysisContextCollection(
    includedPaths: [packageRoot],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
}

// ---------------------------------------------------------------------------
// AST helpers
// ---------------------------------------------------------------------------

List<String> findTableClassNamesParsed(CompilationUnit unit) {
  final names = <String>[];
  for (final d in unit.declarations) {
    if (d is! ClassDeclaration) continue;
    final meta = d.metadata;
    if (meta.isEmpty) continue;
    final hasTable = meta.any((a) => annotationEndsWithName(a, 'Table'));
    if (!hasTable) continue;
    names.add(d.name.lexeme);
  }
  return names;
}

bool annotationEndsWithName(Annotation a, String name) {
  final id = a.name;
  if (id is PrefixedIdentifier) return id.identifier.name == name;
  if (id is SimpleIdentifier) return id.name == name;
  final src = a.name.toSource();
  return src == name || src.endsWith('.$name');
}

String? typeNameLexeme(NamedType t) {
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

String? importPathFromLib(String packageRoot, String absModelFile) {
  final libDir = p.join(packageRoot, 'lib');
  final rel = p.relative(absModelFile, from: libDir);
  if (rel.startsWith('..')) return null;
  final withoutExt = p.withoutExtension(rel);
  return withoutExt.replaceAll('\\', '/');
}

ClassDeclaration? findFirstTableClass(CompilationUnit unit) {
  for (final d in unit.declarations) {
    if (d is! ClassDeclaration) continue;
    final element = d.declaredFragment?.element;
    if (element == null) continue;
    if (tableChecker.hasAnnotationOfExact(element)) return d;
  }
  return null;
}

Map<String, String> buildInitializerMap(ClassDeclaration classDecl) {
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

// ---------------------------------------------------------------------------
// String helpers
// ---------------------------------------------------------------------------

String toCamelCase(String input) {
  if (input.isEmpty) return input;
  return input[0].toLowerCase() + input.substring(1);
}

String capitalizeFirst(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

// ---------------------------------------------------------------------------
// Model / seeder info
// ---------------------------------------------------------------------------

class RegistryModelInfo {
  final String className;
  final String generatedClassName;
  final String importPath;
  final String packageName;

  RegistryModelInfo({
    required this.className,
    required this.generatedClassName,
    required this.importPath,
    required this.packageName,
  });
}

class SeederInfo {
  final String className;
  final String importPath;
  final String packageName;

  SeederInfo({
    required this.className,
    required this.importPath,
    required this.packageName,
  });
}

// ---------------------------------------------------------------------------
// Model scanning
// ---------------------------------------------------------------------------

Future<List<RegistryModelInfo>> scanModelsForRegistry(
  String packageRoot,
  String packageName,
) async {
  final libRoot = p.join(packageRoot, 'lib');
  final modelFiles = findModelFiles(libRoot);
  if (modelFiles.isEmpty) return const [];

  final collection = createCollection(packageRoot);
  final namingConfig = GeneratorNamingConfig.fromOptions(
    const BuilderOptions({}),
  );

  final infos = <RegistryModelInfo>[];
  for (final inputPath in modelFiles) {
    try {
      final context = collection.contextFor(inputPath);
      final result = context.currentSession.getParsedUnit(inputPath);
      if (result is! ParsedUnitResult) continue;
      final classNames = findTableClassNamesParsed(result.unit);
      for (final className in classNames) {
        final ip = importPathFromLib(packageRoot, inputPath);
        if (ip == null) continue;
        infos.add(
          RegistryModelInfo(
            className: className,
            generatedClassName: namingConfig.getModelClassName(className),
            packageName: packageName,
            importPath: ip,
          ),
        );
      }
    } catch (_) {}
  }

  infos.sort((a, b) => a.className.compareTo(b.className));
  return infos;
}

Future<List<SeederInfo>> scanSeedersForRegistry(
  String packageRoot,
  String packageName,
  String seedersDirAbs,
) async {
  final files = findSeederFiles(seedersDirAbs);
  if (files.isEmpty) return const [];

  final collection = createCollection(packageRoot);
  final infos = <SeederInfo>[];

  for (final fileAbs in files) {
    try {
      final context = collection.contextFor(fileAbs);
      final result = context.currentSession.getParsedUnit(fileAbs);
      if (result is! ParsedUnitResult) continue;

      final ip = importPathFromLib(packageRoot, fileAbs);
      if (ip == null) continue;

      for (final d in result.unit.declarations) {
        if (d is! ClassDeclaration) continue;
        final extendsClause = d.extendsClause;
        if (extendsClause == null) continue;

        final superType = extendsClause.superclass;
        final typeName = typeNameLexeme(superType);
        if (typeName == null) continue;

        if (!typeName.endsWith('SequelizeSeeding')) continue;

        infos.add(
          SeederInfo(
            className: d.name.lexeme,
            importPath: ip,
            packageName: packageName,
          ),
        );
      }
    } catch (_) {}
  }

  final byKey = <String, SeederInfo>{};
  for (final s in infos) {
    byKey['${s.importPath}::${s.className}'] = s;
  }
  return byKey.values.toList();
}

// ---------------------------------------------------------------------------
// Registry generation
// ---------------------------------------------------------------------------

String generateRegistryDart({
  required List<RegistryModelInfo> models,
  required String registryClassName,
}) {
  final buffer = StringBuffer();
  for (final model in models) {
    buffer.writeln(
      "import 'package:${model.packageName}/${model.importPath}.dart';",
    );
  }
  buffer.writeln();
  buffer.writeln("import 'package:sequelize_orm/sequelize_orm.dart';");
  buffer.writeln();

  buffer.writeln('/// Registry class for accessing all models');
  buffer.writeln('class $registryClassName {');
  buffer.writeln('  $registryClassName._();');
  buffer.writeln();

  for (final model in models) {
    final getterName = toCamelCase(model.className);
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
    final getterName = toCamelCase(model.className);
    buffer.writeln('      $registryClassName.$getterName,');
  }
  buffer.writeln('    ];');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

String generateDbRegistryDart({
  required List<RegistryModelInfo> models,
  required List<SeederInfo> seeders,
  required String registryClassName,
  required String packageName,
}) {
  final buffer = StringBuffer();

  for (final model in models) {
    buffer.writeln(
      "import 'package:${model.packageName}/${model.importPath}.dart';",
    );
  }
  for (final seeder in seeders) {
    buffer.writeln("import 'package:$packageName/${seeder.importPath}.dart';");
  }
  buffer.writeln();
  buffer.writeln("import 'package:sequelize_orm/sequelize_orm.dart';");
  buffer.writeln();

  buffer.writeln('/// Registry class for accessing all models and seeders');
  buffer.writeln('class $registryClassName {');
  buffer.writeln('  $registryClassName._();');
  buffer.writeln();

  for (final model in models) {
    final getterName = toCamelCase(model.className);
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
    final getterName = toCamelCase(model.className);
    buffer.writeln('      $registryClassName.$getterName,');
  }
  buffer.writeln('    ];');
  buffer.writeln('  }');
  buffer.writeln();

  buffer.writeln('  /// Returns a list of all seeders');
  buffer.writeln('  static List<SequelizeSeeding> allSeeders() {');
  if (seeders.isEmpty) {
    buffer.writeln('    return <SequelizeSeeding>[];');
  } else {
    buffer.writeln('    return [');
    for (final seeder in seeders) {
      buffer.writeln('      ${seeder.className}(),');
    }
    buffer.writeln('    ];');
  }
  buffer.writeln('  }');

  buffer.writeln('}');

  return buffer.toString();
}

Future<String> findRegistryPath({
  required String packageRoot,
  required String modelsRelPath,
  required String? registryPathOverride,
}) async {
  if (registryPathOverride != null) {
    return registryPathOverride;
  }

  final registries = findRegistryFiles(packageRoot);
  if (registries.isNotEmpty) {
    final rel = p.relative(registries.first, from: packageRoot);
    return rel.replaceFirst(RegExp(r'\.registry\.dart$'), '.dart');
  }

  final modelsBaseDirRel = p.dirname(modelsRelPath);
  return p.join(modelsBaseDirRel, 'db.dart');
}

Future<bool> generateRegistries({
  required String packageRoot,
  required List<String>? registryRelPaths,
  required bool quiet,
}) async {
  final packageName = readPackageName(packageRoot);
  if (packageName == null) {
    stderr.writeln('Failed to read package name from pubspec.yaml');
    return false;
  }

  final registryFilesAbs = (registryRelPaths != null)
      ? registryRelPaths
            .map((r) => toAbsolutePath(packageRoot, r))
            .where((p) => p.endsWith('.registry.dart'))
            .toList()
      : findRegistryFiles(packageRoot);

  if (registryFilesAbs.isEmpty) {
    if (!quiet) stdout.writeln('No *.registry.dart files found.');
    return true;
  }

  final models = await scanModelsForRegistry(packageRoot, packageName);
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
    final className = capitalizeFirst(baseName);

    final content = generateRegistryDart(
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

Future<bool> generateDbRegistryFromModelsPath({
  required String packageRoot,
  required String packageName,
  required String modelsRelPath,
  required String seedersRelPath,
  required String? registryPathOverride,
}) async {
  final modelsDirAbs = toAbsolutePath(packageRoot, modelsRelPath);
  final modelFiles = findModelFiles(modelsDirAbs);

  if (modelFiles.isEmpty) {
    stderr.writeln('No *.model.dart files found under: $modelsRelPath');
    return false;
  }

  final collection = createCollection(packageRoot);
  final namingConfig = GeneratorNamingConfig.fromOptions(
    const BuilderOptions({}),
  );

  final models = <RegistryModelInfo>[];
  for (final inputPath in modelFiles) {
    try {
      final context = collection.contextFor(inputPath);
      final result = context.currentSession.getParsedUnit(inputPath);
      if (result is! ParsedUnitResult) continue;

      final classNames = findTableClassNamesParsed(result.unit);
      if (classNames.isEmpty) continue;

      final ip = importPathFromLib(packageRoot, inputPath);
      if (ip == null) continue;

      for (final className in classNames) {
        models.add(
          RegistryModelInfo(
            className: className,
            generatedClassName: namingConfig.getModelClassName(className),
            packageName: packageName,
            importPath: ip,
          ),
        );
      }
    } catch (_) {}
  }

  if (models.isEmpty) {
    stderr.writeln('No @Table models found under: $modelsRelPath');
    return false;
  }

  models.sort((a, b) => a.className.compareTo(b.className));

  final dbOutRel = await findRegistryPath(
    packageRoot: packageRoot,
    modelsRelPath: modelsRelPath,
    registryPathOverride: registryPathOverride,
  );
  final dbOutAbs = toAbsolutePath(packageRoot, dbOutRel);

  final seedersDirAbs = toAbsolutePath(packageRoot, seedersRelPath);
  final seeders = Directory(seedersDirAbs).existsSync()
      ? await scanSeedersForRegistry(packageRoot, packageName, seedersDirAbs)
      : <SeederInfo>[];
  seeders.sort((a, b) => a.className.compareTo(b.className));

  final content = generateDbRegistryDart(
    models: models,
    seeders: seeders,
    registryClassName: 'Db',
    packageName: packageName,
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

// ---------------------------------------------------------------------------
// Model code generation
// ---------------------------------------------------------------------------

Future<bool> generateOne({
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
  final classDecl = findFirstTableClass(unit);
  if (classDecl == null) {
    stderr.writeln('No @Table class found in: $inputPath');
    return false;
  }

  final classElement = classDecl.declaredFragment?.element;
  if (classElement == null) {
    stderr.writeln('No element for @Table class in: $inputPath');
    return false;
  }

  final tableAnnotation = tableChecker.firstAnnotationOfExact(classElement);
  if (tableAnnotation == null) {
    stderr.writeln('Failed to read @Table annotation in: $inputPath');
    return false;
  }

  final initializerByName = buildInitializerMap(classDecl);
  Future<String?> initializerSourceProvider(FieldElement field) async =>
      initializerByName[field.name];

  final generated = await generateSequelizeModelStandalone(
    element: classElement,
    annotation: ConstantReader(tableAnnotation),
    options: const BuilderOptions({}),
    initializerSourceProvider: initializerSourceProvider,
  );

  final outputPath = outputPathOverride != null
      ? toAbsolutePath(packageRoot, outputPathOverride)
      : defaultOutputPathForInput(inputPath);

  final outputBasename = p.basename(outputPath);
  final inputBasename = p.basename(inputPath);

  final content = wrapAsPartOutput(
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

String defaultOutputPathForInput(String inputPath) {
  final dir = p.dirname(inputPath);
  final base = p.basename(inputPath);
  final outBase = base.replaceFirst(RegExp(r'\.model\.dart$'), '.model.g.dart');
  return p.join(dir, outBase);
}

String wrapAsPartOutput({
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

// ---------------------------------------------------------------------------
// Server mode
// ---------------------------------------------------------------------------

Future<void> runServer(String packageRoot) async {
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
      final collection = createCollection(packageRoot);

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
        final inputAbs = toAbsolutePath(packageRoot, input);
        final outAbs = output != null
            ? toAbsolutePath(packageRoot, output)
            : null;
        final ok = await generateOne(
          collection: collection,
          packageRoot: packageRoot,
          inputPath: inputAbs,
          outputPathOverride: outAbs,
          quiet: true,
        );
        okAll = okAll && ok;
        if (ok) {
          generated.add(outAbs ?? defaultOutputPathForInput(inputAbs));
        }
      } else if (folder != null) {
        final folderAbs = toAbsolutePath(packageRoot, folder);
        for (final inputAbs in findModelFiles(folderAbs)) {
          final ok = await generateOne(
            collection: collection,
            packageRoot: packageRoot,
            inputPath: inputAbs,
            outputPathOverride: null,
            quiet: true,
          );
          okAll = okAll && ok;
          if (ok) generated.add(defaultOutputPathForInput(inputAbs));
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

      final ok = await generateRegistries(
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

// ---------------------------------------------------------------------------
// Seed runner source
// ---------------------------------------------------------------------------

String seedRunnerSource({
  required String packageName,
  required String dbImportPath,
}) {
  return '''
import 'dart:io';

import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:$packageName/$dbImportPath.dart';

String? _valueAfter(List<String> args, String flag) {
  final idx = args.indexOf(flag);
  if (idx == -1) return null;
  if (idx + 1 >= args.length) return null;
  return args[idx + 1];
}

SequelizeCoreOptions _connectionFrom({
  required String? url,
  String? host,
  int? port,
  String? database,
  String? user,
  String? pass,
  bool? ssl,
  String? dialect,
}) {
  final hasUrl = url != null && url.trim().isNotEmpty;
  final uri = hasUrl ? Uri.tryParse(url) : null;
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
      if (hasUrl) return SequelizeConnection.postgres(url: url);
      return SequelizeConnection.postgres(
        host: host ?? 'localhost',
        port: port ?? 5432,
        database: database,
        user: user,
        password: pass,
        ssl: ssl ?? false,
      );
    case 'mysql':
      if (hasUrl) return SequelizeConnection.mysql(url: url);
      return SequelizeConnection.mysql(
        host: host ?? 'localhost',
        port: port ?? 3306,
        database: database,
        user: user,
        password: pass,
        ssl: ssl ?? false,
      );
    case 'mariadb':
      if (hasUrl) return SequelizeConnection.mariadb(url: url);
      return SequelizeConnection.mariadb(
        host: host ?? 'localhost',
        port: port ?? 3306,
        database: database,
        user: user,
        password: pass,
        ssl: ssl ?? false,
      );
    case 'sqlite':
      final storage = hasUrl ? url : (database ?? ':memory:');
      return SequelizeConnection.sqlite(storage: storage);
    default:
      throw ArgumentError(
        'Unsupported dialect "\$normalized". Pass --dialect or use a URL scheme like postgresql://, mysql://, mariadb://, sqlite://',
      );
  }
}

void main(List<String> args) async {
  final urlStr = _valueAfter(args, '--url');
  final dialect = _valueAfter(args, '--dialect');
  final alter = args.contains('--no-alter') ? false : true;
  final force = args.contains('--force');
  final verbose = args.contains('--verbose');

  // These will be passed by the generator when it starts this script.
  // We use environment variables for the complex parameters.
  final host = Platform.environment['SEQUELIZE_HOST'];
  final port = int.tryParse(Platform.environment['SEQUELIZE_PORT'] ?? '');
  final database = Platform.environment['SEQUELIZE_DB'];
  final user = Platform.environment['SEQUELIZE_USER'];
  final pass = Platform.environment['SEQUELIZE_PASS'];
  final ssl = Platform.environment['SEQUELIZE_SSL'] == 'true';

  final envUrl = Platform.environment['DATABASE_URL'];
  final resolvedUrl = (urlStr != null && urlStr.trim().isNotEmpty)
      ? urlStr.trim()
      : (envUrl != null && envUrl.trim().isNotEmpty ? envUrl.trim() : null);

  final sequelize = Sequelize().createInstance(
    connection: _connectionFrom(
      url: resolvedUrl,
      host: host,
      port: port,
      database: database,
      user: user,
      pass: pass,
      ssl: ssl,
      dialect: dialect,
    ),
    logging: verbose ? (msg) => stdout.writeln(msg) : null,
  );

  await sequelize.initialize(models: Db.allModels());
  
  final syncMode = force 
    ? SyncTableMode.force 
    : (alter ? SyncTableMode.alter : SyncTableMode.none);

  await sequelize.seed(
    seeders: Db.allSeeders(),
    syncTableMode: syncMode,
    log: (msg) => stdout.writeln(msg),
  );

  await sequelize.close();
}
''';
}

// ---------------------------------------------------------------------------
// DB profile selection
// ---------------------------------------------------------------------------

DbProfile? selectDbProfile({
  required SequelizeOrmConfig sequelizeOrmConfig,
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
