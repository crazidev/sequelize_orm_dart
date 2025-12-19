part of '../../sequelize_model_generator.dart';

void _extractNumberValidator(
  ConstantReader reader,
  String fieldName,
  String className,
  List<String> validators,
) {
  final validatorReader = reader.peek(fieldName);
  if (validatorReader == null || validatorReader.isNull) return;

  final obj = validatorReader.objectValue;
  final valueReader = ConstantReader(obj).peek('value');
  final versionReader = ConstantReader(obj).peek('version'); // for IsUUID
  final msgReader = ConstantReader(obj).peek('msg');

  final numValue = valueReader?.isNull == false
      ? valueReader?.literalValue
      : versionReader?.isNull == false
      ? versionReader?.intValue
      : null;

  if (numValue == null) return;

  final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

  if (msg != null) {
    validators.add("$fieldName: $className.withMsg($numValue, msg: '$msg')");
  } else {
    validators.add('$fieldName: $className($numValue)');
  }
}
