part of '../../sequelize_model_generator.dart';

void _generateTruncateMethod(
  StringBuffer buffer,
  String className,
) {
  buffer.writeln('  @override');
  buffer.writeln('  Future<void> truncate({');
  buffer.writeln('    bool? cascade,');
  buffer.writeln('    bool? restartIdentity,');
  buffer.writeln('    bool? force,');
  buffer.writeln('  }) {');
  buffer.writeln('    final options = <String, dynamic>{');
  buffer.writeln('      if (cascade != null) \'cascade\': cascade,');
  buffer.writeln(
    '      if (restartIdentity != null) \'restartIdentity\': restartIdentity,',
  );
  buffer.writeln('      if (force != null) \'force\': force,');
  buffer.writeln('    };');
  buffer.writeln('    return QueryEngine().truncate(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      options: options,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
