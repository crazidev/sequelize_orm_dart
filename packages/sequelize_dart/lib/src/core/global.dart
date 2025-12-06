import 'dart:js_interop';

@JS('require')
external JSObject require(String module);

@JS()
external JSGlobal get globalThis;

extension type JSGlobal._(JSObject _) implements JSObject {}
