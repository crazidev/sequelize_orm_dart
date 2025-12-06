import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:js' as js;

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/core/console.dart';
import 'package:sequelize_dart/src/core/global.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_interface.dart';
import 'package:sequelize_dart/src/connection/core_options.dart';
import 'package:sequelize_dart/src/types/data_types.dart';

class Sequelize extends SequelizeInterface {
  late SequelizeJS sequelize;

  @override
  Future<void> authenticate() async {
    await sequelize.authenticate().toDart;
  }

  @override
  SequelizeInterface createInstance(
    SequelizeCoreOptions input, {
    List<Model>? models,
  }) {
    Map<String, dynamic> config = input.toJson();

    if (input.url != null) {
      var keysToRemove = ['host', 'password', 'user', 'database', 'port'];
      config.removeWhere((key, value) => keysToRemove.contains(key));
    }

    if (input.logging != null) {
      config['logging'] = js.allowInterop((JSAny sql, JSAny? timing) {
        input.logging!(sql.toString());
      });
    }

    sequelize = sequelizeModule.sequelizeFn.callAsConstructor(
      config.jsify(),
    );

    if (models != null) {
      for (var model in models) {
        model.define(model.name, sequelize);
      }
    }

    return this;
  }

  @override
  void addModels(List<Model> models) {
    for (var model in models) {
      model.define(model.name, sequelize);
    }
  }

  @override
  void define(
    String name,
    Map<String, Map<String, dynamic>> attributes,
    Map<String, dynamic> options,
  ) {
    console.warn('Defining model: $name'.toJS);
  }

  @override
  Future<void> close() async {
    await sequelize.close().toDart;
  }
}

SequelizeModule get sequelizeModule =>
    require('@sequelize/core') as SequelizeModule;

extension type SequelizeJS._(JSObject _) implements JSObject {
  @JS('authenticate')
  external JSPromise authenticate();

  @JS('close')
  external JSPromise close();

  @JS('define')
  external SequelizeModel define(
    JSString modelName,
    JSObject? attributes,
    JSObject? options,
  );
}

extension type SequelizeModule._(JSObject _) implements JSObject {
  @JS('Sequelize')
  external SequelizeJS get sequelize;

  @JS('Sequelize')
  external JSFunction get sequelizeFn;

  @JS('Model')
  external SequelizeModel get model;

  @JS('DataTypes')
  external SequelizeDataTypes get dataTypes;

  @JS('Op')
  external SqOp get op;
}

extension type SqOp._(JSObject _) implements JSObject {
  external JSSymbol get not;
  external JSSymbol get or;
  external JSSymbol get and;

  external JSSymbol get eq;
  external JSSymbol get ne;
  external JSSymbol get gt;
  external JSSymbol get gte;
  external JSSymbol get lt;
  external JSSymbol get lte;

  external JSSymbol get notIn;
}

SqOp get Op => sequelizeModule.op;

extension type SequelizeModel._(JSObject _) implements JSObject {
  @JS('findAll')
  external JSPromise<JSArray<JSObject>> findAll(JSObject? options);

  @JS('findOne')
  external JSPromise<JSObject?> findOne(JSObject? options);
}
