import 'dart:js' as js;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:sequelize_dart/sequelize_dart.dart';
import 'package:sequelize_dart/src/core/console.dart';
import 'package:sequelize_dart/src/core/global.dart';
import 'package:sequelize_dart/src/sequelize/sequelize_interface.dart';
import 'package:sequelize_dart/src/types/data_types.dart';

class Sequelize extends SequelizeInterface {
  late SequelizeJS sequelize;

  @override
  Future<void> authenticate() async {
    await sequelize.authenticate().toDart;
  }

  @override
  SequelizeInterface createInstance(SequelizeCoreOptions input) {
    final Map<String, dynamic> config = input.toJson();

    if (input.url != null) {
      final keysToRemove = ['host', 'password', 'user', 'database', 'port'];
      config.removeWhere((key, value) => keysToRemove.contains(key));
    }

    if (input.logging != null) {
      config['logging'] = js.allowInterop((JSAny sql, JSAny? timing) {
        input.logging!(sql.toString());
      });
    }

    final hoist = config['hoistIncludeOptions'] == true;
    config.remove('hoistIncludeOptions');

    sequelize =
        sequelizeModule.sequelizeFn.callAsConstructor(
              config.jsify(),
            )
            as SequelizeJS;

    // Store custom bridge options on the instance for QueryEngine to access
    sequelize.setProperty('hoistIncludeOptions'.toJS, hoist.toJS);

    return this;
  }

  @override
  Future<void> initialize({required List<Model> models}) async {
    // Define all models first
    for (var model in models) {
      model.define(model.name, sequelize);
    }

    // Then set up associations
    for (var model in models) {
      await model.associateModel();
    }
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

  // --- SQL Expression Builders ---

  static SqlFn fn(String fn, [dynamic args]) =>
      SqlFn(fn, args is List ? args : (args == null ? null : [args]));
  static SqlCol col(String col) => SqlCol(col);
  static SqlLiteral literal(String val) => SqlLiteral(val);
  static SqlAttribute attribute(String attr) => SqlAttribute(attr);
  static SqlIdentifier identifier(String id) => SqlIdentifier(id);
  static SqlCast cast(dynamic expr, String type) => SqlCast(expr, type);
  static SqlRandom random() => SqlRandom();
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

  @JS('random')
  @staticInterop
  external static JSObject random();
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

  @JS('sql')
  external SqSql get sql;

  @JS('Sequelize')
  external JSObject get sequelizeClass;
}

extension type SqSql._(JSObject _) implements JSObject {
  @JS('fn')
  external JSObject fn(
    String fn, [
    JSAny? arg1,
    JSAny? arg2,
    JSAny? arg3,
    JSAny? arg4,
    JSAny? arg5,
  ]);

  @JS('col')
  external JSObject col(String col);

  @JS('literal')
  external JSObject literal(String val);

  @JS('attribute')
  external JSObject attribute(String attr);

  @JS('identifier')
  external JSObject identifier(String id);

  @JS('cast')
  external JSObject cast(JSAny expr, String type);

  @JS('random')
  external JSObject random();
}

extension type SqOp._(JSObject _) implements JSObject {
  // Logical operators
  external JSSymbol get not;
  external JSSymbol get or;
  external JSSymbol get and;

  // Basic comparison operators
  external JSSymbol get eq;
  external JSSymbol get ne;
  @JS('is')
  external JSSymbol get isOp;
  external JSSymbol get isNot;

  // Number comparison operators
  external JSSymbol get gt;
  external JSSymbol get gte;
  external JSSymbol get lt;
  external JSSymbol get lte;
  external JSSymbol get between;
  external JSSymbol get notBetween;

  // List operators
  @JS('in')
  external JSSymbol get inOp;
  external JSSymbol get notIn;
  external JSSymbol get all;
  external JSSymbol get any;

  // String operators
  external JSSymbol get like;
  external JSSymbol get notLike;
  external JSSymbol get startsWith;
  external JSSymbol get endsWith;
  external JSSymbol get substring;
  external JSSymbol get iLike;
  external JSSymbol get notILike;

  // Regex operators
  external JSSymbol get regexp;
  external JSSymbol get notRegexp;
  external JSSymbol get iRegexp;
  external JSSymbol get notIRegexp;

  // Other operators
  external JSSymbol get col;
  external JSSymbol get match;
}

SqOp get Op => sequelizeModule.op;
SqSql get Sql => sequelizeModule.sql;

extension type SequelizeModel._(JSObject _) implements JSObject {
  @JS('findAll')
  external JSPromise<JSArray<JSObject>> findAll(JSObject? options);

  @JS('findOne')
  external JSPromise<JSObject?> findOne(JSObject? options);

  @JS('count')
  external JSPromise<JSAny> count(JSObject? options);

  @JS('max')
  external JSPromise<JSAny> max(JSAny column, JSObject? options);

  @JS('min')
  external JSPromise<JSAny> min(JSAny column, JSObject? options);

  @JS('sum')
  external JSPromise<JSAny> sum(JSAny column, JSObject? options);

  @JS('hasOne')
  external JSObject hasOne(SequelizeModel model, JSObject? options);

  @JS('hasMany')
  external JSObject hasMany(SequelizeModel model, JSObject? options);

  @JS('belongsTo')
  external JSObject belongsTo(SequelizeModel model, JSObject? options);

  @JS('belongsToMany')
  external JSObject belongsToMany(SequelizeModel model, JSObject? options);
}
