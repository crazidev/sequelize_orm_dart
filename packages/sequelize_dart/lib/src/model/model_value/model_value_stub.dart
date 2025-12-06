import 'package:sequelize_dart/src/model/model_value/model_value_interface.dart';

/// Stub implementation of ModelValue
/// Used when neither JS interop nor Dart VM implementation is available
class ModelValue implements ModelValueInterface {
  @override
  dynamic get dataValues {
    throw UnimplementedError('ModelValue is not available in this environment');
  }

  @override
  bool get isNewRecord {
    throw UnimplementedError('ModelValue is not available in this environment');
  }

  @override
  ModelOptionsInterface get options {
    throw UnimplementedError('ModelValue is not available in this environment');
  }
}

/// Stub implementation of ModelOptions
/// Used when neither JS interop nor Dart VM implementation is available
class ModelOptions implements ModelOptionsInterface {
  @override
  List<dynamic> get attributes {
    throw UnimplementedError(
      'ModelOptions is not available in this environment',
    );
  }

  @override
  dynamic get model {
    throw UnimplementedError(
      'ModelOptions is not available in this environment',
    );
  }

  @override
  bool get raw {
    throw UnimplementedError(
      'ModelOptions is not available in this environment',
    );
  }

  @override
  String get schema {
    throw UnimplementedError(
      'ModelOptions is not available in this environment',
    );
  }
}
