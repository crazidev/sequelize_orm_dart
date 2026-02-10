part of '../../sequelize_model_generator.dart';

void _extractPatternValidator(
  ConstantReader reader,
  String fieldName,
  String className,
  List<String> validators,
) {
  final validatorReader = reader.peek(fieldName);
  if (validatorReader == null || validatorReader.isNull) return;

  final obj = validatorReader.objectValue;
  final patternReader = ConstantReader(obj).peek('pattern');
  final flagsReader = ConstantReader(obj).peek('flags');
  final msgReader = ConstantReader(obj).peek('msg');

  if (patternReader == null || patternReader.isNull) return;

  final pattern = patternReader.stringValue;
  final escapedPattern = pattern.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
  final flags = flagsReader?.isNull == false ? flagsReader?.stringValue : null;
  final msg = msgReader?.isNull == false ? msgReader?.stringValue : null;

  if (msg != null && flags != null) {
    validators.add(
      "$fieldName: $className.full(r'$escapedPattern', flags: '$flags', msg: '$msg')",
    );
  } else if (msg != null) {
    validators.add(
      "$fieldName: $className.withMsg(r'$escapedPattern', msg: '$msg')",
    );
  } else if (flags != null) {
    validators.add(
      "$fieldName: $className.withFlags(r'$escapedPattern', '$flags')",
    );
  } else {
    validators.add("$fieldName: $className(r'$escapedPattern')");
  }
}
