import 'package:sequelize_dart_annotations/src/enums.dart';

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

/// Validation message wrapper
class ValidationMessage {
  final String msg;
  final dynamic args;

  const ValidationMessage({required this.msg, this.args});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'msg': msg};
    if (args != null) json['args'] = args;
    return json;
  }
}

/// Options for column validation
class ValidateOption {
  /// - `{ is: ['^[a-z]+$','i'] }` will only allow letters
  /// - `{ is: /^[a-z]+$/i }` also only allows letters
  final Object? is_; // String | List<String> | ValidationMessage

  /// - `{ not: ['[a-z]','i'] }` will not allow letters
  final Object? not_; // String | List<String> | ValidationMessage

  /// Checks for email format (foo@bar.com)
  final Object? isEmail; // bool | ValidationMessage

  /// Checks for url format (http://foo.com)
  final Object? isUrl; // bool | ValidationMessage

  /// Checks for IPv4 (129.89.23.1) or IPv6 format
  final Object? isIP; // bool | ValidationMessage

  /// Checks for IPv4 (129.89.23.1)
  final Object? isIPv4; // bool | ValidationMessage

  /// Checks for IPv6 format
  final Object? isIPv6; // bool | ValidationMessage

  /// Will only allow letters
  final Object? isAlpha; // bool | ValidationMessage

  /// Will only allow alphanumeric characters, so "_abc" will fail
  final Object? isAlphanumeric; // bool | ValidationMessage

  /// Will only allow numbers
  final Object? isNumeric; // bool | ValidationMessage

  /// Checks for valid integers
  final Object? isInt; // bool | ValidationMessage

  /// Checks for valid floating point numbers
  final Object? isFloat; // bool | ValidationMessage

  /// Checks for any numbers
  final Object? isDecimal; // bool | ValidationMessage

  /// Checks for lowercase
  final Object? isLowercase; // bool | ValidationMessage

  /// Checks for uppercase
  final Object? isUppercase; // bool | ValidationMessage

  /// Don't allow empty strings
  final Object? notEmpty; // bool | ValidationMessage

  /// Only allow a specific value
  final Object? equals; // String | ValidationMessage

  /// Force specific substrings
  final Object? contains; // String | ValidationMessage

  /// Check the value is not one of these
  final Object? notIn; // List<dynamic> | ValidationMessage

  /// Check the value is one of these
  final Object? isIn; // List<dynamic> | ValidationMessage

  /// Don't allow specific substrings
  final Object? notContains; // String | List<String> | ValidationMessage

  /// Only allow values with length between min and max
  final Object? len; // List<int> | ValidationMessage

  /// Only allow uuids
  final Object? isUUID; // int | ValidationMessage

  /// Only allow date strings
  final Object? isDate; // bool | ValidationMessage

  /// Only allow date strings after a specific date
  final Object? isAfter; // String | ValidationMessage

  /// Only allow date strings before a specific date
  final Object? isBefore; // String | ValidationMessage

  /// Only allow values <= max
  final Object? max; // int | ValidationMessage

  /// Only allow values >= min
  final Object? min; // int | ValidationMessage

  /// Only allow arrays
  final Object? isArray; // bool | ValidationMessage

  /// Check for valid credit card numbers
  final Object? isCreditCard; // bool | ValidationMessage

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

    if (is_ != null) {
      json['is'] = _convertValidationValue(is_);
    }
    if (not_ != null) {
      json['not'] = _convertValidationValue(not_);
    }
    if (isEmail != null) {
      json['isEmail'] = _convertValidationValue(isEmail);
    }
    if (isUrl != null) {
      json['isUrl'] = _convertValidationValue(isUrl);
    }
    if (isIP != null) {
      json['isIP'] = _convertValidationValue(isIP);
    }
    if (isIPv4 != null) {
      json['isIPv4'] = _convertValidationValue(isIPv4);
    }
    if (isIPv6 != null) {
      json['isIPv6'] = _convertValidationValue(isIPv6);
    }
    if (isAlpha != null) {
      json['isAlpha'] = _convertValidationValue(isAlpha);
    }
    if (isAlphanumeric != null) {
      json['isAlphanumeric'] = _convertValidationValue(isAlphanumeric);
    }
    if (isNumeric != null) {
      json['isNumeric'] = _convertValidationValue(isNumeric);
    }
    if (isInt != null) {
      json['isInt'] = _convertValidationValue(isInt);
    }
    if (isFloat != null) {
      json['isFloat'] = _convertValidationValue(isFloat);
    }
    if (isDecimal != null) {
      json['isDecimal'] = _convertValidationValue(isDecimal);
    }
    if (isLowercase != null) {
      json['isLowercase'] = _convertValidationValue(isLowercase);
    }
    if (isUppercase != null) {
      json['isUppercase'] = _convertValidationValue(isUppercase);
    }
    if (notEmpty != null) {
      json['notEmpty'] = _convertValidationValue(notEmpty);
    }
    if (equals != null) {
      json['equals'] = _convertValidationValue(equals);
    }
    if (contains != null) {
      json['contains'] = _convertValidationValue(contains);
    }
    if (notIn != null) {
      json['notIn'] = _convertValidationValue(notIn);
    }
    if (isIn != null) {
      json['isIn'] = _convertValidationValue(isIn);
    }
    if (notContains != null) {
      json['notContains'] = _convertValidationValue(notContains);
    }
    if (len != null) {
      json['len'] = _convertValidationValue(len);
    }
    if (isUUID != null) {
      json['isUUID'] = _convertValidationValue(isUUID);
    }
    if (isDate != null) {
      json['isDate'] = _convertValidationValue(isDate);
    }
    if (isAfter != null) {
      json['isAfter'] = _convertValidationValue(isAfter);
    }
    if (isBefore != null) {
      json['isBefore'] = _convertValidationValue(isBefore);
    }
    if (max != null) {
      json['max'] = _convertValidationValue(max);
    }
    if (min != null) {
      json['min'] = _convertValidationValue(min);
    }
    if (isArray != null) {
      json['isArray'] = _convertValidationValue(isArray);
    }
    if (isCreditCard != null) {
      json['isCreditCard'] = _convertValidationValue(isCreditCard);
    }
    if (custom != null) {
      json.addAll(custom!);
    }

    return json;
  }

  dynamic _convertValidationValue(Object? value) {
    if (value == null) return null;
    if (value is ValidationMessage) return value.toJson();
    if (value is bool || value is String || value is int || value is double) {
      return value;
    }
    if (value is List) return value;
    return value;
  }
}

/// Column options for model schema attributes
class ModelAttributes {
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

  const ModelAttributes({
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
  @Deprecated('Use ModelAttributes constructor')
  const ModelAttributes.legacy({
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
