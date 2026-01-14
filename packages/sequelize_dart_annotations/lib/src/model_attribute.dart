// ignore_for_file: non_constant_identifier_names
import 'package:meta/meta_meta.dart';
import 'package:sequelize_dart_annotations/src/datatype.dart';

/// Referential action for foreign key constraints
enum ReferentialAction {
  cascade,
  restrict,
  setDefault,
  setNull,
  noAction,
}

/// Options for unique constraint
class UniqueOption {
  /// Unique constraint name (for composite unique indexes)
  final String? name;

  /// Custom error message
  final String? msg;

  const UniqueOption({this.name, this.msg});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (msg != null) json['msg'] = msg;
    return json;
  }
}

/// Options for index
class IndexOption {
  /// Index name (for composite indexes)
  final String? name;

  const IndexOption({this.name});

  /// Create an index with a name (for composite indexes)
  const IndexOption.named(this.name);

  /// Create a simple index (no name)
  const IndexOption.simple() : name = null;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    return json;
  }
}

// ============================================================================
// Validator Base Class
// ============================================================================

/// Base class for all validators
abstract class Validator {
  const Validator();

  /// Returns the JSON representation of this validator
  Object toJson();
}

// ============================================================================
// Boolean Validators (isEmail, isUrl, isIP, etc.)
// Type: boolean | { msg: string }
// ============================================================================

/// Checks for email format (foo@bar.com)
@Target({TargetKind.field})
class IsEmail extends Validator {
  final String? msg;

  const IsEmail([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for url format (http://foo.com)
@Target({TargetKind.field})
class IsUrl extends Validator {
  final String? msg;

  const IsUrl([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for IPv4 (129.89.23.1) or IPv6 format
@Target({TargetKind.field})
class IsIP extends Validator {
  final String? msg;

  const IsIP([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for IPv4 (129.89.23.1)
@Target({TargetKind.field})
class IsIPv4 extends Validator {
  final String? msg;

  const IsIPv4([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for IPv6 format
@Target({TargetKind.field})
class IsIPv6 extends Validator {
  final String? msg;

  const IsIPv6([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Will only allow letters
@Target({TargetKind.field})
class IsAlpha extends Validator {
  final String? msg;

  const IsAlpha([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Will only allow alphanumeric characters, so "_abc" will fail
@Target({TargetKind.field})
class IsAlphanumeric extends Validator {
  final String? msg;

  const IsAlphanumeric([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Will only allow numbers
@Target({TargetKind.field})
class IsNumeric extends Validator {
  final String? msg;

  const IsNumeric([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for valid integers
@Target({TargetKind.field})
class IsInt extends Validator {
  final String? msg;

  const IsInt([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for valid floating point numbers
@Target({TargetKind.field})
class IsFloat extends Validator {
  final String? msg;

  const IsFloat([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for any numbers
@Target({TargetKind.field})
class IsDecimal extends Validator {
  final String? msg;

  const IsDecimal([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for lowercase
@Target({TargetKind.field})
class IsLowercase extends Validator {
  final String? msg;

  const IsLowercase([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Checks for uppercase
@Target({TargetKind.field})
class IsUppercase extends Validator {
  final String? msg;

  const IsUppercase([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Don't allow empty strings
@Target({TargetKind.field})
class NotEmpty extends Validator {
  final String? msg;

  const NotEmpty([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Only allow arrays
@Target({TargetKind.field})
class IsArray extends Validator {
  final String? msg;

  const IsArray([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Check for valid credit card numbers
@Target({TargetKind.field})
class IsCreditCard extends Validator {
  final String? msg;

  const IsCreditCard([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

/// Only allow date strings
@Target({TargetKind.field})
class IsDate extends Validator {
  final String? msg;

  const IsDate([this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg} : true;
}

// ============================================================================
// Pattern Validators (is, not)
// Type: string | List<String> | { msg: string, args: string | List<String> }
// ============================================================================

/// Pattern matching validator
/// - `Is('^[a-z]+\$')` will only allow letters
/// - `Is.withFlags('^[a-z]+\$', 'i')` with regex flags
/// - `Is.withMsg('^[a-z]+\$', msg: 'Only letters allowed')` with custom message
/// Pattern matching validator
@Target({TargetKind.field})
class Is extends Validator {
  final String pattern;
  final String? flags;
  final String? msg;

  /// Simple pattern match
  const Is(this.pattern, [this.msg]) : flags = null;

  /// Pattern with regex flags (e.g., 'i' for case-insensitive)
  const Is.withFlags(this.pattern, this.flags, [this.msg]);

  @override
  Object toJson() {
    if (msg != null) {
      return {
        'msg': msg,
        'args': flags != null ? [pattern, flags] : pattern,
      };
    }
    return flags != null ? [pattern, flags] : pattern;
  }
}

/// Negated pattern matching validator
/// - `Not('[a-z]')` will not allow letters
/// - `Not.withFlags('[a-z]', 'i')` with regex flags
/// Negated pattern matching validator
@Target({TargetKind.field})
class Not extends Validator {
  final String pattern;
  final String? flags;
  final String? msg;

  /// Simple pattern match
  const Not(this.pattern, [this.msg]) : flags = null;

  /// Pattern with regex flags
  const Not.withFlags(this.pattern, this.flags, [this.msg]);

  @override
  Object toJson() {
    if (msg != null) {
      return {
        'msg': msg,
        'args': flags != null ? [pattern, flags] : pattern,
      };
    }
    return flags != null ? [pattern, flags] : pattern;
  }
}

// ============================================================================
// String Validators (equals, contains, isAfter, isBefore)
// Type: string | { msg: string, args?: string }
// ============================================================================

/// Only allow a specific value
/// Only allow a specific value
@Target({TargetKind.field})
class Equals extends Validator {
  final String value;
  final String? msg;

  const Equals(this.value, [this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg, 'args': value} : value;
}

/// Force specific substrings
/// Force specific substrings
@Target({TargetKind.field})
class Contains extends Validator {
  final String value;
  final String? msg;

  const Contains(this.value, [this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg, 'args': value} : value;
}

/// Only allow date strings after a specific date
/// Only allow date strings after a specific date
@Target({TargetKind.field})
class IsAfter extends Validator {
  final String date;
  final String? msg;

  const IsAfter(this.date, [this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg, 'args': date} : date;
}

/// Only allow date strings before a specific date
/// Only allow date strings before a specific date
@Target({TargetKind.field})
class IsBefore extends Validator {
  final String date;
  final String? msg;

  const IsBefore(this.date, [this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg, 'args': date} : date;
}

// ============================================================================
// Number Validators (max, min)
// Type: number | { msg: string, args: [number] }
// ============================================================================

/// Only allow values <= max
/// Only allow values <= max
@Target({TargetKind.field})
class Max extends Validator {
  final num value;
  final String? msg;

  const Max(this.value, [this.msg]);

  @override
  Object toJson() => msg != null
      ? {
          'msg': msg,
          'args': [value],
        }
      : value;
}

/// Only allow values >= min
/// Only allow values >= min
@Target({TargetKind.field})
class Min extends Validator {
  final num value;
  final String? msg;

  const Min(this.value, [this.msg]);

  @override
  Object toJson() => msg != null
      ? {
          'msg': msg,
          'args': [value],
        }
      : value;
}

/// Only allow uuids
/// Only allow uuids
@Target({TargetKind.field})
class IsUUID extends Validator {
  final int version;
  final String? msg;

  /// UUID version (1, 3, 4, or 5)
  const IsUUID(this.version, [this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg, 'args': version} : version;
}

// ============================================================================
// Range Validators (len)
// Type: [min, max] | { msg: string, args: [min, max] }
// ============================================================================

/// Only allow values with length between min and max
/// Only allow values with length between min and max
@Target({TargetKind.field})
class Len extends Validator {
  final int min;
  final int max;
  final String? msg;

  const Len(this.min, this.max, [this.msg]);

  @override
  Object toJson() => msg != null
      ? {
          'msg': msg,
          'args': [min, max],
        }
      : [min, max];
}

// ============================================================================
// List Validators (isIn, notIn, notContains)
// Type: List | { msg: string, args: List }
// ============================================================================

/// Check the value is one of these
/// Check the value is one of these
@Target({TargetKind.field})
class IsIn extends Validator {
  final List<dynamic> values;
  final String? msg;

  const IsIn(this.values, [this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg, 'args': values} : values;
}

/// Check the value is not one of these
/// Check the value is not one of these
@Target({TargetKind.field})
class NotIn extends Validator {
  final List<dynamic> values;
  final String? msg;

  const NotIn(this.values, [this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg, 'args': values} : values;
}

/// Don't allow specific substrings
@Target({TargetKind.field})
class NotContains extends Validator {
  final Object value; // String | List<String>
  final String? msg;

  const NotContains(this.value, [this.msg]);

  @override
  Object toJson() => msg != null ? {'msg': msg, 'args': value} : value;
}

// ============================================================================
// Validate Namespace Class
// ============================================================================

/// Namespace class for all validators using named constructors.
/// This allows for syntax like `@Validate.IsEmail('msg')`.
@Target({TargetKind.field})
class Validate extends Validator {
  final String? msg;
  final dynamic value;
  final dynamic args;
  final String? pattern;
  final String? flags;
  final int? min;
  final int? max;

  /// Private constructor to prevent direct instantiation without a named type.
  const Validate._({
    this.msg,
    this.value,
    this.args,
    this.pattern,
    this.flags,
    this.min,
    this.max,
  });

  const Validate.IsEmail([String? msg]) : this._(msg: msg);
  const Validate.IsUrl([String? msg]) : this._(msg: msg);
  const Validate.IsIP([String? msg]) : this._(msg: msg);
  const Validate.IsIPv4([String? msg]) : this._(msg: msg);
  const Validate.IsIPv6([String? msg]) : this._(msg: msg);
  const Validate.IsAlpha([String? msg]) : this._(msg: msg);
  const Validate.IsAlphanumeric([String? msg]) : this._(msg: msg);
  const Validate.IsNumeric([String? msg]) : this._(msg: msg);
  const Validate.IsInt([String? msg]) : this._(msg: msg);
  const Validate.IsFloat([String? msg]) : this._(msg: msg);
  const Validate.IsDecimal([String? msg]) : this._(msg: msg);
  const Validate.IsLowercase([String? msg]) : this._(msg: msg);
  const Validate.IsUppercase([String? msg]) : this._(msg: msg);
  const Validate.NotEmpty([String? msg]) : this._(msg: msg);
  const Validate.IsArray([String? msg]) : this._(msg: msg);
  const Validate.IsCreditCard([String? msg]) : this._(msg: msg);
  const Validate.IsDate([String? msg]) : this._(msg: msg);

  const Validate.Is(String pattern, [String? msg])
    : this._(pattern: pattern, msg: msg);
  const Validate.IsWithFlags(String pattern, String flags, [String? msg])
    : this._(pattern: pattern, flags: flags, msg: msg);

  const Validate.Not(String pattern, [String? msg])
    : this._(pattern: pattern, msg: msg);
  const Validate.NotWithFlags(String pattern, String flags, [String? msg])
    : this._(pattern: pattern, flags: flags, msg: msg);

  const Validate.Equals(String value, [String? msg])
    : this._(value: value, msg: msg);
  const Validate.Contains(String value, [String? msg])
    : this._(value: value, msg: msg);
  const Validate.IsAfter(String date, [String? msg])
    : this._(value: date, msg: msg);
  const Validate.IsBefore(String date, [String? msg])
    : this._(value: date, msg: msg);

  const Validate.Max(num value, [String? msg]) : this._(value: value, msg: msg);
  const Validate.Min(num value, [String? msg]) : this._(value: value, msg: msg);
  const Validate.IsUUID(int version, [String? msg])
    : this._(value: version, msg: msg);
  const Validate.Len(int min, int max, [String? msg])
    : this._(min: min, max: max, msg: msg);

  const Validate.IsIn(List<dynamic> values, [String? msg])
    : this._(value: values, msg: msg);
  const Validate.NotIn(List<dynamic> values, [String? msg])
    : this._(value: values, msg: msg);
  const Validate.NotContains(Object value, [String? msg])
    : this._(value: value, msg: msg);

  @override
  Object toJson() {
    // This is not strictly used by the generator as it generates the individual classes,
    // but implemented for completeness.
    return {};
  }
}

// ============================================================================
// ValidateOption - Combines all validators
// ============================================================================

/// Options for column validation
class ValidateOption {
  final Is? is_;
  final Not? not_;
  final IsEmail? isEmail;
  final IsUrl? isUrl;
  final IsIP? isIP;
  final IsIPv4? isIPv4;
  final IsIPv6? isIPv6;
  final IsAlpha? isAlpha;
  final IsAlphanumeric? isAlphanumeric;
  final IsNumeric? isNumeric;
  final IsInt? isInt;
  final IsFloat? isFloat;
  final IsDecimal? isDecimal;
  final IsLowercase? isLowercase;
  final IsUppercase? isUppercase;
  final NotEmpty? notEmpty;
  final Equals? equals;
  final Contains? contains;
  final NotIn? notIn;
  final IsIn? isIn;
  final NotContains? notContains;
  final Len? len;
  final IsUUID? isUUID;
  final IsDate? isDate;
  final IsAfter? isAfter;
  final IsBefore? isBefore;
  final Max? max;
  final Min? min;
  final IsArray? isArray;
  final IsCreditCard? isCreditCard;

  /// Custom validations (additional properties)
  final Map<String, dynamic>? custom;

  const ValidateOption({
    this.is_,
    this.not_,
    this.isEmail,
    this.isUrl,
    this.isIP,
    this.isIPv4,
    this.isIPv6,
    this.isAlpha,
    this.isAlphanumeric,
    this.isNumeric,
    this.isInt,
    this.isFloat,
    this.isDecimal,
    this.isLowercase,
    this.isUppercase,
    this.notEmpty,
    this.equals,
    this.contains,
    this.notIn,
    this.isIn,
    this.notContains,
    this.len,
    this.isUUID,
    this.isDate,
    this.isAfter,
    this.isBefore,
    this.max,
    this.min,
    this.isArray,
    this.isCreditCard,
    this.custom,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (is_ != null) json['is'] = is_!.toJson();
    if (not_ != null) json['not'] = not_!.toJson();
    if (isEmail != null) json['isEmail'] = isEmail!.toJson();
    if (isUrl != null) json['isUrl'] = isUrl!.toJson();
    if (isIP != null) json['isIP'] = isIP!.toJson();
    if (isIPv4 != null) json['isIPv4'] = isIPv4!.toJson();
    if (isIPv6 != null) json['isIPv6'] = isIPv6!.toJson();
    if (isAlpha != null) json['isAlpha'] = isAlpha!.toJson();
    if (isAlphanumeric != null)
      json['isAlphanumeric'] = isAlphanumeric!.toJson();
    if (isNumeric != null) json['isNumeric'] = isNumeric!.toJson();
    if (isInt != null) json['isInt'] = isInt!.toJson();
    if (isFloat != null) json['isFloat'] = isFloat!.toJson();
    if (isDecimal != null) json['isDecimal'] = isDecimal!.toJson();
    if (isLowercase != null) json['isLowercase'] = isLowercase!.toJson();
    if (isUppercase != null) json['isUppercase'] = isUppercase!.toJson();
    if (notEmpty != null) json['notEmpty'] = notEmpty!.toJson();
    if (equals != null) json['equals'] = equals!.toJson();
    if (contains != null) json['contains'] = contains!.toJson();
    if (notIn != null) json['notIn'] = notIn!.toJson();
    if (isIn != null) json['isIn'] = isIn!.toJson();
    if (notContains != null) json['notContains'] = notContains!.toJson();
    if (len != null) json['len'] = len!.toJson();
    if (isUUID != null) json['isUUID'] = isUUID!.toJson();
    if (isDate != null) json['isDate'] = isDate!.toJson();
    if (isAfter != null) json['isAfter'] = isAfter!.toJson();
    if (isBefore != null) json['isBefore'] = isBefore!.toJson();
    if (max != null) json['max'] = max!.toJson();
    if (min != null) json['min'] = min!.toJson();
    if (isArray != null) json['isArray'] = isArray!.toJson();
    if (isCreditCard != null) json['isCreditCard'] = isCreditCard!.toJson();
    if (custom != null) json.addAll(custom!);

    return json;
  }
}

/// Column options for model schema attributes
class ColumnDefinition {
  /// The name of the column in the database.
  ///
  /// This maps to Sequelize's `columnName` option.
  /// If no value is provided, Sequelize will use the name of the attribute
  /// (in snake_case if underscored is true)
  final String name;

  /// A string or a data type
  final DataType type;

  /// If false, the column will have a NOT NULL constraint, and a not null validation will be run before an instance is saved.
  ///
  /// Default: true
  final bool? allowNull;

  /// The name of the column (alternative to name, for explicit column name specification).
  ///
  /// If both name and columnName are provided, columnName takes precedence.
  final String? columnName;

  /// A literal default value, a JavaScript function, or an SQL function
  final dynamic defaultValue;

  /// If true, the column will get a unique constraint. If a string is provided, the column will be part of a
  /// composite unique index. If a UniqueOption is provided, it specifies the unique constraint options.
  final Object? unique; // bool | String | UniqueOption

  /// If true, an index will be created for this column.
  /// If a string is provided, the column will be part of a composite index together with the other attributes
  /// that specify the same index name. If an IndexOption is provided, it specifies the index options.
  final Object? index; // bool | String | IndexOption

  /// If true, this attribute will be marked as primary key
  final bool? primaryKey;

  /// Is this field an auto increment field
  final bool? autoIncrement;

  /// If this field is a Postgres auto increment field, use Postgres `GENERATED BY DEFAULT AS IDENTITY` instead of `SERIAL`.
  /// Postgres 10+ only.
  final bool? autoIncrementIdentity;

  /// Comment to add on the column in the database
  final String? comment;

  /// An object of validations to execute for this column every time the model is saved.
  /// Can be either the name of a validation provided by validator.js, a validation function provided by extending validator.js,
  /// or a custom validation function.
  final ValidateOption? validate;

  const ColumnDefinition({
    required this.name,
    required this.type,
    this.allowNull,
    this.columnName,
    this.defaultValue,
    this.unique,
    this.index,
    this.primaryKey,
    this.autoIncrement,
    this.autoIncrementIdentity,
    this.comment,
    this.validate,
  });

  /// Legacy constructor for backward compatibility
  /// @deprecated Use the main constructor
  @Deprecated('Use ColumnDefinition constructor')
  const ColumnDefinition.legacy({
    required this.name,
    required this.type,
    this.defaultValue,
    bool? notNull,
    this.primaryKey,
    this.autoIncrement,
  }) : allowNull = notNull == true ? false : null,
       columnName = null,
       unique = null,
       index = null,
       autoIncrementIdentity = null,
       comment = null,
       validate = null;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type.name,
    };

    // Use columnName if provided, otherwise use name
    final dbColumnName = columnName ?? name;
    json['columnName'] = dbColumnName;

    if (allowNull != null) {
      json['allowNull'] = allowNull;
    }
    if (defaultValue != null) {
      json['defaultValue'] = defaultValue;
    }
    if (unique != null) {
      if (unique is bool) {
        json['unique'] = unique;
      } else if (unique is String) {
        json['unique'] = unique;
      } else if (unique is UniqueOption) {
        json['unique'] = (unique as UniqueOption).toJson();
      }
    }
    if (index != null) {
      if (index is bool) {
        json['index'] = index;
      } else if (index is String) {
        json['index'] = index;
      } else if (index is IndexOption) {
        json['index'] = (index as IndexOption).toJson();
      }
    }
    if (primaryKey != null) {
      json['primaryKey'] = primaryKey;
    }
    if (autoIncrement != null) {
      json['autoIncrement'] = autoIncrement;
    }
    if (autoIncrementIdentity != null) {
      json['autoIncrementIdentity'] = autoIncrementIdentity;
    }
    if (comment != null) {
      json['comment'] = comment;
    }
    if (validate != null) {
      json['validate'] = validate!.toJson();
    }

    return json;
  }
}
