import 'package:sequelize_dart/src/utils/ansi_colors.dart';
import 'package:sequelize_dart/src/utils/sql_formatter.dart';

/// Base class for all Sequelize related exceptions
class SequelizeException implements Exception {
  final String message;
  final String? name;
  final int? code;
  final String? stack;
  final String? sql;
  final Map<String, dynamic>? original;

  /// Optional context (e.g., "Exception: failed to execute findAll()")
  final String? context;

  SequelizeException(
    this.message, {
    this.name,
    this.code,
    this.stack,
    this.sql,
    this.original,
    this.context,
  });

  /// Create a copy of this exception with a different context
  SequelizeException copyWithContext(String newContext) {
    return _createSubclass(
      name ?? 'SequelizeException',
      message,
      code: code,
      stack: stack,
      sql: sql,
      original: original,
      context: newContext,
    );
  }

  /// Parse a bridge error response into a typed SequelizeException
  factory SequelizeException.fromBridge(Map<String, dynamic> error) {
    final String name = error['name'] as String? ?? 'SequelizeBaseError';
    final String message = error['message'] as String? ?? 'Unknown error';
    final int? code = error['code'] as int?;
    final String? stack = error['stack'] as String?;
    final String? sql = error['sql'] as String?;
    final Map<String, dynamic>? original = error['original'] != null
        ? Map<String, dynamic>.from(error['original'])
        : null;

    return _createSubclass(
      name,
      message,
      code: code,
      stack: stack,
      sql: sql,
      original: original,
    );
  }

  static SequelizeException _createSubclass(
    String name,
    String message, {
    int? code,
    String? stack,
    String? sql,
    Map<String, dynamic>? original,
    String? context,
  }) {
    switch (name) {
      case 'SequelizeDatabaseError':
        return SequelizeDatabaseError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeValidationError':
        return SequelizeValidationError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeUniqueConstraintError':
        return SequelizeUniqueConstraintError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeForeignKeyConstraintError':
        return SequelizeForeignKeyConstraintError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeEagerLoadingError':
        return SequelizeEagerLoadingError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeConnectionError':
        return SequelizeConnectionError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeTimeoutError':
        return SequelizeTimeoutError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeHostNotFoundError':
        return SequelizeHostNotFoundError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeHostNotReachableError':
        return SequelizeHostNotReachableError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeInvalidConnectionError':
        return SequelizeInvalidConnectionError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeConnectionRefusedError':
        return SequelizeConnectionRefusedError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeEmptyResultError':
        return SequelizeEmptyResultError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      case 'SequelizeOptimisticLockError':
        return SequelizeOptimisticLockError(
          message,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
      default:
        return SequelizeException(
          message,
          name: name,
          code: code,
          stack: stack,
          sql: sql,
          original: original,
          context: context,
        );
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln(
      AnsiColor.red.wrap("${'=' * 20} SEQUELIZE ERROR ${'=' * 20}"),
    );

    // 1. Print Context if available
    if (context != null && context!.isNotEmpty) {
      if (context!.contains(':')) {
        final parts = context!.split(':');
        buffer.write(AnsiColor.brightRed.wrap('${parts[0].trim()}: '));
        buffer.writeln(
          AnsiColor.yellow.wrap(parts.sublist(1).join(':').trim()),
        );
      } else {
        buffer.writeln(AnsiColor.brightRed.wrap(context!));
      }
    }

    // 2. Print Main Exception Header (Special case for context wrapper)
    final errorName = name ?? runtimeType.toString();
    if (errorName != 'SequelizeException' || context == null) {
      buffer.write(AnsiColor.brightRed.wrap('$errorName: '));
      buffer.writeln(AnsiColor.yellow.wrap(message));
    }

    // 3. Print Code
    if (code != null && code != -32603) {
      buffer.write('${AnsiColor.brightBlack.wrap('Code:')} ');
      buffer.writeln(AnsiColor.cyan.wrap(code.toString()));
    }

    // 4. Print Original Error Details
    if (original != null) {
      final originalMsg = original!['message'] as String?;
      if (originalMsg != null && !message.contains(originalMsg)) {
        buffer.write('${AnsiColor.brightBlack.wrap('Reason:')} ');
        buffer.writeln(AnsiColor.yellow.wrap(originalMsg));
      }
    }

    // 5. Print SQL Details
    if (sql != null) {
      buffer.write('${AnsiColor.brightBlue.wrap('SQL:')} ');
      final cleanedSql = sql!.replaceAll(RegExp(r'\s+'), ' ').trim();
      buffer.writeln(SqlFormatter.addColors(cleanedSql));
    }

    // 6. Print StackTrace (No arrows, clean standard format)
    // if (_formattedStack.isNotEmpty) {
    //   buffer.writeln(AnsiColor.brightBlack.wrap('StackTrace:'));
    //   final lines = _formattedStack.trim().split('\n');
    //   for (final line in lines) {
    //     final trimmed = line.trim();
    //     if (trimmed.isEmpty) continue;

    //     // Skip lines that don't look like frames
    //     if (!trimmed.startsWith('at ') &&
    //         !trimmed.startsWith('#') &&
    //         !trimmed.contains('(package:')) {
    //       continue;
    //     }

    //     String formattedLine = trimmed;
    //     if (trimmed.startsWith('#')) {
    //       formattedLine = trimmed.replaceFirst(RegExp(r'^#\d+\s+'), '');
    //     }

    //     buffer.writeln(AnsiColor.brightBlack.wrap(formattedLine));
    //   }
    // }

    return buffer.toString().trim();
  }
}

class SequelizeDatabaseError extends SequelizeException {
  SequelizeDatabaseError(
    super.message, {
    super.name = 'SequelizeDatabaseError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeValidationError extends SequelizeException {
  SequelizeValidationError(
    super.message, {
    super.name = 'SequelizeValidationError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeUniqueConstraintError extends SequelizeValidationError {
  SequelizeUniqueConstraintError(
    super.message, {
    super.name = 'SequelizeUniqueConstraintError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeForeignKeyConstraintError extends SequelizeException {
  SequelizeForeignKeyConstraintError(
    super.message, {
    super.name = 'SequelizeForeignKeyConstraintError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeEagerLoadingError extends SequelizeException {
  SequelizeEagerLoadingError(
    super.message, {
    super.name = 'SequelizeEagerLoadingError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeConnectionError extends SequelizeException {
  SequelizeConnectionError(
    super.message, {
    super.name = 'SequelizeConnectionError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeTimeoutError extends SequelizeException {
  SequelizeTimeoutError(
    super.message, {
    super.name = 'SequelizeTimeoutError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeHostNotFoundError extends SequelizeConnectionError {
  SequelizeHostNotFoundError(
    super.message, {
    super.name = 'SequelizeHostNotFoundError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeHostNotReachableError extends SequelizeConnectionError {
  SequelizeHostNotReachableError(
    super.message, {
    super.name = 'SequelizeHostNotReachableError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeInvalidConnectionError extends SequelizeConnectionError {
  SequelizeInvalidConnectionError(
    super.message, {
    super.name = 'SequelizeInvalidConnectionError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeConnectionRefusedError extends SequelizeConnectionError {
  SequelizeConnectionRefusedError(
    super.message, {
    super.name = 'SequelizeConnectionRefusedError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeEmptyResultError extends SequelizeException {
  SequelizeEmptyResultError(
    super.message, {
    super.name = 'SequelizeEmptyResultError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}

class SequelizeOptimisticLockError extends SequelizeException {
  SequelizeOptimisticLockError(
    super.message, {
    super.name = 'SequelizeOptimisticLockError',
    super.code,
    super.stack,
    super.sql,
    super.original,
    super.context,
  });
}
