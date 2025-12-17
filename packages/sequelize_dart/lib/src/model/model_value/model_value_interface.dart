/// Interface for ModelValue
abstract class ModelValueInterface {
  /// Get the data values from the model instance
  dynamic get dataValues;

  /// Convert the model instance to JSON
  dynamic toJSON();

  /// Check if this is a new record
  bool get isNewRecord;

  /// Get the model options
  ModelOptionsInterface get options;
}

/// Interface for ModelOptions
abstract class ModelOptionsInterface {
  /// Get the raw flag
  bool get raw;

  /// Get the attributes array
  List<dynamic> get attributes;

  /// Get the model instance
  dynamic get model;

  /// Get the schema
  String get schema;
}
