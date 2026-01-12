part of '../../sequelize_model_generator.dart';

void _generateMergeWhereHelper(
  StringBuffer buffer,
  String columnsClassName,
  String whereCallbackName,
  String generatedClassName,
  List<_FieldInfo> primaryKeys,
) {
  buffer.writeln(
    '  /// Merge instance primary key where clause with optional provided where clause',
  );
  buffer.writeln(
    '  /// Sequelize.js behavior: instance primary key replaces any primary key in provided where',
  );
  buffer.writeln(
    '  /// This merging happens at the SQL level by Sequelize.js, so we use and() to combine them',
  );
  buffer.writeln(
    '  QueryOperator Function($columnsClassName $whereCallbackName) _mergeWhere(',
  );
  buffer.writeln(
    '    QueryOperator Function($columnsClassName $whereCallbackName)? where,',
  );
  buffer.writeln('  ) {');
  buffer.writeln('    final instanceWhereClause = this.where();');
  buffer.writeln(
    '    QueryOperator Function($columnsClassName $whereCallbackName) finalWhere;',
  );
  buffer.writeln('    if (instanceWhereClause != null) {');
  buffer.writeln(
    '      // Convert instance where() Map to QueryOperator function',
  );
  _generateMapToWhereClause(
    buffer,
    whereCallbackName,
    primaryKeys,
    'primaryKeyWhere',
    columnsClassName,
  );
  buffer.writeln('      if (where != null) {');
  buffer.writeln(
    '        // Merge with and(): Sequelize.js handles primary key replacement at SQL level',
  );
  buffer.writeln(
    '        // Order: provided where first, then instance primary key (matches Sequelize.js behavior)',
  );
  buffer.writeln(
    '        finalWhere = ($whereCallbackName) => and([where($whereCallbackName), primaryKeyWhere($whereCallbackName)]);',
  );
  buffer.writeln('      } else {');
  buffer.writeln('        finalWhere = primaryKeyWhere;');
  buffer.writeln('      }');
  buffer.writeln('    } else if (where != null) {');
  buffer.writeln('      // Use provided where clause only');
  buffer.writeln('      finalWhere = where;');
  buffer.writeln('    } else {');
  buffer.writeln(
    '      throw ArgumentError(\'Where clause is required\');',
  );
  buffer.writeln('    }');
  buffer.writeln('    return finalWhere;');
  buffer.writeln('  }');
  buffer.writeln();
}
