/// SQL formatter utility for pretty-printing SQL queries with syntax highlighting
library;

/// ANSI color codes for terminal output
enum AnsiColor {
  reset('\x1B[0m'),
  black('\x1B[30m'),
  red('\x1B[31m'),
  green('\x1B[32m'),
  yellow('\x1B[33m'),
  blue('\x1B[34m'),
  magenta('\x1B[35m'),
  cyan('\x1B[36m'),
  white('\x1B[37m'),
  brightBlack('\x1B[90m'),
  brightRed('\x1B[91m'),
  brightGreen('\x1B[92m'),
  brightYellow('\x1B[93m'),
  brightBlue('\x1B[94m'),
  brightMagenta('\x1B[95m'),
  brightCyan('\x1B[96m'),
  brightWhite('\x1B[97m'),
  none('');

  final String code;
  const AnsiColor(this.code);

  @override
  String toString() => code;
}

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
    final result = StringBuffer();

    // Find SELECT clause
    final selectMatch = RegExp(
      r'\bSELECT\b',
      caseSensitive: false,
    ).firstMatch(sql);
    if (selectMatch == null) {
      return sql; // Not a SELECT query, return as-is
    }

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
      'FROM',
      'WHERE',
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
