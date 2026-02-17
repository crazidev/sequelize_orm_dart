import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:sequelize_orm/src/annotations.dart';
import 'package:sequelize_orm_generator/src/generator_naming_config.dart';
import 'package:source_gen/source_gen.dart';

part 'generators/methods/_extract_boolean_validator.dart';
part 'generators/methods/_extract_from_datatype_field.dart';
part 'generators/methods/_extract_len_validator.dart';
part 'generators/methods/_extract_list_validator.dart';
part 'generators/methods/_extract_not_contains_validator.dart';
part 'generators/methods/_extract_number_validator.dart';
part 'generators/methods/_extract_pattern_validator.dart';
part 'generators/methods/_extract_string_validator.dart';
part 'generators/methods/_extract_table_annotation.dart';
part 'generators/methods/_extract_validate_code.dart';
part 'generators/methods/_generate_associate_model_method.dart';
part 'generators/methods/_generate_class_create.dart';
part 'generators/methods/_generate_class_definition.dart';
part 'generators/methods/_generate_class_update.dart';
part 'generators/methods/_generate_class_values.dart';
part 'generators/methods/_generate_columns.dart';
part 'generators/methods/_generate_count_method.dart';
part 'generators/methods/_generate_create_method.dart';
part 'generators/methods/_generate_define_method.dart';
part 'generators/methods/_generate_destroy_method.dart';
part 'generators/methods/_generate_enums.dart';
part 'generators/methods/_generate_find_all_method.dart';
part 'generators/methods/_generate_find_one_method.dart';
part 'generators/methods/_generate_get_attributes_json_method.dart';
part 'generators/methods/_generate_get_attributes_method.dart';
part 'generators/methods/_generate_get_options_json_method.dart';
part 'generators/methods/_generate_get_query_builder_method.dart';
part 'generators/methods/_generate_include_helper.dart';
part 'generators/methods/_generate_increment_method.dart';
part 'generators/methods/_generate_instance_methods.dart';
part 'generators/methods/_generate_json_value_parser.dart';
part 'generators/methods/_generate_max_method.dart';
part 'generators/methods/_generate_merge_where_helper.dart';
part 'generators/methods/_generate_min_method.dart';
part 'generators/methods/_generate_query_builder.dart';
part 'generators/methods/_generate_restore_method.dart';
part 'generators/methods/_generate_sum_method.dart';
part 'generators/methods/_generate_truncate_method.dart';
part 'generators/methods/_generate_update_method.dart';
part 'generators/methods/_generate_where_method.dart';
part 'generators/methods/_generator_naming_config.dart';
part 'generators/methods/_get_association_json_key.dart';
part 'generators/methods/_get_associations.dart';
part 'generators/methods/_get_dart_type_for_query.dart';
part 'generators/methods/_get_datatype_expression.dart';
part 'generators/methods/_get_fields.dart';
part 'generators/methods/_get_model_class_name.dart';
part 'generators/methods/_models.dart';
part 'generators/methods/_to_camel_case.dart';

/// Provides the source of a field's initializer expression, if available.
///
/// This is used to support non-const initializers without depending on
/// `BuildStep.resolver.astNodeFor(...)` (e.g. in a standalone analyzer CLI).
typedef InitializerSourceProvider = Future<String?> Function(
  FieldElement field,
);

/// Shared implementation used by both build_runner and the standalone CLI.
Future<String> _generateForClassElement(
  ClassElement element,
  ConstantReader annotation,
  BuilderOptions options, {
  required InitializerSourceProvider initializerSourceProvider,
}) async {
  final className = element.name ?? 'Unknown';
  final tableAnnotation = _extractTableAnnotation(annotation);

  final fields = await _getFields(element, initializerSourceProvider);
  final associations = _getAssociations(element);
  final namingConfig = GeneratorNamingConfig.fromOptions(options);
  final generatedClassName = namingConfig.getModelClassName(className);
  final valuesClassName = namingConfig.getModelValuesClassName(className);
  final createClassName = namingConfig.getModelCreateClassName(className);
  final updateClassName = namingConfig.getModelUpdateClassName(className);

  final buffer = StringBuffer();
  buffer.writeln(
    '// ignore_for_file: override_on_non_overriding_member, invalid_use_of_protected_member, avoid_renaming_method_parameters, annotate_overrides, curly_braces_in_flow_control_structures, non_constant_identifier_names, use_null_aware_elements, prefer_function_declarations_over_variables, invalid_use_of_internal_member, unused_element, unnecessary_cast',
  );
  buffer.writeln();

  _generateEnums(buffer, className, fields, namingConfig);

  _generateClassDefinition(
    buffer,
    generatedClassName,
    className,
    namingConfig,
  );
  _generateDefineMethod(
    buffer,
    generatedClassName,
    associations,
  );
  _generateGetAttributesMethod(
    buffer,
    fields,
  );
  _generateGetAttributesJsonMethod(buffer);
  _generateGetOptionsJsonMethod(
    buffer,
    tableAnnotation,
  );

  final singularName = (tableAnnotation['name']?['singular'] as String?) ??
      _toCamelCase(className);
  final pluralName = (tableAnnotation['name']?['plural'] as String?) ??
      _toCamelCase(className);

  final baseCallbackName = namingConfig.getWhereCallbackName(
    singular: singularName,
    plural: pluralName,
  );
  final includeParamName = namingConfig.getIncludeCallbackName(
    singular: singularName,
    plural: pluralName,
  );

  _generateFindAllMethod(
    buffer,
    className,
    valuesClassName,
    baseCallbackName,
    includeParamName,
    namingConfig,
  );
  _generateFindOneMethod(
    buffer,
    className,
    valuesClassName,
    baseCallbackName,
    includeParamName,
    namingConfig,
  );
  _generateCreateMethod(
    buffer,
    className,
    valuesClassName,
    baseCallbackName,
    includeParamName,
    fields,
    associations,
    namingConfig,
  );
  _generateUpdateMethod(
    buffer,
    className,
    baseCallbackName,
    fields,
    namingConfig,
  );
  _generateCountMethod(
    buffer,
    className,
    baseCallbackName,
    namingConfig,
  );
  _generateMaxMethod(
    buffer,
    className,
    baseCallbackName,
    namingConfig,
  );
  _generateMinMethod(
    buffer,
    className,
    baseCallbackName,
    namingConfig,
  );
  _generateSumMethod(
    buffer,
    className,
    baseCallbackName,
    namingConfig,
  );
  _generateIncrementMethod(
    buffer,
    className,
    valuesClassName,
    baseCallbackName,
    fields,
    namingConfig,
  );
  _generateDecrementMethod(
    buffer,
    className,
    valuesClassName,
    baseCallbackName,
    fields,
    namingConfig,
  );
  _generateDestroyMethod(
    buffer,
    className,
    baseCallbackName,
    namingConfig,
  );
  _generateTruncateMethod(
    buffer,
    className,
  );
  _generateRestoreMethod(
    buffer,
    className,
    baseCallbackName,
    namingConfig,
  );
  _generateGetQueryBuilderMethod(
    buffer,
    className,
    namingConfig,
  );
  _generateAssociateModelMethod(
    buffer,
    generatedClassName,
    associations,
  );

  buffer.writeln('}');
  buffer.writeln();

  _generateClassValues(
    buffer,
    valuesClassName,
    fields,
    associations,
    className: className,
    generatedClassName: generatedClassName,
    namingConfig: namingConfig,
  );

  // Conditionally generate ModelCreate class based on config
  if (namingConfig.generateCreateClass) {
    _generateClassCreate(
      buffer,
      createClassName,
      fields,
      associations,
      namingConfig,
      className: className,
    );
    // Also generate Update class (same structure but without associations)
    _generateClassUpdate(
      buffer,
      updateClassName,
      fields,
      className: className,
    );
  }

  _generateColumns(
    buffer,
    className,
    fields,
    namingConfig,
  );
  _generateQueryBuilder(
    buffer,
    className,
    fields,
    associations,
    namingConfig,
  );
  _generateIncludeHelper(
    buffer,
    className,
    associations,
    namingConfig,
  );

  return buffer.toString();
}

/// Standalone API: generate code for a resolved `ClassElement` annotated with `@Table`
/// without requiring a `BuildStep`.
///
/// Used by the analyzer-based CLI to generate `*.model.g.dart` directly.
Future<String> generateSequelizeModelStandalone({
  required ClassElement element,
  required ConstantReader annotation,
  required BuilderOptions options,
  required InitializerSourceProvider initializerSourceProvider,
}) {
  return _generateForClassElement(
    element,
    annotation,
    options,
    initializerSourceProvider: initializerSourceProvider,
  );
}

class SequelizeModelGenerator extends GeneratorForAnnotation<Table> {
  final BuilderOptions options;

  SequelizeModelGenerator(this.options);

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.displayName}`.',
      );
    }

    return _generateForClassElement(
      element,
      annotation,
      options,
      initializerSourceProvider: (field) async {
        try {
          final dynamic node = await buildStep.resolver.astNodeFor(
            field.firstFragment,
            resolve: true,
          );
          final dynamic initializer = node?.initializer;
          return (initializer != null)
              ? (initializer.toSource() as String)
              : null;
        } catch (_) {
          return null;
        }
      },
    );
  }
}
