part of '../../sequelize_model_generator.dart';

void _extractBooleanValidator(
  ConstantReader reader,
  String fieldName,
  String className,
  List<String> validators,
) {
  final validatorReader = reader.peek(fieldName);
  if (validatorReader == null || validatorReader.isNull) return;

  final obj = validatorReader.objectValue;
  final msgReader = ConstantReader(obj).peek('msg');

  if (msgReader != null && !msgReader.isNull) {
    final msg = msgReader.stringValue;
    validators.add("$fieldName: $className.withMsg('$msg')");
  } else {
    validators.add('$fieldName: $className()');
  }
}
