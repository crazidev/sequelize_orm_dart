part of '../../sequelize_model_generator.dart';

void _generateMergeWhereHelper(
  StringBuffer buffer,
  String columnsClassName,
  String whereCallbackName,
  String generatedClassName,
  List<_FieldInfo> primaryKeys,
) {
  buffer.writeln(
    '  /// Merges instance primary key with optional where clause (Sequelize.js behavior)',
  );
  buffer.writeln(
    '  QueryOperator Function($columnsClassName c) _mergeWhere(QueryOperator Function($columnsClassName c)? where) {',
  );
  buffer.writeln('    final pk = this.where();');
  buffer.writeln('    if (pk == null) {');
  buffer.writeln(
    '      if (where != null) return where;',
  );
  buffer.writeln(
    '      throw ArgumentError(\'Where clause is required\');',
  );
  buffer.writeln('    }');

  // Generate primary key where builder with explicit type
  buffer.writeln(
    '    QueryOperator pkWhere($columnsClassName c) => ',
  );
  if (primaryKeys.length == 1) {
    final key = primaryKeys.first.fieldName;
    buffer.writeln('        c.$key.eq(pk[\'$key\']);');
  } else {
    buffer.writeln('        and([');
    for (final pk in primaryKeys) {
      final key = pk.fieldName;
      buffer.writeln(
        '          if (pk[\'$key\'] != null) c.$key.eq(pk[\'$key\']),',
      );
    }
    buffer.writeln('        ]);');
  }

  buffer.writeln(
    '    return where != null ? ($columnsClassName c) => and([where(c), pkWhere(c)]) : pkWhere;',
  );
  buffer.writeln('  }');
  buffer.writeln();
}
