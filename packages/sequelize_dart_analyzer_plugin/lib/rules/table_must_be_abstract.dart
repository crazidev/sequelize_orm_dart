import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class TableMustBeAbstract extends AnalysisRule {
  static const LintCode code = LintCode(
    'table_must_be_abstract',
    'Classes annotated with @Table must be abstract.',
    correctionMessage: "Add 'abstract' to the class declaration.",
  );

  TableMustBeAbstract()
    : super(
        name: 'table_must_be_abstract',
        description:
            'Ensures that any class with @Table annotation is an abstract class.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    bool hasTable = false;
    for (var annotation in node.metadata) {
      if (annotation.name.name == 'Table') {
        hasTable = true;
        break;
      }
    }

    if (!hasTable) return;
    if (node.abstractKeyword != null) return;

    rule.reportAtToken(node.name);
  }
}

/// Quick fix that adds `abstract` to a @Table-annotated class.
class AddAbstractToTableClassFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'sequelize_dart_analyzer_plugin.fix.addAbstract',
    DartFixKindPriority.standard,
    "Add 'abstract' to class",
  );

  AddAbstractToTableClassFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind? get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final decl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (decl == null || decl.abstractKeyword != null) return;

    await builder.addDartFileEdit(file, (editBuilder) {
      editBuilder.addSimpleInsertion(decl.classKeyword.offset, 'abstract ');
    }, createEditsForImports: false);
  }
}
