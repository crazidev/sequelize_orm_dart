import 'dart:js_interop';
import 'package:sequelize_dart/src/sequelize/sequelize_js.dart';

/// JS implementation of ModelValue using extension types
extension type ModelValue._(JSObject _) implements JSObject {
  external JSObject get dataValues;
  external JSBoolean get isNewRecord;

  @JS("_options")
  external ModelOptions get options;
}

/// JS implementation of ModelOptions using extension types
extension type ModelOptions._(JSObject _) implements JSObject {
  external JSBoolean get raw;
  external JSArray get attributes;
  external SequelizeModel get model;

  @JS("_schema")
  external JSString get schema;
}
