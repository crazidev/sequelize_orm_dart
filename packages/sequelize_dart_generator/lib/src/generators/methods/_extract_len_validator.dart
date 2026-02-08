part of '../../sequelize_model_generator.dart';

void _extractLenValidator(ConstantReader reader, List<String> validators) {
  final validatorReader = reader.peek('len');
  if (validatorReader == null || validatorReader.isNull) return;

  final obj = validatorReader.objectValue;
  final minReader = ConstantReader(obj).peek('min');
  final maxReader = ConstantReader(obj).peek('max');
  final msgReader = ConstantReader(obj).peek('msg');

  if (minReader == null ||
      minReader.isNull ||
      maxReader == null ||
      maxReader.isNull) {
    return;
  }

  final min = minReader.intValue;
  final max = maxReader.intValue;
  final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

  if (msg != null) {
    validators.add("len: Len.withMsg($min, $max, msg: '$msg')");
  } else {
    validators.add('len: Len($min, $max)');
  }
}
