import 'package:analyzer/dart/ast/ast.dart';

/// Helper utilities for analyzing and suggesting association parameters.
class AssociationHelpers {
  /// Extracts the @Table annotation from a class declaration.
  static Annotation? getTableAnnotation(ClassDeclaration classDecl) {
    for (final annotation in classDecl.metadata) {
      final name = annotation.name;
      if (name is SimpleIdentifier && name.name == 'Table') {
        return annotation;
      }
    }
    return null;
  }

  /// Checks if a table uses underscored (snake_case) naming convention.
  static bool isUnderscoredTable(ClassDeclaration classDecl) {
    final tableAnnotation = getTableAnnotation(classDecl);
    if (tableAnnotation == null) return false;

    final args = tableAnnotation.arguments;
    if (args == null) return false;

    for (final arg in args.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'underscored') {
        final expression = arg.expression;
        if (expression is BooleanLiteral) {
          return expression.value;
        }
      }
    }
    return false;
  }

  /// Gets the table name from the @Table annotation.
  /// Returns null if not found, falls back to class name if tableName not specified.
  static String? getTableName(ClassDeclaration classDecl) {
    final tableAnnotation = getTableAnnotation(classDecl);
    if (tableAnnotation == null) return null;

    final args = tableAnnotation.arguments;
    if (args == null) return classDecl.name.lexeme.toLowerCase();

    for (final arg in args.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'tableName') {
        final expression = arg.expression;
        if (expression is StringLiteral) {
          return expression.stringValue;
        }
      }
    }

    // Default to class name in lowercase
    return classDecl.name.lexeme.toLowerCase();
  }

  /// Simple singularization - removes trailing 's'.
  /// For more complex cases, consider using a proper inflection library.
  static String toSingular(String word) {
    if (word.isEmpty) return word;

    // Handle common irregular plurals
    final irregulars = {
      'posts': 'post',
      'users': 'user',
      'comments': 'comment',
      'categories': 'category',
      'entries': 'entry',
    };

    if (irregulars.containsKey(word.toLowerCase())) {
      return irregulars[word.toLowerCase()]!;
    }

    // Simple rule: remove trailing 's'
    if (word.endsWith('s') && word.length > 1) {
      return word.substring(0, word.length - 1);
    }

    return word;
  }

  /// Simple pluralization - adds 's'.
  /// For more complex cases, consider using a proper inflection library.
  static String toPlural(String word) {
    if (word.isEmpty) return word;

    // Handle common irregular singulars
    final irregulars = {
      'post': 'posts',
      'user': 'users',
      'comment': 'comments',
      'category': 'categories',
      'entry': 'entries',
    };

    if (irregulars.containsKey(word.toLowerCase())) {
      return irregulars[word.toLowerCase()]!;
    }

    // Simple rule: add 's'
    if (word.endsWith('y') && word.length > 1) {
      return '${word.substring(0, word.length - 1)}ies';
    }

    return '${word}s';
  }

  /// Converts a string to camelCase.
  static String toCamelCase(String input) {
    if (input.isEmpty) return input;

    // If already camelCase, return as-is
    if (!input.contains('_')) {
      return input[0].toLowerCase() + input.substring(1);
    }

    final parts = input.split('_');
    final buffer = StringBuffer(parts[0].toLowerCase());

    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase());
        if (parts[i].length > 1) {
          buffer.write(parts[i].substring(1).toLowerCase());
        }
      }
    }

    return buffer.toString();
  }

  /// Converts a string to snake_case.
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;

    // If already snake_case, return as-is
    if (input.contains('_')) {
      return input.toLowerCase();
    }

    final buffer = StringBuffer();

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == char.toUpperCase() && i > 0) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }

    return buffer.toString();
  }

  /// Suggests a conventional foreign key name based on the source model name.
  ///
  /// Examples:
  /// - sourceModel: "User", underscored: false → "userId"
  /// - sourceModel: "User", underscored: true → "user_id"
  static String suggestForeignKey(String sourceModel, bool underscored) {
    // Convert class name to singular if needed
    final singular = toSingular(sourceModel);

    if (underscored) {
      final snakeCase = toSnakeCase(singular);
      return '${snakeCase}_id';
    } else {
      final camelCase = toCamelCase(singular);
      return '${camelCase}Id';
    }
  }

  /// Suggests a conventional relationship alias based on the table name.
  ///
  /// Examples:
  /// - tableName: "posts", isHasMany: true → "posts"
  /// - tableName: "post", isHasMany: false → "post"
  static String suggestAlias(String tableName, bool isHasMany) {
    if (isHasMany) {
      return toPlural(tableName);
    } else {
      return toSingular(tableName);
    }
  }

  /// Checks if a field with the given name exists in the class declaration.
  /// Considers both field names and @ColumnName annotations.
  static bool fieldExists(
    ClassDeclaration classDecl,
    String fieldName,
  ) {
    for (final member in classDecl.members) {
      if (member is FieldDeclaration) {
        // Check field variable name
        for (final variable in member.fields.variables) {
          if (variable.name.lexeme == fieldName) {
            return true;
          }

          // Check @ColumnName annotation
          for (final annotation in member.metadata) {
            final name = annotation.name;
            if (name is SimpleIdentifier && name.name == 'ColumnName') {
              final args = annotation.arguments;
              if (args != null && args.arguments.isNotEmpty) {
                final firstArg = args.arguments.first;
                if (firstArg is StringLiteral) {
                  final columnName = firstArg.stringValue;
                  // Convert both to same format for comparison
                  if (columnName == fieldName ||
                      toCamelCase(columnName ?? '') == fieldName ||
                      toSnakeCase(columnName ?? '') == toSnakeCase(fieldName)) {
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }
    return false;
  }
}
