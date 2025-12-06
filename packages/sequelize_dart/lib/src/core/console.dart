// --- JS Console Interop (Remains the same) ---
import 'dart:js_interop';

@JS()
external JSConsole get console;

extension type JSConsole._(JSObject _) implements JSObject {
  external void error(JSAny? message);
  external void log(JSAny? message, [JSAny? message2]);
  external void warn(JSAny? message);
  external void info(JSAny? message);
}
