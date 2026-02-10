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
  bold('\x1B[1m'),
  underline('\x1B[4m'),
  none('');

  final String code;
  const AnsiColor(this.code);

  @override
  String toString() => code;

  /// Wrap text in this color
  String wrap(String text) {
    if (this == AnsiColor.none) return text;
    return '$code$text${AnsiColor.reset.code}';
  }
}

/// Helper for colored printing
class ColoredPrint {
  static void red(String message) => print(AnsiColor.red.wrap(message));
  static void green(String message) => print(AnsiColor.green.wrap(message));
  static void yellow(String message) => print(AnsiColor.yellow.wrap(message));
  static void blue(String message) => print(AnsiColor.blue.wrap(message));
  static void magenta(String message) => print(AnsiColor.magenta.wrap(message));
  static void cyan(String message) => print(AnsiColor.cyan.wrap(message));
  static void bold(String message) => print(AnsiColor.bold.wrap(message));
}
