import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
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

    // Generate the registry class with the derived class name
    final content = _generateRegistryClass(models, className);

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

  Future<_ModelInfo?> _extractModelInfo(
    AssetId assetId,
    BuildStep buildStep,
  ) async {
    try {
      final libraryReader = LibraryReader(
        await buildStep.resolver.libraryFor(assetId),
      );

      // Find the class annotated with @Table
      for (final element in libraryReader.allElements) {
        if (element is ClassElement) {
          if (_hasTableAnnotation(element)) {
            final className = element.name;
            if (className == null) continue;
            final generatedClassName = '\$$className';

            // Get the import path relative to lib/
            final importPath = p.withoutExtension(
              p.relative(assetId.path, from: 'lib'),
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
  ) {
    final buffer = StringBuffer();

    // Generate imports
    for (final model in models) {
      buffer.writeln(
        "import 'package:${model.packageName}/${model.importPath}.dart';",
      );
    }
    buffer.writeln();
    buffer.writeln("import 'package:sequelize_dart/sequelize_dart.dart';");
    buffer.writeln();

    // Generate class
    buffer.writeln('/// Registry class for accessing all models');
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
