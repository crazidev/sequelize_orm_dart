import 'package:sequelize_dart/src/model/model_value/model_value_interface.dart';

/// Dart VM implementation of ModelValue
/// This is a placeholder for future Dart VM implementation
class ModelValue implements ModelValueInterface {
  @override
  dynamic get dataValues {
    throw UnimplementedError('ModelValue is not implemented for Dart VM');
  }

  @override
  dynamic toJSON() {
    throw UnimplementedError('ModelValue is not implemented for Dart VM');
  }

  @override
  bool get isNewRecord {
    throw UnimplementedError('ModelValue is not implemented for Dart VM');
  }

  @override
  ModelOptionsInterface get options {
    throw UnimplementedError('ModelValue is not implemented for Dart VM');
  }
}

/// Dart VM implementation of ModelOptions
/// This is a placeholder for future Dart VM implementation
class ModelOptions implements ModelOptionsInterface {
  @override
  List<dynamic> get attributes {
    throw UnimplementedError('ModelOptions is not implemented for Dart VM');
  }

  @override
  dynamic get model {
    throw UnimplementedError('ModelOptions is not implemented for Dart VM');
  }

  @override
  bool get raw {
    throw UnimplementedError('ModelOptions is not implemented for Dart VM');
  }

  @override
  String get schema {
    throw UnimplementedError('ModelOptions is not implemented for Dart VM');
  }
}
