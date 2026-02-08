part of '../../sequelize_model_generator.dart';

void _extractNotContainsValidator(
  ConstantReader reader,
  List<String> validators,
) {
  final validatorReader = reader.peek('notContains');
  if (validatorReader == null || validatorReader.isNull) return;

  final obj = validatorReader.objectValue;
  final valueReader = ConstantReader(obj).peek('value');
  final msgReader = ConstantReader(obj).peek('msg');

  if (valueReader == null || valueReader.isNull) return;

  String valueCode;
  if (valueReader.isString) {
    valueCode = "'${valueReader.stringValue}'";
  } else if (valueReader.isList) {
    final values = valueReader.listValue;
    final valueStrings = values
        .map((v) => "'${ConstantReader(v).stringValue}'")
        .join(', ');
    valueCode = '[$valueStrings]';
  } else {
    return;
  }

  final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

  if (msg != null) {
    validators.add(
      "notContains: NotContains.withMsg($valueCode, msg: '$msg')",
    );
  } else {
    validators.add('notContains: NotContains($valueCode)');
  }
}
