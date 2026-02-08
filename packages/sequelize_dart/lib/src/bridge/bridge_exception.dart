import 'package:sequelize_dart/src/utils/ansi_colors.dart';

/// Exception thrown by the bridge
class BridgeException implements Exception {
  final String message;
  final int? code;
  final String? stack;
  final String? context;

  BridgeException(this.message, {this.code, this.stack, this.context}) {
    _formattedStack = stack ?? StackTrace.current.toString();
  }

  late final String _formattedStack;

  @override
  String toString() {
    final buffer = StringBuffer('\n');

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

    // 2. Print Main Header
    buffer.write(AnsiColor.brightRed.wrap('BridgeException: '));
    buffer.writeln(AnsiColor.yellow.wrap(message));

    // 3. Print Code
    if (code != null) {
      buffer.write('${AnsiColor.brightBlack.wrap('Code:')} ');
      buffer.writeln(AnsiColor.cyan.wrap(code.toString()));
    }

    // 4. Print StackTrace (No arrows, standard spacing)
    if (_formattedStack.isNotEmpty) {
      buffer.writeln(AnsiColor.brightBlack.wrap('StackTrace:'));
      final lines = _formattedStack.trim().split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        // Skip lines that don't look like frames
        if (!trimmed.startsWith('at ') &&
            !trimmed.startsWith('#') &&
            !trimmed.contains('(package:')) {
          continue;
        }

        String formattedLine = trimmed;
        if (trimmed.startsWith('#')) {
          formattedLine = trimmed.replaceFirst(RegExp(r'^#\d+\s+'), '');
        }

        buffer.writeln(AnsiColor.brightBlack.wrap(formattedLine));
      }
    }

    return buffer.toString().trim();
  }
}
