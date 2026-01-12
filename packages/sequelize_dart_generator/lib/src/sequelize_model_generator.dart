import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:sequelize_dart_annotations/sequelize_dart_annotations.dart';
import 'package:source_gen/source_gen.dart';

part 'generators/methods/_extract_boolean_validator.dart';
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
part 'generators/methods/_generate_class_values.dart';
part 'generators/methods/_generate_columns.dart';
part 'generators/methods/_generate_count_method.dart';
part 'generators/methods/_generate_define_method.dart';
part 'generators/methods/_generate_find_all_method.dart';
part 'generators/methods/_generate_find_one_method.dart';
part 'generators/methods/_generate_get_attributes_json_method.dart';
part 'generators/methods/_generate_get_attributes_method.dart';
part 'generators/methods/_generate_get_options_json_method.dart';
part 'generators/methods/_generate_get_query_builder_method.dart';
part 'generators/methods/_generate_include_helper.dart';
part 'generators/methods/_generate_increment_method.dart';
part 'generators/methods/_generate_json_value_parser.dart';
part 'generators/methods/_generate_max_method.dart';
part 'generators/methods/_generate_min_method.dart';
part 'generators/methods/_generate_query_builder.dart';
part 'generators/methods/_generate_sum_method.dart';
part 'generators/methods/_generate_where_method.dart';
part 'generators/methods/_generate_merge_where_helper.dart';
part 'generators/methods/_generate_instance_methods.dart';
part 'generators/methods/_generator_naming_config.dart';
part 'generators/methods/_get_association_json_key.dart';
part 'generators/methods/_get_associations.dart';
part 'generators/methods/_get_dart_type_for_query.dart';
part 'generators/methods/_get_fields.dart';
part 'generators/methods/_get_model_class_name.dart';
part 'generators/methods/_get_model_values_class_name.dart';
part 'generators/methods/_models.dart';
part 'generators/methods/_to_camel_case.dart';

class SequelizeModelGenerator extends GeneratorForAnnotation<Table> {
  final BuilderOptions options;

  SequelizeModelGenerator(this.options);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.displayName}`.',
      );
    }

    final className = element.name ?? 'Unknown';
    final tableAnnotation = _extractTableAnnotation(annotation);

    final fields = _getFields(element);
    final associations = _getAssociations(element);
    final generatedClassName = '\$$className';
    final valuesClassName = '\$${className}Values';
    final createClassName = '\$${className}Create';

    final buffer = StringBuffer();

    _generateClassDefinition(
      buffer,
      generatedClassName,
      className,
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
    final namingConfig = GeneratorNamingConfig.fromOptions(options);

    final singularName =
        (tableAnnotation['name']?['singular'] as String?) ??
        _toCamelCase(className);
    final pluralName =
        (tableAnnotation['name']?['plural'] as String?) ??
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
    );
    _generateFindOneMethod(
      buffer,
      className,
      valuesClassName,
      baseCallbackName,
      includeParamName,
    );
    _generateCountMethod(
      buffer,
      className,
      baseCallbackName,
    );
    _generateMaxMethod(
      buffer,
      className,
      baseCallbackName,
    );
    _generateMinMethod(
      buffer,
      className,
      baseCallbackName,
    );
    _generateSumMethod(
      buffer,
      className,
      baseCallbackName,
    );
    _generateIncrementMethod(
      buffer,
      className,
      valuesClassName,
      baseCallbackName,
      fields,
    );
    _generateDecrementMethod(
      buffer,
      className,
      valuesClassName,
      baseCallbackName,
      fields,
    );
    _generateGetQueryBuilderMethod(
      buffer,
      className,
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
    );
    _generateClassCreate(
      buffer,
      createClassName,
      fields,
    );
    _generateColumns(
      buffer,
      className,
      fields,
    );
    _generateQueryBuilder(
      buffer,
      className,
      fields,
      associations,
    );
    _generateIncludeHelper(
      buffer,
      className,
      associations,
      namingConfig,
    );

    return buffer.toString();
  }
}
