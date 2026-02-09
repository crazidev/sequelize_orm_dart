import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:sequelize_orm_analyzer/rules/table_must_be_abstract.dart';

final plugin = SequelizePlugin();

class SequelizePlugin extends Plugin {
  @override
  String get name => 'Sequelize ORM Dart plugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(TableMustBeAbstract());
    registry.registerFixForRule(
      TableMustBeAbstract.code,
      AddAbstractToTableClassFix.new,
    );
  }
}
