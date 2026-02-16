import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:sequelize_orm_generator/src/generator_naming_config.dart';
import 'package:source_gen/source_gen.dart';

/// Custom builder that generates a models registry from all model files
class ModelsRegistryBuilder implements Builder {
  final BuilderOptions options;

  ModelsRegistryBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions {
    // Support registry files anywhere
    // Pattern: *.registry.dart -> generates *.dart in the same directory
    // build_runner will replace .registry.dart with .dart
    return {
      '.registry.dart': ['.dart'],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final config = _RegistryConfig.fromOptions(options);

    // Skip if disabled
    if (!config.enabled) {
      return;
    }

    // Extract class name and output file from registry file name
    // e.g., models.registry.dart -> Models class, models.dart file
    final inputPath = buildStep.inputId.path;

    // Skip if not a registry file
    if (!inputPath.endsWith('.registry.dart')) {
      return;
    }

    final fileName = p.basename(inputPath); // e.g., "models.registry.dart"
    final baseName = fileName.replaceAll(
      '.registry.dart',
      '',
    ); // e.g., "models"

    final inputPathPosix = inputPath.replaceAll('\\', '/');
    final isSeedersRegistry =
        baseName == 'seeders' || inputPathPosix.contains('/seeders/');

    // Generate class name: capitalize first letter
    // models -> Models, db -> Db, database -> Database
    final className = _capitalizeFirst(baseName);

    // Output file is in the same directory as the registry file
    final inputDir = p.dirname(inputPath); // e.g., "lib/models"
    final outputFileName = baseName; // e.g., "models"
    final outputPath = p.join(
      inputDir,
      '$outputFileName.dart',
    ); // e.g., "lib/models/models.dart"

    late final String content;

    if (isSeedersRegistry) {
      final seederFiles = await _findSeederFiles(buildStep);
      if (seederFiles.isEmpty) return;

      final seeders = <_SeederInfo>[];
      for (final seederFile in seederFiles) {
        final infos = await _extractSeederInfos(seederFile, buildStep);
        seeders.addAll(infos);
      }
      if (seeders.isEmpty) return;

      seeders.sort((a, b) => a.className.compareTo(b.className));
      content = _generateSeedersRegistryClass(seeders, className);
    } else {
      // Find all .model.dart files in the package
      final modelFiles = await _findModelFiles(buildStep);

      if (modelFiles.isEmpty) {
        return;
      }

      // Extract model information from each file
      final models = <_ModelInfo>[];
      for (final modelFile in modelFiles) {
        final info = await _extractModelInfo(modelFile, buildStep);
        if (info != null) {
          models.add(info);
        }
      }

      if (models.isEmpty) {
        return;
      }

      // Also scan for seeder files to include in the registry
      final seederFiles = await _findSeederFiles(buildStep);
      final seeders = <_SeederInfo>[];
      for (final seederFile in seederFiles) {
        final infos = await _extractSeederInfos(seederFile, buildStep);
        seeders.addAll(infos);
      }
      seeders.sort((a, b) => a.className.compareTo(b.className));

      // Generate the registry class with the derived class name
      content = _generateRegistryClass(models, className, seeders);
    }

    // Write to the output file in the same directory as the registry file
    final outputId = AssetId(
      buildStep.inputId.package,
      outputPath,
    );

    await buildStep.writeAsString(outputId, content);
  }

  Future<List<AssetId>> _findModelFiles(BuildStep buildStep) async {
    final modelGlob = Glob('lib/**/*.model.dart');
    return await buildStep.findAssets(modelGlob).toList();
  }

  Future<List<AssetId>> _findSeederFiles(BuildStep buildStep) async {
    final seederGlob = Glob('lib/**/*.seeder.dart');
    return await buildStep.findAssets(seederGlob).toList();
  }

  Future<List<_SeederInfo>> _extractSeederInfos(
    AssetId assetId,
    BuildStep buildStep,
  ) async {
    try {
      final libraryReader = LibraryReader(
        await buildStep.resolver.libraryFor(assetId),
      );

      // Get the import path relative to lib/
      final assetPathPosix = assetId.path.replaceAll('\\', '/');
      final importPath = p.posix.withoutExtension(
        p.posix.relative(assetPathPosix, from: 'lib'),
      );

      final seeders = <_SeederInfo>[];
      for (final element in libraryReader.allElements) {
        if (element is! ClassElement) continue;
        final superType = element.supertype;
        final superName = superType?.element.displayName;
        if (superName != 'SequelizeSeeding') continue;

        seeders.add(
          _SeederInfo(
            className: element.displayName,
            importPath: importPath,
            packageName: assetId.package,
          ),
        );
      }
      return seeders;
    } catch (_) {
      return const [];
    }
  }

  String _generateSeedersRegistryClass(
    List<_SeederInfo> seeders,
    String className,
  ) {
    final buffer = StringBuffer();

    for (final seeder in seeders) {
      final importPathPosix = seeder.importPath.replaceAll('\\', '/');
      buffer.writeln(
        "import 'package:${seeder.packageName}/$importPathPosix.dart';",
      );
    }
    buffer.writeln();
    buffer.writeln("import 'package:sequelize_orm/sequelize_orm.dart';");
    buffer.writeln();

    buffer.writeln('/// Registry class for accessing all seeders');
    buffer.writeln('class $className {');
    buffer.writeln('  $className._();');
    buffer.writeln();
    buffer.writeln('  static List<SequelizeSeeding> all() {');
    buffer.writeln('    return [');
    for (final seeder in seeders) {
      buffer.writeln('      ${seeder.className}(),');
    }
    buffer.writeln('    ];');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  Future<_ModelInfo?> _extractModelInfo(
    AssetId assetId,
    BuildStep buildStep,
  ) async {
    try {
      final libraryReader = LibraryReader(
        await buildStep.resolver.libraryFor(assetId),
      );

      // Create naming config instance
      final namingConfig = GeneratorNamingConfig.fromOptions(options);

      // Find the class annotated with @Table
      for (final element in libraryReader.allElements) {
        if (element is ClassElement) {
          if (_hasTableAnnotation(element)) {
            final className = element.name;
            if (className == null) continue;
            final generatedClassName = namingConfig.getModelClassName(
              className,
            );

            // Get the import path relative to lib/
            // IMPORTANT: Dart import URIs must use forward slashes, regardless of OS.
            // `package:path` defaults to the host platform style, which is `\` on Windows.
            final assetPathPosix = assetId.path.replaceAll('\\', '/');
            final importPath = p.posix.withoutExtension(
              p.posix.relative(assetPathPosix, from: 'lib'),
            );

            return _ModelInfo(
              className: className,
              generatedClassName: generatedClassName,
              importPath: importPath,
              packageName: assetId.package,
            );
          }
        }
      }
    } catch (e) {
      // If we can't parse the file, skip it
      return null;
    }
    return null;
  }

  bool _hasTableAnnotation(ClassElement element) {
    // element.metadata.annotations is the correct way to access annotations
    for (final annotation in element.metadata.annotations) {
      final value = annotation.computeConstantValue();
      if (value != null) {
        final type = value.type;
        if (type != null && type.element != null) {
          final elementName = type.element!.displayName;
          if (elementName == 'Table') {
            return true;
          }
        }
      }
    }
    return false;
  }

  String _generateRegistryClass(
    List<_ModelInfo> models,
    String className,
    List<_SeederInfo> seeders,
  ) {
    final buffer = StringBuffer();
    final hasSeeders = seeders.isNotEmpty;

    // Generate imports
    for (final model in models) {
      final importPathPosix = model.importPath.replaceAll('\\', '/');
      buffer.writeln(
        "import 'package:${model.packageName}/$importPathPosix.dart';",
      );
    }
    for (final seeder in seeders) {
      final importPathPosix = seeder.importPath.replaceAll('\\', '/');
      buffer.writeln(
        "import 'package:${seeder.packageName}/$importPathPosix.dart';",
      );
    }
    buffer.writeln();
    buffer.writeln("import 'package:sequelize_orm/sequelize_orm.dart';");
    buffer.writeln();

    // Generate class
    final classDoc = hasSeeders
        ? '/// Registry class for accessing all models and seeders'
        : '/// Registry class for accessing all models';
    buffer.writeln(classDoc);
    buffer.writeln('class $className {');
    buffer.writeln('  $className._();');
    buffer.writeln();

    // Generate static getters for each model
    for (final model in models) {
      final getterName = _toCamelCase(model.className);
      buffer.writeln('  /// Returns the ${model.className} model instance');
      buffer.writeln(
        '  static ${model.generatedClassName} get $getterName => ${model.generatedClassName}();',
      );
      buffer.writeln();
    }

    // Generate allModels() method
    buffer.writeln('  /// Returns a list of all model instances');
    buffer.writeln('  static List<Model> allModels() {');
    buffer.writeln('    return [');
    for (final model in models) {
      final getterName = _toCamelCase(model.className);
      buffer.writeln('      $className.$getterName,');
    }
    buffer.writeln('    ];');
    buffer.writeln('  }');

    // Generate allSeeders() method if seeders exist
    if (hasSeeders) {
      buffer.writeln();
      buffer.writeln('  /// Returns a list of all seeders');
      buffer.writeln('  static List<SequelizeSeeding> allSeeders() {');
      buffer.writeln('    return [');
      for (final seeder in seeders) {
        buffer.writeln('      ${seeder.className}(),');
      }
      buffer.writeln('    ];');
      buffer.writeln('  }');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }

  String _capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}

class _ModelInfo {
  final String className;
  final String generatedClassName;
  final String importPath;
  final String packageName;

  _ModelInfo({
    required this.className,
    required this.generatedClassName,
    required this.importPath,
    required this.packageName,
  });
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

class _RegistryConfig {
  final bool enabled;
  final String className;
  final String outputFileName;
  final String entryFileName;

  _RegistryConfig({
    this.enabled = true,
    this.className = 'Models',
    this.outputFileName = 'models',
    this.entryFileName = 'models',
  });

  factory _RegistryConfig.fromOptions(BuilderOptions options) {
    final config = options.config;
    return _RegistryConfig(
      enabled: config['enabled'] as bool? ?? true,
      className: config['className'] as String? ?? 'Models',
      outputFileName: config['outputFileName'] as String? ?? 'models',
      entryFileName: config['entryFileName'] as String? ?? 'models',
    );
  }
}
