import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sequelize_dart_generator/sequelize_dart_generator.dart';

const _tableChecker = TypeChecker.fromUrl(
  'package:sequelize_dart/src/annotations/table.dart#Table',
);

/// Assist that generates or regenerates the .model.g.dart file for a .model.dart
/// file using the sequelize_dart_generator.
class GenerateModelAssist extends ResolvedCorrectionProducer {
  static const _assistKind = AssistKind(
    'sequelize_dart_analyzer_plugin.assist.generateModel',
    DartFixKindPriority.standard,
    "Generate '*.model.g.dart'",
  );

  GenerateModelAssist({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind? get assistKind => _assistKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (!file.endsWith('.model.dart')) return;

    final unit = unitResult.unit;
    final partOfBasename = _partOfBasename(file);
    if (partOfBasename == null) return;

    final tableClasses = <ClassElement>[];
    for (final decl in unit.declarations) {
      if (decl is ClassDeclaration) {
        final el = decl.declaredFragment?.element;
        if (el is ClassElement && _tableChecker.hasAnnotationOfExact(el)) {
          tableClasses.add(el);
        }
      }
    }
    if (tableClasses.isEmpty) return;

    Future<AstNode?> astNodeProvider(Object element) async {
      if (element is InstanceElement) {
        final node = await getDeclarationNodeFromElement(element);
        return node is AstNode ? node : null;
      }
      if (element is Fragment) {
        final result = await sessionHelper.getFragmentDeclaration(element);
        return result?.node;
      }
      return null;
    }

    const options = BuilderOptions({});
    final generator = SequelizeModelGenerator(options);
    final buffer = StringBuffer();

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// dart format width=80');
    buffer.writeln();
    buffer.writeln("part of '$partOfBasename';");
    buffer.writeln();

    for (final classEl in tableClasses) {
      final annotation = _tableChecker.firstAnnotationOfExact(classEl);
      if (annotation == null) continue;
      final reader = ConstantReader(annotation);
      try {
        final src = await generator.generateModelSource(
          classEl,
          reader,
          astNodeProvider,
        );
        buffer.writeln('// **************************************************************************');
        buffer.writeln('// SequelizeModelGenerator');
        buffer.writeln('// **************************************************************************');
        buffer.writeln();
        buffer.write(src);
        if (!src.endsWith('\n')) buffer.writeln();
        buffer.writeln();
      } catch (_) {
        return;
      }
    }

    final gPath = file.replaceAll(RegExp(r'\.model\.dart$'), '.model.g.dart');
    final content = buffer.toString();

    await builder.addDartFileEdit(gPath, (editBuilder) {
      try {
        final res = resourceProvider.getFile(gPath);
        final len = res.lengthSync;
        editBuilder.addSimpleReplacement(SourceRange(0, len), content);
      } catch (_) {
        editBuilder.addSimpleInsertion(0, content);
      }
    }, createEditsForImports: false);
  }

  /// e.g. "users.model.dart" from ".../example/lib/models/users.model.dart"
  String? _partOfBasename(String path) {
    final segments = path.replaceAll(r'\', '/').split('/');
    final basename = segments.isNotEmpty ? segments.last : path;
    if (!basename.endsWith('.model.dart')) return null;
    return basename;
  }
}
