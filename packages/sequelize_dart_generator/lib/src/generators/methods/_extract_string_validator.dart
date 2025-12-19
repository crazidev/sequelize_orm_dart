part of '../../sequelize_model_generator.dart';

void _extractStringValidator(
  ConstantReader reader,
  String fieldName,
  String className,
  List<String> validators,
) {
  final validatorReader = reader.peek(fieldName);
  if (validatorReader == null || validatorReader.isNull) return;

  final obj = validatorReader.objectValue;

  // Check if it has 'value' field (for Equals, Contains) or 'date' field (for IsAfter, IsBefore)
  final valueReader = ConstantReader(obj).peek('value');
  final dateReader = ConstantReader(obj).peek('date');
  final msgReader = ConstantReader(obj).peek('msg');

  final stringValue = valueReader?.isNull == false
      ? valueReader?.stringValue
      : dateReader?.isNull == false
      ? dateReader?.stringValue
      : null;

  if (stringValue == null) return;

  final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

  if (msg != null) {
    validators.add(
      "$fieldName: $className.withMsg('$stringValue', msg: '$msg')",
    );
  } else {
    validators.add("$fieldName: $className('$stringValue')");
  }
}
