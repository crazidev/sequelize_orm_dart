// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:sequelize_orm/src/types/sequelize_big_int.dart';
import 'package:sequelize_orm/src/utils/model_parse_exception.dart';

/// Fast-path typed parsers. Zero allocation on the happy path.
/// Each returns null for null input, the parsed value on success,
/// or throws [FormatException] on type mismatch.

int? parseIntValue(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  throw FormatException('Expected int, got ${v.runtimeType}');
}

SequelizeBigInt? parseSequelizeBigIntValue(dynamic v) {
  if (v == null) return null;
  if (v is String) return SequelizeBigInt(v);
  if (v is int) return SequelizeBigInt.fromInt(v);
  throw FormatException('Expected String or int for BigInt, got ${v.runtimeType}');
}

double? parseDoubleValue(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble(); // JSON doesn't distinguish int/double
  throw FormatException('Expected double, got ${v.runtimeType}');
}

bool? parseBoolValue(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is int) {
    if (v == 1) return true;
    if (v == 0) return false;
  }
  throw FormatException('Expected bool, got ${v.runtimeType}');
}

DateTime? parseDateTimeValue(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.parse(v); // Bridge returns ISO-8601 strings
  throw FormatException('Expected DateTime, got ${v.runtimeType}');
}

String? parseStringValue(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  throw FormatException('Expected String, got ${v.runtimeType}');
}

Map<String, dynamic>? parseMapValue(dynamic v) {
  if (v == null) return null;
  if (v is Map) return Map<String, dynamic>.from(v);
  if (v is String) return Map<String, dynamic>.from(jsonDecode(v) as Map); // Bridge may return JSON columns as strings
  throw FormatException('Expected Map, got ${v.runtimeType}');
}

List<int>? parseBlobValue(dynamic v) {
  if (v == null) return null;
  if (v is List) return List<int>.from(v);
  throw FormatException('Expected List, got ${v.runtimeType}');
}

/// Parses a JSON list value with typed elements.
///
/// Handles the bridge returning JSON columns as strings by running [jsonDecode].
/// The generator emits instantiated tear-offs: `parseJsonList<String>`,
/// `parseJsonList<int>`, `parseJsonList<Map<String, dynamic>>`, etc.
List<T>? parseJsonList<T>(dynamic v) {
  if (v == null) return null;
  if (v is String) v = jsonDecode(v);
  if (v is List) return List<T>.from(v);
  throw FormatException('Expected List<$T>, got ${v.runtimeType}');
}

/// Parses a JSON map value with typed values.
///
/// Handles the bridge returning JSON columns as strings by running [jsonDecode].
/// The generator emits instantiated tear-offs: `parseJsonMap<dynamic>`,
/// `parseJsonMap<String>`, `parseJsonMap<int>`, etc.
Map<String, T>? parseJsonMap<T>(dynamic v) {
  if (v == null) return null;
  if (v is String) v = jsonDecode(v);
  if (v is Map) return Map<String, T>.from(v);
  throw FormatException('Expected Map<String, $T>, got ${v.runtimeType}');
}

/// Generic field parser with error context.
/// Wraps a typed parser and catches failures with rich diagnostics.
///
/// Used by generated fromJson() code. The [parse] function is one of the
/// typed helpers above. Only allocates error context on the exception path.
T? parseField<T>(
  dynamic value,
  T? Function(dynamic) parse, {
  required String model,
  required String key,
  required String expectedType,
  required String operation,
  int? rowIndex,
}) {
  try {
    return parse(value);
  } catch (e, stack) {
    // Skip parseField + _p frames so the trace starts at fromJson.
    final filtered = _filterStack(stack);
    Error.throwWithStackTrace(
      ModelParseException(
        model: model,
        operation: operation,
        key: key,
        expectedType: expectedType,
        actualType: value.runtimeType.toString(),
        actualValue: _truncate(value?.toString() ?? 'null', 100),
        rowIndex: rowIndex,
        originalError: e,
      ),
      filtered,
    );
  }
}

String _truncate(String s, int max) =>
    s.length > max ? '${s.substring(0, max)}...' : s;

/// Strips internal parseField / _p frames and renumbers from #0.
StackTrace _filterStack(StackTrace stack) {
  final lines = stack.toString().split('\n');
  final filtered = lines.where((line) {
    return !line.contains('parseField') &&
        !line.contains('parse_helpers.dart') &&
        !line.contains('._p ');
  }).toList();
  // Renumber #N frames starting from 0
  var index = 0;
  final renumbered = filtered.map((line) {
    return line.replaceFirstMapped(
      RegExp(r'^#\d+\s'),
      (m) => '#${index++} ',
    );
  }).toList();
  return StackTrace.fromString(renumbered.join('\n'));
}
