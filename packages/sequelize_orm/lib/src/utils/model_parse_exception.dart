// ignore_for_file: avoid_print

/// Exception thrown when model JSON parsing fails.
class ModelParseException implements Exception {
  final String model;
  final String operation;
  final String key;
  final String expectedType;
  final String actualType;
  final String actualValue;
  final int? rowIndex;
  final Object? originalError;

  ModelParseException({
    required this.model,
    required this.operation,
    required this.key,
    required this.expectedType,
    required this.actualType,
    required this.actualValue,
    this.rowIndex,
    this.originalError,
  });

  static const _r = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _y = '\x1B[33m';
  static const _c = '\x1B[36m';
  static const _g = '\x1B[90m';
  static const _b = '\x1B[1m';

  @override
  String toString() {
    final row = rowIndex != null ? ' ${_g}row=$_r$rowIndex' : '';
    return '$_red${_b}ModelParseError:$_r field=$_y$key$_r model=$_c$model$_r op=$_c$operation$_r expected=$_b$expectedType$_r got=$_red$actualType$_r($_red"$actualValue"$_r)$row';
  }
}
