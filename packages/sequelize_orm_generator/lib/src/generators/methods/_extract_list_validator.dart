part of '../../sequelize_model_generator.dart';

void _extractListValidator(
  ConstantReader reader,
  String fieldName,
  String className,
  List<String> validators,
) {
  final validatorReader = reader.peek(fieldName);
  if (validatorReader == null || validatorReader.isNull) return;

  final obj = validatorReader.objectValue;
  final valuesReader = ConstantReader(obj).peek('values');
  final msgReader = ConstantReader(obj).peek('msg');

  if (valuesReader == null || valuesReader.isNull) return;

  final values = valuesReader.listValue;
  final valueStrings = values
      .map((v) {
        final reader = ConstantReader(v);
        if (reader.isString) return "'${reader.stringValue}'";
        if (reader.isInt) return '${reader.intValue}';
        if (reader.isDouble) return '${reader.doubleValue}';
        if (reader.isBool) return '${reader.boolValue}';
        return 'null';
      })
      .join(', ');

  final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

  if (msg != null) {
    validators.add(
      "$fieldName: $className.withMsg([$valueStrings], msg: '$msg')",
    );
  } else {
    validators.add('$fieldName: $className([$valueStrings])');
  }
}
