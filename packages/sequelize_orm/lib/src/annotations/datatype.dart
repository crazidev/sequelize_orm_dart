// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:meta/meta.dart';

/// Base DataType class for Sequelize data types
abstract class DataType {
  /// The name of the data type (e.g., 'STRING', 'INTEGER')
  @protected
  final String name;

  const DataType._(this.name);

  /// Public accessor for the datatype name.
  ///
  /// The underlying [name] field is `@protected`, so generated / helper code
  /// should use this getter instead.
  String get typeName => name;

  /// Serializes this datatype for bridge transport.
  Map<String, dynamic> toJson() => {'type': typeName};

  // --- Integer Types ---
  static const IntegerDataType TINYINT = IntegerDataType._('TINYINT');
  static const IntegerDataType SMALLINT = IntegerDataType._('SMALLINT');
  static const IntegerDataType MEDIUMINT = IntegerDataType._('MEDIUMINT');
  static const IntegerDataType INTEGER = IntegerDataType._('INTEGER');
  static const IntegerDataType BIGINT = IntegerDataType._('BIGINT');

  // --- Decimal / Float Types ---
  static const DecimalDataType FLOAT = DecimalDataType._('FLOAT');
  static const DecimalDataType DOUBLE = DecimalDataType._('DOUBLE');
  static const DecimalDataType DECIMAL = DecimalDataType._('DECIMAL');

  // --- String Types ---
  static const StringDataType STRING = StringDataType._('STRING');
  static const StringDataType CHAR = StringDataType._('CHAR');

  // --- Text Types ---
  static const TextDataType TEXT = TextDataType._('TEXT');

  // --- Blob Types ---
  static const BlobDataType BLOB = BlobDataType._('BLOB');

  // --- Standard Types ---
  static const StandardDataType BOOLEAN = StandardDataType._('BOOLEAN');
  static const StandardDataType DATE = StandardDataType._('DATE');
  static const StandardDataType DATEONLY = StandardDataType._('DATEONLY');
  static const StandardDataType UUID = StandardDataType._('UUID');
  static const StandardDataType JSON = StandardDataType._('JSON');
  static const StandardDataType JSONB = StandardDataType._('JSONB');

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString();
}

/// Generic DataType with no extra options
class StandardDataType extends DataType {
  const StandardDataType._(super.name) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StandardDataType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

/// Integers (TINYINT, INTEGER, BIGINT)
class IntegerDataType extends DataType {
  @protected
  final int? length;
  @protected
  final bool unsigned;
  @protected
  final bool zerofill;

  const IntegerDataType._(
    super.name, {
    this.length,
    this.unsigned = false,
    this.zerofill = false,
  }) : super._();

  int? get lengthValue => length;
  bool get isUnsigned => unsigned;
  bool get isZerofill => zerofill;

  /// Support for DataType.INTEGER(10)
  IntegerDataType call([int? length]) => IntegerDataType._(
    name,
    length: length,
    unsigned: unsigned,
    zerofill: zerofill,
  );

  IntegerDataType get UNSIGNED => IntegerDataType._(
    name,
    length: length,
    unsigned: true,
    zerofill: zerofill,
  );
  IntegerDataType get ZEROFILL => IntegerDataType._(
    name,
    length: length,
    unsigned: unsigned,
    zerofill: true,
  );

  @override
  bool operator ==(Object other) =>
      other is IntegerDataType &&
      name == other.name &&
      length == other.length &&
      unsigned == other.unsigned &&
      zerofill == other.zerofill;

  @override
  int get hashCode => Object.hash(name, length, unsigned, zerofill);

  @override
  String toString() {
    String out = length != null ? '$name($length)' : name;
    if (unsigned) out += ' UNSIGNED';
    if (zerofill) out += ' ZEROFILL';
    return out;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': typeName,
    if (length != null) 'length': length,
    if (unsigned) 'unsigned': true,
    if (zerofill) 'zerofill': true,
  };
}

/// Decimals (DECIMAL, FLOAT, DOUBLE)
class DecimalDataType extends DataType {
  @protected
  final int? length; // used as precision
  @protected
  final int? scale;
  @protected
  final bool unsigned;
  @protected
  final bool zerofill;

  const DecimalDataType._(
    super.name, {
    this.length,
    this.scale,
    this.unsigned = false,
    this.zerofill = false,
  }) : super._();

  int? get precision => length;
  int? get scaleValue => scale;
  bool get isUnsigned => unsigned;
  bool get isZerofill => zerofill;

  /// Support for DataType.DECIMAL(10, 2)
  @protected
  DecimalDataType call([int? precision, int? scale]) => DecimalDataType._(
    name,
    length: precision ?? length,
    scale: scale ?? this.scale,
    unsigned: unsigned,
    zerofill: zerofill,
  );

  DecimalDataType get UNSIGNED => DecimalDataType._(
    name,
    length: length,
    scale: scale,
    unsigned: true,
    zerofill: zerofill,
  );
  DecimalDataType get ZEROFILL => DecimalDataType._(
    name,
    length: length,
    scale: scale,
    unsigned: unsigned,
    zerofill: true,
  );

  @override
  bool operator ==(Object other) =>
      other is DecimalDataType &&
      name == other.name &&
      length == other.length &&
      scale == other.scale &&
      unsigned == other.unsigned &&
      zerofill == other.zerofill;

  @override
  int get hashCode => Object.hash(name, length, scale, unsigned, zerofill);

  @override
  String toString() {
    String out = (length != null && scale != null)
        ? '$name($length, $scale)'
        : name;
    if (unsigned) out += ' UNSIGNED';
    if (zerofill) out += ' ZEROFILL';
    return out;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': typeName,
    if (length != null) 'length': length,
    if (scale != null) 'scale': scale,
    if (unsigned) 'unsigned': true,
    if (zerofill) 'zerofill': true,
  };
}

/// Strings (STRING, CHAR)
class StringDataType extends DataType {
  @protected
  final int? length;
  @protected
  final bool binary;

  const StringDataType._(
    super.name, {
    this.length,
    this.binary = false,
  }) : super._();

  int? get lengthValue => length;
  bool get isBinary => binary;

  /// Support for DataType.STRING(255)
  @protected
  StringDataType call([int? length]) =>
      StringDataType._(name, length: length, binary: binary);

  StringDataType get BINARY =>
      StringDataType._(name, length: length, binary: true);

  @override
  bool operator ==(Object other) =>
      other is StringDataType &&
      name == other.name &&
      length == other.length &&
      binary == other.binary;

  @override
  int get hashCode => Object.hash(name, length, binary);

  @override
  String toString() {
    String out = length != null ? '$name($length)' : name;
    if (binary) out += ' BINARY';
    return out;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': typeName,
    if (length != null) 'length': length,
    if (binary) 'binary': true,
  };
}

/// Text types
class TextDataType extends DataType {
  @protected
  final String? variant;

  const TextDataType._(super.name, {this.variant}) : super._();

  String? get variantValue => variant;

  TextDataType get tiny => TextDataType._(name, variant: 'tiny');
  TextDataType get medium => TextDataType._(name, variant: 'medium');
  TextDataType get long => TextDataType._(name, variant: 'long');

  @override
  bool operator ==(Object other) =>
      other is TextDataType && name == other.name && variant == other.variant;

  @override
  int get hashCode => Object.hash(name, variant);

  @override
  String toString() => variant != null ? "$name('$variant')" : name;

  @override
  Map<String, dynamic> toJson() => {
    'type': typeName,
    if (variant != null) 'variant': variant,
  };
}

/// Blob types
class BlobDataType extends DataType {
  @protected
  final String? variant;

  const BlobDataType._(super.name, {this.variant}) : super._();

  String? get variantValue => variant;

  BlobDataType get tiny => BlobDataType._(name, variant: 'tiny');
  BlobDataType get medium => BlobDataType._(name, variant: 'medium');
  BlobDataType get long => BlobDataType._(name, variant: 'long');

  @override
  bool operator ==(Object other) =>
      other is BlobDataType && name == other.name && variant == other.variant;

  @override
  int get hashCode => Object.hash(name, variant);

  @override
  String toString() => variant != null ? "$name('$variant')" : name;

  @override
  Map<String, dynamic> toJson() => {
    'type': typeName,
    if (variant != null) 'variant': variant,
  };
}
