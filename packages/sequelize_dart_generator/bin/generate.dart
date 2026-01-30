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

  final collection = _createCollection(packageRoot);

  final inputs = <String>[];
  if (parsed.input != null) {
    inputs.add(_toAbsolutePath(packageRoot, parsed.input!));
  } else if (parsed.folder != null) {
    final folderAbs = _toAbsolutePath(packageRoot, parsed.folder!);
    inputs.addAll(_findModelFiles(folderAbs));
  } else {
    stderr.writeln('Missing --input or --folder.');
    stderr.writeln(_helpText());
    exit(2);
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
  dart run sequelize_dart_generator:generate --registry
  dart run sequelize_dart_generator:generate --server

Options:
  --package-root <path>   Package root (defaults to nearest pubspec.yaml from cwd)
  --input <path>          Single *.model.dart file (relative to package root or absolute)
  --folder <path>         Folder to scan for **/*.model.dart (relative to package root or absolute)
  --registry              Generate registries for **/*.registry.dart under the package
  --output <path>         Output path (only applies to --input)
  --server               Run as a persistent stdio server (JSON lines)
  --help                 Show this help
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
