part of '../../sequelize_model_generator.dart';

String? _extractValidateCode(ConstantReader? validateReader) {
  if (validateReader == null || validateReader.isNull) return null;

  final validators = <String>[];

  // Boolean validators
  _extractBooleanValidator(validateReader, 'isEmail', 'IsEmail', validators);
  _extractBooleanValidator(validateReader, 'isUrl', 'IsUrl', validators);
  _extractBooleanValidator(validateReader, 'isIP', 'IsIP', validators);
  _extractBooleanValidator(validateReader, 'isIPv4', 'IsIPv4', validators);
  _extractBooleanValidator(validateReader, 'isIPv6', 'IsIPv6', validators);
  _extractBooleanValidator(validateReader, 'isAlpha', 'IsAlpha', validators);
  _extractBooleanValidator(
    validateReader,
    'isAlphanumeric',
    'IsAlphanumeric',
    validators,
  );
  _extractBooleanValidator(
    validateReader,
    'isNumeric',
    'IsNumeric',
    validators,
  );
  _extractBooleanValidator(validateReader, 'isInt', 'IsInt', validators);
  _extractBooleanValidator(validateReader, 'isFloat', 'IsFloat', validators);
  _extractBooleanValidator(
    validateReader,
    'isDecimal',
    'IsDecimal',
    validators,
  );
  _extractBooleanValidator(
    validateReader,
    'isLowercase',
    'IsLowercase',
    validators,
  );
  _extractBooleanValidator(
    validateReader,
    'isUppercase',
    'IsUppercase',
    validators,
  );
  _extractBooleanValidator(
    validateReader,
    'notEmpty',
    'NotEmpty',
    validators,
  );
  _extractBooleanValidator(validateReader, 'isArray', 'IsArray', validators);
  _extractBooleanValidator(
    validateReader,
    'isCreditCard',
    'IsCreditCard',
    validators,
  );
  _extractBooleanValidator(validateReader, 'isDate', 'IsDate', validators);

  // Pattern validators (is_, not_)
  _extractPatternValidator(validateReader, 'is_', 'Is', validators);
  _extractPatternValidator(validateReader, 'not_', 'Not', validators);

  // String validators
  _extractStringValidator(validateReader, 'equals', 'Equals', validators);
  _extractStringValidator(validateReader, 'contains', 'Contains', validators);
  _extractStringValidator(validateReader, 'isAfter', 'IsAfter', validators);
  _extractStringValidator(validateReader, 'isBefore', 'IsBefore', validators);

  // Number validators
  _extractNumberValidator(validateReader, 'max', 'Max', validators);
  _extractNumberValidator(validateReader, 'min', 'Min', validators);
  _extractNumberValidator(validateReader, 'isUUID', 'IsUUID', validators);

  // Range validator (len)
  _extractLenValidator(validateReader, validators);

  // List validators
  _extractListValidator(validateReader, 'isIn', 'IsIn', validators);
  _extractListValidator(validateReader, 'notIn', 'NotIn', validators);
  _extractNotContainsValidator(validateReader, validators);

  if (validators.isEmpty) return null;

  return 'ValidateOption(${validators.join(', ')})';
}
