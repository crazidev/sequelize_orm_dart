part of '../../sequelize_model_generator.dart';

class GeneratorNamingConfig {
  /// Whether to generate $ModelCreate class (default: true)
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
}
