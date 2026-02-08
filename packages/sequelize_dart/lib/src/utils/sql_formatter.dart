import 'package:sequelize_dart/src/utils/ansi_colors.dart';

/// Configuration class for SQL syntax highlighting colors
class SqlFormatterColors {
  /// ANSI code to reset formatting
  final AnsiColor reset;

  /// Color for SQL keywords (SELECT, FROM, WHERE, etc.)
  final AnsiColor keyword;

  /// Color for operators (=, <, >, etc.)
  final AnsiColor operator;

  /// Color for identifiers (table/column names)
  final AnsiColor identifier;

  const SqlFormatterColors({
    this.reset = AnsiColor.reset,
    this.keyword = AnsiColor.brightBlue,
    this.operator = AnsiColor.brightYellow,
    this.identifier = AnsiColor.brightCyan,
  });

  /// Default color scheme
  static const SqlFormatterColors defaultColors = SqlFormatterColors();

  /// No colors (plain text output)
  static const SqlFormatterColors noColors = SqlFormatterColors(
    reset: AnsiColor.none,
    keyword: AnsiColor.none,
    operator: AnsiColor.none,
    identifier: AnsiColor.none,
  );

  /// Green theme
  static const SqlFormatterColors greenTheme = SqlFormatterColors(
    keyword: AnsiColor.brightGreen,
  );

  /// Magenta theme
  static const SqlFormatterColors magentaTheme = SqlFormatterColors(
    keyword: AnsiColor.brightMagenta,
  );

  /// Red theme
  static const SqlFormatterColors redTheme = SqlFormatterColors(
    keyword: AnsiColor.brightRed,
  );
}

/// SQL formatter utility for pretty-printing SQL queries with syntax highlighting
class SqlFormatter {
  /// Default colors used for formatting
  static SqlFormatterColors colors = SqlFormatterColors.defaultColors;

  /// Formats a SQL query string for better readability
  static String format(String sql) {
    // Remove "Executing (default):" prefix if present
    final String cleaned = sql
        .replaceFirst(
          RegExp(r'Executing\s*\([^)]+\):\s*'),
          '',
        )
        .trim();

    // Parse and format the SQL more intelligently
    return _formatSql(cleaned);
  }

  /// Formats SQL by parsing it into logical sections
  static String _formatSql(String sql) {
    final upperSql = sql.toUpperCase();

    // Handle INSERT queries
    if (upperSql.contains(RegExp(r'\bINSERT\s+INTO\b'))) {
      return _formatInsert(sql);
    }

    // Handle UPDATE queries
    if (upperSql.contains(RegExp(r'\bUPDATE\b'))) {
      return _formatUpdate(sql);
    }

    // Handle SELECT queries
    final selectMatch = RegExp(
      r'\bSELECT\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (selectMatch != null) {
      return _formatSelect(sql, selectMatch);
    }

    // Unknown query type, return as-is
    return sql;
  }

  /// Formats SELECT queries
  static String _formatSelect(String sql, RegExpMatch selectMatch) {
    final result = StringBuffer();

    // Add SELECT keyword
    result.writeln('SELECT');

    // Parse SELECT columns (everything between SELECT and FROM)
    final fromMatch = RegExp(r'\bFROM\b', caseSensitive: false).firstMatch(sql);
    if (fromMatch != null) {
      final selectEnd = selectMatch.end;
      final fromStart = fromMatch.start;
      final columnsStr = sql.substring(selectEnd, fromStart).trim();

      // Split columns by comma, but respect quoted strings
      final columns = _splitColumns(columnsStr);
      for (int j = 0; j < columns.length; j++) {
        final column = columns[j].trim();
        if (column.isNotEmpty) {
          result.write('  $column');
          if (j < columns.length - 1) {
            result.write(',');
          }
          result.writeln();
        }
      }
    }

    // Parse FROM clause and beyond
    if (fromMatch != null) {
      final remaining = sql.substring(fromMatch.start).trim();
      result.writeln(_formatFromAndBeyond(remaining));
    }

    return result.toString().trim();
  }

  /// Formats INSERT queries
  static String _formatInsert(String sql) {
    final result = StringBuffer();

    // Match INSERT INTO "table" (columns) VALUES (values) RETURNING ...
    final insertMatch = RegExp(
      r'\bINSERT\s+INTO\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (insertMatch == null) return sql;

    result.write('INSERT INTO');

    // Find table name (quoted identifier after INTO)
    final afterInto = sql.substring(insertMatch.end).trim();
    final tableMatch = RegExp(r'^("[^"]+"|\w+)').firstMatch(afterInto);
    if (tableMatch != null) {
      result.writeln(' ${tableMatch.group(0)}');
    }

    // Find column list in parentheses
    final columnsMatch = RegExp(r'\(([^)]+)\)').firstMatch(afterInto);
    if (columnsMatch != null) {
      final columnsStr = columnsMatch.group(1)!;
      final columns = _splitColumns(columnsStr);
      result.writeln('(');
      for (int i = 0; i < columns.length; i++) {
        final column = columns[i].trim();
        if (column.isNotEmpty) {
          result.write('  $column');
          if (i < columns.length - 1) {
            result.write(',');
          }
          result.writeln();
        }
      }
      result.write(')');
    }

    // Find VALUES clause
    final valuesMatch = RegExp(
      r'\bVALUES\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (valuesMatch != null) {
      result.writeln();
      result.write('VALUES');

      // Find the values list (everything between VALUES and RETURNING or end)
      final afterValues = sql.substring(valuesMatch.end).trim();
      final returningMatch = RegExp(
        r'\bRETURNING\b',
        caseSensitive: false,
      ).firstMatch(afterValues);

      final valuesEnd = returningMatch?.start ?? afterValues.length;
      final valuesStr = afterValues.substring(0, valuesEnd).trim();

      // Format values (handle parentheses)
      if (valuesStr.startsWith('(') && valuesStr.endsWith(')')) {
        final innerValues = valuesStr.substring(1, valuesStr.length - 1);
        final values = _splitColumns(innerValues);

        // Check if values are simple (parameters or DEFAULT) - keep on one line
        final areSimpleValues = values.every((v) => _isSimpleValue(v.trim()));

        if (areSimpleValues) {
          // Keep simple values on one line
          result.write(' ($innerValues)');
        } else {
          // Format complex values across multiple lines
          result.writeln(' (');
          for (int i = 0; i < values.length; i++) {
            final value = values[i].trim();
            if (value.isNotEmpty) {
              result.write('  $value');
              if (i < values.length - 1) {
                result.write(',');
              }
              result.writeln();
            }
          }
          result.write(')');
        }
      } else {
        result.write(' $valuesStr');
      }
    }

    // Handle RETURNING clause
    final returningMatch = RegExp(
      r'\bRETURNING\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (returningMatch != null) {
      _formatReturning(result, sql, returningMatch);
    }

    return result.toString().trim();
  }

  /// Formats UPDATE queries
  static String _formatUpdate(String sql) {
    final result = StringBuffer();

    // Match UPDATE "table" SET ... WHERE ... RETURNING ...
    final updateMatch = RegExp(
      r'\bUPDATE\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (updateMatch == null) return sql;

    result.write('UPDATE');

    // Find table name (quoted identifier after UPDATE)
    final afterUpdate = sql.substring(updateMatch.end).trim();
    final tableMatch = RegExp(r'^("[^"]+"|\w+)').firstMatch(afterUpdate);
    if (tableMatch != null) {
      result.writeln(' ${tableMatch.group(0)}');
    }

    // Find SET clause
    final setMatch = RegExp(
      r'\bSET\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (setMatch != null) {
      result.write('SET');

      // Find everything between SET and WHERE/RETURNING/end
      final afterSet = sql.substring(setMatch.end).trim();
      final whereMatch = RegExp(
        r'\bWHERE\b',
        caseSensitive: false,
      ).firstMatch(afterSet);
      final returningMatch = RegExp(
        r'\bRETURNING\b',
        caseSensitive: false,
      ).firstMatch(afterSet);

      final setEnd =
          whereMatch?.start ?? returningMatch?.start ?? afterSet.length;
      final setClause = afterSet.substring(0, setEnd).trim();

      // Split SET assignments by comma, but respect quoted strings and operators
      final assignments = _splitSetAssignments(setClause);
      result.writeln();
      for (int i = 0; i < assignments.length; i++) {
        final assignment = assignments[i].trim();
        if (assignment.isNotEmpty) {
          result.write('  $assignment');
          if (i < assignments.length - 1) {
            result.write(',');
          }
          result.writeln();
        }
      }
    }

    // Handle WHERE clause
    final whereMatch = RegExp(
      r'\bWHERE\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (whereMatch != null) {
      result.writeln();
      result.write('WHERE');

      final afterWhere = sql.substring(whereMatch.end).trim();
      final returningMatch = RegExp(
        r'\bRETURNING\b',
        caseSensitive: false,
      ).firstMatch(afterWhere);

      final whereEnd = returningMatch?.start ?? afterWhere.length;
      final whereClause = afterWhere.substring(0, whereEnd).trim();

      // Format WHERE clause with proper indentation for AND/OR
      final formattedWhere = _formatWhereClause(whereClause);
      result.writeln(' $formattedWhere');
    }

    // Handle RETURNING clause
    final returningMatch = RegExp(
      r'\bRETURNING\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (returningMatch != null) {
      _formatReturning(result, sql, returningMatch);
    }

    return result.toString().trim();
  }

  /// Splits SET assignments respecting quoted strings and operators
  static List<String> _splitSetAssignments(String setClause) {
    final assignments = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    int parenDepth = 0;

    for (int i = 0; i < setClause.length; i++) {
      final char = setClause[i];

      if (char == '"' && (i == 0 || setClause[i - 1] != '\\')) {
        inQuotes = !inQuotes;
        buffer.write(char);
      } else if (!inQuotes && char == '(') {
        parenDepth++;
        buffer.write(char);
      } else if (!inQuotes && char == ')') {
        parenDepth--;
        buffer.write(char);
      } else if (!inQuotes && parenDepth == 0 && char == ',') {
        final assignment = buffer.toString().trim();
        if (assignment.isNotEmpty) {
          assignments.add(assignment);
        }
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    final lastAssignment = buffer.toString().trim();
    if (lastAssignment.isNotEmpty) {
      assignments.add(lastAssignment);
    }

    return assignments;
  }

  /// Formats WHERE clause with proper indentation for AND/OR
  static String _formatWhereClause(String whereClause) {
    // Replace AND/OR with newlines and proper indentation
    final formatted = whereClause
        .replaceAll(RegExp(r'\bAND\b', caseSensitive: false), '\n  AND')
        .replaceAll(RegExp(r'\bOR\b', caseSensitive: false), '\n  OR')
        .trim();

    return formatted;
  }

  /// Checks if a value is simple (parameter, DEFAULT, number, quoted string, NULL)
  /// Simple values don't contain operators, function calls, or complex expressions
  static bool _isSimpleValue(String value) {
    final trimmed = value.trim();

    // Empty values are considered simple
    if (trimmed.isEmpty) return true;

    // Parameters like $1, $2, etc.
    if (RegExp(r'^\$\d+$').hasMatch(trimmed)) return true;

    // DEFAULT keyword
    if (trimmed.toUpperCase() == 'DEFAULT') return true;

    // NULL
    if (trimmed.toUpperCase() == 'NULL') return true;

    // Simple numbers (integer or decimal)
    if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(trimmed)) return true;

    // Simple quoted strings/identifiers (no expressions inside)
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      // Check if it's just a quoted identifier/string (no operators, functions, etc.)
      final inner = trimmed.substring(1, trimmed.length - 1);
      // If inner contains operators or function-like patterns, it's complex
      if (inner.contains(RegExp(r'[+\-*/()]'))) return false;
      return true;
    }

    // If it contains operators (outside of quotes), it's complex
    // Simple check: if it has operators and isn't quoted, it's complex
    if (trimmed.contains(RegExp(r'[+\-*/]'))) {
      // Check if operators are inside quotes
      int quoteCount = 0;
      int singleQuoteCount = 0;
      for (int i = 0; i < trimmed.length; i++) {
        final char = trimmed[i];
        if (char == '"' && (i == 0 || trimmed[i - 1] != '\\')) {
          quoteCount++;
        } else if (char == "'" && (i == 0 || trimmed[i - 1] != '\\')) {
          singleQuoteCount++;
        } else if (RegExp(r'[+\-*/]').hasMatch(char)) {
          // If we find an operator and we're not inside quotes, it's complex
          if (quoteCount % 2 == 0 && singleQuoteCount % 2 == 0) {
            return false;
          }
        }
      }
    }

    // Check for function calls (word followed by opening parenthesis)
    if (RegExp(r'[a-zA-Z_][a-zA-Z0-9_]*\s*\(').hasMatch(trimmed)) {
      return false;
    }

    // Default to simple if no complex patterns detected
    return true;
  }

  /// Checks if a column name is simple (quoted identifier or simple name)
  static bool _isSimpleColumn(String column) {
    final trimmed = column.trim();

    // Empty columns are considered simple
    if (trimmed.isEmpty) return true;

    // Quoted identifiers are simple
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      return true;
    }

    // Simple unquoted identifiers (alphanumeric and underscore)
    if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(trimmed)) {
      return true;
    }

    // If it contains operators, functions, or other complex patterns, it's not simple
    if (trimmed.contains(RegExp(r'[+\-*/()]'))) {
      return false;
    }

    return true;
  }

  /// Formats RETURNING clause, keeping simple columns on one line
  static void _formatReturning(
    StringBuffer result,
    String sql,
    RegExpMatch returningMatch,
  ) {
    result.writeln();
    result.write('RETURNING');

    final afterReturning = sql.substring(returningMatch.end).trim();
    // Remove trailing semicolon if present
    final returningContent = afterReturning.replaceFirst(RegExp(r';?\s*$'), '');

    if (returningContent == '*') {
      result.write(' *');
    } else {
      final columns = _splitColumns(returningContent);
      // Check if all columns are simple (quoted identifiers or simple names)
      final areSimpleColumns = columns.every(
        (col) => _isSimpleColumn(col.trim()),
      );

      if (areSimpleColumns) {
        // Keep simple columns on one line
        result.write(' $returningContent');
      } else {
        // Format complex columns across multiple lines
        if (columns.length > 1) {
          result.writeln();
          for (int i = 0; i < columns.length; i++) {
            final column = columns[i].trim();
            if (column.isNotEmpty) {
              result.write('  $column');
              if (i < columns.length - 1) {
                result.write(',');
              }
              result.writeln();
            }
          }
        } else {
          result.write(' $returningContent');
        }
      }
    }
  }

  /// Splits column list respecting quoted strings
  static List<String> _splitColumns(String columnsStr) {
    final columns = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    int depth = 0;

    for (int i = 0; i < columnsStr.length; i++) {
      final char = columnsStr[i];

      if (char == '"' && (i == 0 || columnsStr[i - 1] != '\\')) {
        inQuotes = !inQuotes;
        buffer.write(char);
      } else if (!inQuotes && char == '(') {
        depth++;
        buffer.write(char);
      } else if (!inQuotes && char == ')') {
        depth--;
        buffer.write(char);
      } else if (!inQuotes && depth == 0 && char == ',') {
        final col = buffer.toString().trim();
        if (col.isNotEmpty) {
          columns.add(col);
        }
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    final lastCol = buffer.toString().trim();
    if (lastCol.isNotEmpty) {
      columns.add(lastCol);
    }

    return columns;
  }

  /// Formats FROM clause and everything after it
  static String _formatFromAndBeyond(String sql) {
    final lines = <String>[];

    // Replace multi-word keywords first
    final String formatted = sql
        .replaceAll(
          RegExp(r'\bLEFT\s+OUTER\s+JOIN\b', caseSensitive: false),
          '\nLEFT OUTER JOIN',
        )
        .replaceAll(
          RegExp(r'\bRIGHT\s+OUTER\s+JOIN\b', caseSensitive: false),
          '\nRIGHT OUTER JOIN',
        )
        .replaceAll(
          RegExp(r'\bFULL\s+OUTER\s+JOIN\b', caseSensitive: false),
          '\nFULL OUTER JOIN',
        )
        .replaceAll(
          RegExp(r'\bINNER\s+JOIN\b', caseSensitive: false),
          '\nINNER JOIN',
        )
        .replaceAll(
          RegExp(r'\bORDER\s+BY\b', caseSensitive: false),
          '\nORDER BY',
        )
        .replaceAll(
          RegExp(r'\bGROUP\s+BY\b', caseSensitive: false),
          '\nGROUP BY',
        )
        .replaceAll(RegExp(r'\bFROM\b', caseSensitive: false), '\nFROM')
        .replaceAll(RegExp(r'\bWHERE\b', caseSensitive: false), '\nWHERE')
        .replaceAll(RegExp(r'\bON\b', caseSensitive: false), '\n  ON')
        .replaceAll(RegExp(r'\bAND\b', caseSensitive: false), '\n  AND')
        .replaceAll(RegExp(r'\bOR\b', caseSensitive: false), '\n  OR')
        .replaceAll(RegExp(r'\bHAVING\b', caseSensitive: false), '\nHAVING')
        .replaceAll(RegExp(r'\bLIMIT\b', caseSensitive: false), '\nLIMIT')
        .replaceAll(RegExp(r'\bOFFSET\b', caseSensitive: false), '\nOFFSET')
        .replaceAll(RegExp(r'\bAS\b', caseSensitive: false), ' AS')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n+'), '\n')
        .trim();

    // Process lines with proper indentation
    final splitLines = formatted.split('\n');
    bool inJoin = false;

    for (final line in splitLines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final upper = trimmed.toUpperCase();

      if (upper.startsWith('FROM')) {
        inJoin = false;
        lines.add(trimmed);
      } else if (upper.contains('JOIN')) {
        inJoin = true;
        lines.add('  $trimmed');
      } else if (inJoin && upper.startsWith('ON')) {
        lines.add('    $trimmed');
      } else if (inJoin &&
          (upper.startsWith('AND') || upper.startsWith('OR'))) {
        lines.add('    $trimmed');
      } else if (upper.startsWith('WHERE') ||
          upper.startsWith('ORDER') ||
          upper.startsWith('GROUP') ||
          upper.startsWith('HAVING') ||
          upper.startsWith('LIMIT') ||
          upper.startsWith('OFFSET')) {
        inJoin = false;
        lines.add(trimmed);
      } else if (inJoin) {
        lines.add('    $trimmed');
      } else {
        lines.add(trimmed);
      }
    }

    return lines.join('\n');
  }

  /// Adds color highlighting to SQL using the provided or default colors
  static String addColors(String sql, {SqlFormatterColors? colorScheme}) {
    final c = colorScheme ?? colors;

    // List of keywords to highlight
    final keywords = [
      'SELECT',
      'INSERT',
      'INTO',
      'UPDATE',
      'DELETE',
      'FROM',
      'WHERE',
      'SET',
      'VALUES',
      'RETURNING',
      'JOIN',
      'LEFT',
      'RIGHT',
      'FULL',
      'OUTER',
      'INNER',
      'ON',
      'AND',
      'OR',
      'ORDER',
      'BY',
      'GROUP',
      'HAVING',
      'LIMIT',
      'OFFSET',
      'AS',
      'IN',
      'IS',
      'NOT',
      'NULL',
      'LIKE',
      'ILIKE',
    ];

    // Combined regex for all tokens:
    // 1. Quoted identifiers: "..."
    // 2. Keywords: word boundaries
    // 3. Operators: including arrows
    // 4. Numbers: integer and decimal
    final pattern = RegExp(
      '('
      r'"[^"]*"'
      '|'
      '\\b(?:${keywords.join('|')})\\b'
      '|'
      r'[=<>!]+'
      '|'
      r'\b\d+(?:\.\d+)?\b'
      ')',
      caseSensitive: false,
    );

    return sql.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final token = match.group(0)!;
        final upperToken = token.toUpperCase();

        // 1. Handle Quoted identifiers
        if (token.startsWith('"')) {
          return '${c.identifier}$token${c.reset}';
        }

        // 2. Handle Keywords
        if (keywords.contains(upperToken)) {
          return '${c.keyword}$token${c.reset}';
        }

        // 3. Handle Operators
        if (RegExp(r'[=<>!]+').hasMatch(token)) {
          return '${c.operator}$token${c.reset}';
        }

        // 4. Handle Numbers (use operator color for now or add a new one)
        if (RegExp(r'^\d+(\.\d+)?$').hasMatch(token)) {
          return '${c.operator}$token${c.reset}';
        }

        return token;
      },
      onNonMatch: (String nonMatch) => nonMatch,
    );
  }

  /// Formats and prints SQL with colors
  static void printFormatted(
    String sql, {
    String? prefix,
    SqlFormatterColors? colorScheme,
  }) {
    final formatted = format(sql);
    final colored = addColors(formatted, colorScheme: colorScheme);
    if (prefix != null) {
      print('$prefix\n$colored');
    } else {
      print(colored);
    }
  }
}
