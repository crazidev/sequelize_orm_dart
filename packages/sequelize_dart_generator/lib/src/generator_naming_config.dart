import 'package:build/build.dart';

/// Configuration for naming conventions used in code generation
class GeneratorNamingConfig {
  /// Whether to generate ModelCreate class (default: true)
  final bool generateCreateClass;

  const GeneratorNamingConfig({
    this.generateCreateClass = true,
  });

  factory GeneratorNamingConfig.fromOptions(BuilderOptions options) {
    final config = options.config;
    return GeneratorNamingConfig(
      generateCreateClass: config['generateCreateClass'] as bool? ?? true,
    );
  }

  /// Gets the parameter name for the 'where' callback
  String getWhereCallbackName({
    required String singular,
    required String plural,
  }) {
    // Default to singular as requested to remove the naming_strategy config
    return singular;
  }

  /// Gets the parameter name for the 'include' callback
  String getIncludeCallbackName({
    required String singular,
    required String plural,
  }) {
    // Default to singular
    final name = singular;
    if (name.isEmpty) return 'include';
    return 'include${name[0].toUpperCase()}${name.substring(1)}';
  }

  /// Gets the generated model class name (e.g., UserModel from User)
  String getModelClassName(String className) {
    return '${className}Model';
  }

  /// Gets the generated values class name (e.g., UserValues from User)
  String getModelValuesClassName(String className) {
    return '${className}Values';
  }

  /// Gets the generated create class name (e.g., UserCreate from User)
  String getModelCreateClassName(String className) {
    return 'Create$className';
  }

  /// Gets the generated update class name (e.g., UserUpdate from User)
  String getModelUpdateClassName(String className) {
    return 'Update$className';
  }

  /// Gets the generated columns class name (e.g., UserColumns from User)
  String getModelColumnsClassName(String className) {
    return '${className}Columns';
  }

  /// Gets the generated query class name (e.g., UserQuery from User)
  String getModelQueryClassName(String className) {
    return '${className}Query';
  }

  /// Gets the generated include helper class name (e.g., UserIncludeHelper from User)
  String getModelIncludeHelperClassName(String className) {
    return '${className}IncludeHelper';
  }
}
